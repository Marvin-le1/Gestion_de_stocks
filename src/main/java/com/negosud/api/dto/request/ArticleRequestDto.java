package com.negosud.api.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ArticleRequestDto {

    @NotBlank(message = "La référence est obligatoire")
    private String reference;

    @NotBlank(message = "La désignation est obligatoire")
    private String designation;

    private String description;
    private String maison;
    private Integer annee;

    @NotNull(message = "Le prix unitaire est obligatoire")
    @DecimalMin(value = "0.0", inclusive = false, message = "Le prix doit être positif")
    private BigDecimal prixUnitaire;

    private BigDecimal prixCarton;

    @Min(value = 0, message = "Le stock ne peut pas être négatif")
    private Integer quantiteStock = 0;

    @Min(value = 0, message = "Le seuil minimum ne peut pas être négatif")
    private Integer seuilMinimum = 0;

    private Boolean reapprovisionnementAuto = true;

    @NotNull(message = "La famille est obligatoire")
    private Long familleId;

    @NotNull(message = "Le fournisseur est obligatoire")
    private Long fournisseurId;
}
