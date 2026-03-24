package com.negosud.api.mapper;

import com.negosud.api.dto.response.CommandeFournisseurResponseDto;
import com.negosud.api.dto.response.LigneCommandeFournisseurResponseDto;
import com.negosud.api.model.entity.CommandeFournisseur;
import com.negosud.api.model.entity.LigneCommandeFournisseur;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CommandeFournisseurMapper {

    private final FournisseurMapper fournisseurMapper;
    private final ArticleMapper articleMapper;

    public CommandeFournisseurResponseDto toResponseDto(CommandeFournisseur commande) {
        if (commande == null) return null;
        CommandeFournisseurResponseDto dto = new CommandeFournisseurResponseDto();
        dto.setId(commande.getId());
        dto.setDateCommande(commande.getDateCommande());
        dto.setStatut(commande.getStatut());
        dto.setGenereeAutomatiquement(commande.getGenereeAutomatiquement());
        dto.setCommentaire(commande.getCommentaire());
        dto.setFournisseur(fournisseurMapper.toResponseDto(commande.getFournisseur()));
        List<LigneCommandeFournisseurResponseDto> lignes = commande.getLignes().stream()
                .map(this::ligneToResponseDto)
                .toList();
        dto.setLignes(lignes);
        return dto;
    }

    public LigneCommandeFournisseurResponseDto ligneToResponseDto(LigneCommandeFournisseur ligne) {
        if (ligne == null) return null;
        LigneCommandeFournisseurResponseDto dto = new LigneCommandeFournisseurResponseDto();
        dto.setId(ligne.getId());
        dto.setQuantite(ligne.getQuantite());
        dto.setPrixUnitaire(ligne.getPrixUnitaire());
        dto.setArticle(articleMapper.toResponseDto(ligne.getArticle()));
        return dto;
    }
}
