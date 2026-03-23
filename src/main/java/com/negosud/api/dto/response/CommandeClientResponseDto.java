package com.negosud.api.dto.response;

import com.negosud.api.model.enums.StatutCommande;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CommandeClientResponseDto {

    private Long id;
    private LocalDateTime dateCommande;
    private StatutCommande statut;
    private String commentaire;
    private ClientResponseDto client;
    private List<LigneCommandeClientResponseDto> lignes;
}
