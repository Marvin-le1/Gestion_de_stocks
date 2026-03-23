package com.negosud.api.mapper;

import com.negosud.api.dto.request.FamilleRequestDto;
import com.negosud.api.dto.response.FamilleResponseDto;
import com.negosud.api.model.entity.Famille;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface FamilleMapper {

    FamilleResponseDto toResponseDto(Famille famille);

    Famille toEntity(FamilleRequestDto dto);

    void updateEntityFromDto(FamilleRequestDto dto, @MappingTarget Famille famille);
}
