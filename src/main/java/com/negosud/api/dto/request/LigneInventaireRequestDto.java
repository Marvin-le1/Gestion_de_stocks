package com.negosud.api.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LigneInventaireRequestDto {

    @NotNull(message = "L'article est obligatoire")
    private Long articleId;

    @NotNull(message = "La quantité constatée est obligatoire")
    @Min(value = 0, message = "La quantité constatée ne peut pas être négative")
    private Integer quantiteConstatee;
}
