package com.negosud.api.mapper;

import com.negosud.api.dto.response.CommandeFournisseurResponseDto;
import com.negosud.api.dto.response.LigneCommandeFournisseurResponseDto;
import com.negosud.api.model.entity.CommandeFournisseur;
import com.negosud.api.model.entity.LigneCommandeFournisseur;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {FournisseurMapper.class, ArticleMapper.class})
public interface CommandeFournisseurMapper {

    CommandeFournisseurResponseDto toResponseDto(CommandeFournisseur commande);

    LigneCommandeFournisseurResponseDto ligneToResponseDto(LigneCommandeFournisseur ligne);
}
