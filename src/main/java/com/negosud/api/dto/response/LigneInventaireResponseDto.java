package com.negosud.api.dto.response;

import lombok.Data;

@Data
public class LigneInventaireResponseDto {

    private Long id;
    private Integer quantiteConstatee;
    private Integer quantiteAvantRegularisation;
    private Integer ecart;
    private ArticleResponseDto article;
}
