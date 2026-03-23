package com.negosud.api.dto.response;

import com.negosud.api.model.enums.StatutCommande;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CommandeFournisseurResponseDto {

    private Long id;
    private LocalDateTime dateCommande;
    private StatutCommande statut;
    private Boolean genereeAutomatiquement;
    private String commentaire;
    private FournisseurResponseDto fournisseur;
    private List<LigneCommandeFournisseurResponseDto> lignes;
}
