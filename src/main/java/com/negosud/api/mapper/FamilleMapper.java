package com.negosud.api.mapper;

import com.negosud.api.dto.request.FamilleRequestDto;
import com.negosud.api.dto.response.FamilleResponseDto;
import com.negosud.api.model.entity.Famille;
import org.springframework.stereotype.Component;

@Component
public class FamilleMapper {

    public FamilleResponseDto toResponseDto(Famille famille) {
        if (famille == null) return null;
        FamilleResponseDto dto = new FamilleResponseDto();
        dto.setId(famille.getId());
        dto.setType(famille.getType());
        dto.setDescription(famille.getDescription());
        return dto;
    }

    public Famille toEntity(FamilleRequestDto dto) {
        if (dto == null) return null;
        Famille famille = new Famille();
        famille.setType(dto.getType());
        famille.setDescription(dto.getDescription());
        return famille;
    }

    public void updateEntityFromDto(FamilleRequestDto dto, Famille famille) {
        if (dto == null || famille == null) return;
        famille.setType(dto.getType());
        famille.setDescription(dto.getDescription());
    }
}
