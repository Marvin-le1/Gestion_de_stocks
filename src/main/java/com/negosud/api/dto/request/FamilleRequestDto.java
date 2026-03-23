package com.negosud.api.dto.request;

import com.negosud.api.model.enums.TypeFamille;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FamilleRequestDto {

    @NotNull(message = "Le type de famille est obligatoire")
    private TypeFamille type;

    private String description;
}
