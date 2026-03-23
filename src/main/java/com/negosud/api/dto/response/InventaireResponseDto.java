package com.negosud.api.dto.response;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class InventaireResponseDto {

    private Long id;
    private LocalDateTime dateInventaire;
    private String commentaire;
    private Boolean regularise;
    private List<LigneInventaireResponseDto> lignes;
}
