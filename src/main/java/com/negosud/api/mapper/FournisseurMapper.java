package com.negosud.api.mapper;

import com.negosud.api.dto.request.FournisseurRequestDto;
import com.negosud.api.dto.response.FournisseurResponseDto;
import com.negosud.api.model.entity.Fournisseur;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface FournisseurMapper {

    FournisseurResponseDto toResponseDto(Fournisseur fournisseur);

    Fournisseur toEntity(FournisseurRequestDto dto);

    void updateEntityFromDto(FournisseurRequestDto dto, @MappingTarget Fournisseur fournisseur);
}
