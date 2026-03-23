package com.negosud.api.service.impl;

import com.negosud.api.dto.request.InventaireRequestDto;
import com.negosud.api.dto.response.InventaireResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.InventaireMapper;
import com.negosud.api.model.entity.Article;
import com.negosud.api.model.entity.Inventaire;
import com.negosud.api.model.entity.LigneInventaire;
import com.negosud.api.repository.ArticleRepository;
import com.negosud.api.repository.InventaireRepository;
import com.negosud.api.service.InventaireService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class InventaireServiceImpl implements InventaireService {

    private final InventaireRepository inventaireRepository;
    private final ArticleRepository articleRepository;
    private final InventaireMapper inventaireMapper;

    @Override
    @Transactional(readOnly = true)
    public List<InventaireResponseDto> findAll() {
        return inventaireRepository.findAll().stream()
                .map(inventaireMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public InventaireResponseDto findById(Long id) {
        return inventaireMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    public InventaireResponseDto create(InventaireRequestDto dto) {
        Inventaire inventaire = new Inventaire();
        inventaire.setCommentaire(dto.getCommentaire());

        for (var ligneDto : dto.getLignes()) {
            Article article = articleRepository.findById(ligneDto.getArticleId())
                    .orElseThrow(() -> new ResourceNotFoundException("Article", ligneDto.getArticleId()));

            LigneInventaire ligne = new LigneInventaire();
            ligne.setArticle(article);
            ligne.setQuantiteConstatee(ligneDto.getQuantiteConstatee());
            // Snapshot du stock actuel avant toute régularisation
            ligne.setQuantiteAvantRegularisation(article.getQuantiteStock());
            ligne.setInventaire(inventaire);
            inventaire.getLignes().add(ligne);
        }

        return inventaireMapper.toResponseDto(inventaireRepository.save(inventaire));
    }

    @Override
    public InventaireResponseDto regulariser(Long id) {
        Inventaire inventaire = getOrThrow(id);

        if (Boolean.TRUE.equals(inventaire.getRegularise())) {
            throw new IllegalArgumentException("Cet inventaire a déjà été régularisé");
        }

        // Mise à jour du stock de chaque article avec la quantité constatée
        for (LigneInventaire ligne : inventaire.getLignes()) {
            Article article = ligne.getArticle();
            article.setQuantiteStock(ligne.getQuantiteConstatee());
            articleRepository.save(article);
        }

        inventaire.setRegularise(true);
        return inventaireMapper.toResponseDto(inventaireRepository.save(inventaire));
    }

    private Inventaire getOrThrow(Long id) {
        return inventaireRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Inventaire", id));
    }
}
