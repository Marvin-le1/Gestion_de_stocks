package com.negosud.api.mapper;

import com.negosud.api.dto.response.InventaireResponseDto;
import com.negosud.api.dto.response.LigneInventaireResponseDto;
import com.negosud.api.model.entity.Inventaire;
import com.negosud.api.model.entity.LigneInventaire;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {ArticleMapper.class})
public interface InventaireMapper {

    InventaireResponseDto toResponseDto(Inventaire inventaire);

    @Mapping(target = "ecart", expression = "java(ligne.getQuantiteConstatee() - ligne.getQuantiteAvantRegularisation())")
    LigneInventaireResponseDto ligneToResponseDto(LigneInventaire ligne);
}
