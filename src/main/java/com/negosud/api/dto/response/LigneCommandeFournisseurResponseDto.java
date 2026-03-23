package com.negosud.api.dto.response;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class LigneCommandeFournisseurResponseDto {

    private Long id;
    private Integer quantite;
    private BigDecimal prixUnitaire;
    private ArticleResponseDto article;
}
