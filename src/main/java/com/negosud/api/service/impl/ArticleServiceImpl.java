package com.negosud.api.service.impl;

import com.negosud.api.dto.request.ArticleRequestDto;
import com.negosud.api.dto.request.ReapprovisionnementDto;
import com.negosud.api.dto.request.StockAjustementDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.exception.StockInsuffisantException;
import com.negosud.api.mapper.ArticleMapper;
import com.negosud.api.model.entity.Article;
import com.negosud.api.model.entity.Famille;
import com.negosud.api.model.entity.Fournisseur;
import com.negosud.api.repository.ArticleRepository;
import com.negosud.api.repository.FamilleRepository;
import com.negosud.api.repository.FournisseurRepository;
import com.negosud.api.service.ArticleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ArticleServiceImpl implements ArticleService {

    private final ArticleRepository articleRepository;
    private final FamilleRepository familleRepository;
    private final FournisseurRepository fournisseurRepository;
    private final ArticleMapper articleMapper;

    @Override
    @Transactional(readOnly = true)
    public List<ArticleResponseDto> findAll() {
        return articleRepository.findAll().stream()
                .map(articleMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ArticleResponseDto> findByFamille(Long familleId) {
        return articleRepository.findByFamilleId(familleId).stream()
                .map(articleMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ArticleResponseDto> findByFournisseur(Long fournisseurId) {
        return articleRepository.findByFournisseurId(fournisseurId).stream()
                .map(articleMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ArticleResponseDto findById(Long id) {
        return articleMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    public ArticleResponseDto create(ArticleRequestDto dto) {
        Article article = articleMapper.toEntity(dto);
        article.setFamille(getFamilleOrThrow(dto.getFamilleId()));
        article.setFournisseur(getFournisseurOrThrow(dto.getFournisseurId()));
        return articleMapper.toResponseDto(articleRepository.save(article));
    }

    @Override
    public ArticleResponseDto update(Long id, ArticleRequestDto dto) {
        Article article = getOrThrow(id);
        articleMapper.updateEntityFromDto(dto, article);
        article.setFamille(getFamilleOrThrow(dto.getFamilleId()));
        article.setFournisseur(getFournisseurOrThrow(dto.getFournisseurId()));
        return articleMapper.toResponseDto(articleRepository.save(article));
    }

    @Override
    public ArticleResponseDto ajusterStock(Long id, StockAjustementDto dto) {
        Article article = getOrThrow(id);
        int nouveauStock = article.getQuantiteStock() + dto.getQuantite();
        if (nouveauStock < 0) {
            throw new StockInsuffisantException(
                    "Stock insuffisant pour l'article '" + article.getDesignation() +
                    "'. Stock actuel : " + article.getQuantiteStock() +
                    ", quantité demandée : " + Math.abs(dto.getQuantite()));
        }
        article.setQuantiteStock(nouveauStock);
        return articleMapper.toResponseDto(articleRepository.save(article));
    }

    @Override
    public ArticleResponseDto toggleReapprovisionnement(Long id, ReapprovisionnementDto dto) {
        Article article = getOrThrow(id);
        article.setReapprovisionnementAuto(dto.getActif());
        return articleMapper.toResponseDto(articleRepository.save(article));
    }

    @Override
    public void delete(Long id) {
        articleRepository.delete(getOrThrow(id));
    }

    private Article getOrThrow(Long id) {
        return articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", id));
    }

    private Famille getFamilleOrThrow(Long id) {
        return familleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Famille", id));
    }

    private Fournisseur getFournisseurOrThrow(Long id) {
        return fournisseurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Fournisseur", id));
    }
}
