package com.negosud.api.mapper;

import com.negosud.api.dto.request.ArticleRequestDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.model.entity.Article;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ArticleMapper {

    private final FamilleMapper familleMapper;
    private final FournisseurMapper fournisseurMapper;

    public ArticleResponseDto toResponseDto(Article article) {
        if (article == null) return null;
        ArticleResponseDto dto = new ArticleResponseDto();
        dto.setId(article.getId());
        dto.setReference(article.getReference());
        dto.setDesignation(article.getDesignation());
        dto.setDescription(article.getDescription());
        dto.setMaison(article.getMaison());
        dto.setAnnee(article.getAnnee());
        dto.setPrixUnitaire(article.getPrixUnitaire());
        dto.setPrixCarton(article.getPrixCarton());
        dto.setQuantiteStock(article.getQuantiteStock());
        dto.setSeuilMinimum(article.getSeuilMinimum());
        dto.setReapprovisionnementAuto(article.getReapprovisionnementAuto());
        dto.setFamille(familleMapper.toResponseDto(article.getFamille()));
        dto.setFournisseur(fournisseurMapper.toResponseDto(article.getFournisseur()));
        return dto;
    }

    public Article toEntity(ArticleRequestDto dto) {
        if (dto == null) return null;
        Article article = new Article();
        updateEntityFromDto(dto, article);
        return article;
    }

    public void updateEntityFromDto(ArticleRequestDto dto, Article article) {
        if (dto == null || article == null) return;
        article.setReference(dto.getReference());
        article.setDesignation(dto.getDesignation());
        article.setDescription(dto.getDescription());
        article.setMaison(dto.getMaison());
        article.setAnnee(dto.getAnnee());
        article.setPrixUnitaire(dto.getPrixUnitaire());
        article.setPrixCarton(dto.getPrixCarton());
        article.setQuantiteStock(dto.getQuantiteStock() != null ? dto.getQuantiteStock() : 0);
        article.setSeuilMinimum(dto.getSeuilMinimum() != null ? dto.getSeuilMinimum() : 0);
        article.setReapprovisionnementAuto(dto.getReapprovisionnementAuto() != null ? dto.getReapprovisionnementAuto() : true);
        // famille et fournisseur sont résolus dans le service
    }
}
