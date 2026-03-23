package com.negosud.api.dto.request;

import com.negosud.api.model.enums.StatutCommande;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StatutCommandeDto {

    @NotNull(message = "Le statut est obligatoire")
    private StatutCommande statut;
}
