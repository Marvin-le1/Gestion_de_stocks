package com.negosud.api.dto.request;

import jakarta.validation.Valid;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class InventaireRequestDto {

    private String commentaire;

    @Valid
    private List<LigneInventaireRequestDto> lignes = new ArrayList<>();
}
