package com.negosud.api.dto.response;

import com.negosud.api.model.enums.TypeFamille;
import lombok.Data;

@Data
public class FamilleResponseDto {

    private Long id;
    private TypeFamille type;
    private String description;
}
