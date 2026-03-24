package com.negosud.api.mapper;

import com.negosud.api.dto.response.InventaireResponseDto;
import com.negosud.api.dto.response.LigneInventaireResponseDto;
import com.negosud.api.model.entity.Inventaire;
import com.negosud.api.model.entity.LigneInventaire;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class InventaireMapper {

    private final ArticleMapper articleMapper;

    public InventaireResponseDto toResponseDto(Inventaire inventaire) {
        if (inventaire == null) return null;
        InventaireResponseDto dto = new InventaireResponseDto();
        dto.setId(inventaire.getId());
        dto.setDateInventaire(inventaire.getDateInventaire());
        dto.setCommentaire(inventaire.getCommentaire());
        dto.setRegularise(inventaire.getRegularise());
        List<LigneInventaireResponseDto> lignes = inventaire.getLignes().stream()
                .map(this::ligneToResponseDto)
                .toList();
        dto.setLignes(lignes);
        return dto;
    }

    public LigneInventaireResponseDto ligneToResponseDto(LigneInventaire ligne) {
        if (ligne == null) return null;
        LigneInventaireResponseDto dto = new LigneInventaireResponseDto();
        dto.setId(ligne.getId());
        dto.setQuantiteConstatee(ligne.getQuantiteConstatee());
        dto.setQuantiteAvantRegularisation(ligne.getQuantiteAvantRegularisation());
        dto.setEcart(ligne.getQuantiteConstatee() - ligne.getQuantiteAvantRegularisation());
        dto.setArticle(articleMapper.toResponseDto(ligne.getArticle()));
        return dto;
    }
}
