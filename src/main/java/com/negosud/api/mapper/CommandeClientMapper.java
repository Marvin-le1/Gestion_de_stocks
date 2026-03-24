package com.negosud.api.mapper;

import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.dto.response.LigneCommandeClientResponseDto;
import com.negosud.api.model.entity.CommandeClient;
import com.negosud.api.model.entity.LigneCommandeClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CommandeClientMapper {

    private final ClientMapper clientMapper;
    private final ArticleMapper articleMapper;

    public CommandeClientResponseDto toResponseDto(CommandeClient commande) {
        if (commande == null) return null;
        CommandeClientResponseDto dto = new CommandeClientResponseDto();
        dto.setId(commande.getId());
        dto.setDateCommande(commande.getDateCommande());
        dto.setStatut(commande.getStatut());
        dto.setCommentaire(commande.getCommentaire());
        dto.setClient(clientMapper.toResponseDto(commande.getClient()));
        List<LigneCommandeClientResponseDto> lignes = commande.getLignes().stream()
                .map(this::ligneToResponseDto)
                .toList();
        dto.setLignes(lignes);
        return dto;
    }

    public LigneCommandeClientResponseDto ligneToResponseDto(LigneCommandeClient ligne) {
        if (ligne == null) return null;
        LigneCommandeClientResponseDto dto = new LigneCommandeClientResponseDto();
        dto.setId(ligne.getId());
        dto.setQuantite(ligne.getQuantite());
        dto.setPrixUnitaire(ligne.getPrixUnitaire());
        dto.setArticle(articleMapper.toResponseDto(ligne.getArticle()));
        return dto;
    }
}
