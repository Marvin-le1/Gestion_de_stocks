package com.negosud.api.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReapprovisionnementDto {

    @NotNull(message = "La valeur est obligatoire")
    private Boolean actif;
}
