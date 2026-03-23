package com.negosud.api.service.impl;

import com.negosud.api.dto.request.FournisseurRequestDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.dto.response.FournisseurResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.ArticleMapper;
import com.negosud.api.mapper.FournisseurMapper;
import com.negosud.api.model.entity.Fournisseur;
import com.negosud.api.repository.ArticleRepository;
import com.negosud.api.repository.FournisseurRepository;
import com.negosud.api.service.FournisseurService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class FournisseurServiceImpl implements FournisseurService {

    private final FournisseurRepository fournisseurRepository;
    private final ArticleRepository articleRepository;
    private final FournisseurMapper fournisseurMapper;
    private final ArticleMapper articleMapper;

    @Override
    @Transactional(readOnly = true)
    public List<FournisseurResponseDto> findAll() {
        return fournisseurRepository.findAll().stream()
                .map(fournisseurMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public FournisseurResponseDto findById(Long id) {
        return fournisseurMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ArticleResponseDto> findArticlesByFournisseur(Long id) {
        getOrThrow(id);
        return articleRepository.findByFournisseurId(id).stream()
                .map(articleMapper::toResponseDto)
                .toList();
    }

    @Override
    public FournisseurResponseDto create(FournisseurRequestDto dto) {
        Fournisseur fournisseur = fournisseurMapper.toEntity(dto);
        return fournisseurMapper.toResponseDto(fournisseurRepository.save(fournisseur));
    }

    @Override
    public FournisseurResponseDto update(Long id, FournisseurRequestDto dto) {
        Fournisseur fournisseur = getOrThrow(id);
        fournisseurMapper.updateEntityFromDto(dto, fournisseur);
        return fournisseurMapper.toResponseDto(fournisseurRepository.save(fournisseur));
    }

    @Override
    public void delete(Long id) {
        fournisseurRepository.delete(getOrThrow(id));
    }

    private Fournisseur getOrThrow(Long id) {
        return fournisseurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Fournisseur", id));
    }
}
