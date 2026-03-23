package com.negosud.api.dto.response;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArticleResponseDto {

    private Long id;
    private String reference;
    private String designation;
    private String description;
    private String maison;
    private Integer annee;
    private BigDecimal prixUnitaire;
    private BigDecimal prixCarton;
    private Integer quantiteStock;
    private Integer seuilMinimum;
    private Boolean reapprovisionnementAuto;
    private FamilleResponseDto famille;
    private FournisseurResponseDto fournisseur;
}
