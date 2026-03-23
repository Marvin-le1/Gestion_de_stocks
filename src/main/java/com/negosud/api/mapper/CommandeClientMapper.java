package com.negosud.api.mapper;

import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.dto.response.LigneCommandeClientResponseDto;
import com.negosud.api.model.entity.CommandeClient;
import com.negosud.api.model.entity.LigneCommandeClient;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {ClientMapper.class, ArticleMapper.class})
public interface CommandeClientMapper {

    CommandeClientResponseDto toResponseDto(CommandeClient commande);

    LigneCommandeClientResponseDto ligneToResponseDto(LigneCommandeClient ligne);
}
