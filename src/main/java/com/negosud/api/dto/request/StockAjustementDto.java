package com.negosud.api.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StockAjustementDto {

    /**
     * Quantité à ajouter (positif) ou retirer (négatif) du stock.
     * Exemple : -1 pour vendre une bouteille, +12 pour en recevoir un carton.
     */
    @NotNull(message = "La quantité est obligatoire")
    private Integer quantite;
}
