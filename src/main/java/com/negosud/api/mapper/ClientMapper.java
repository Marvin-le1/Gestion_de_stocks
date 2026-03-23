package com.negosud.api.mapper;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.model.entity.Client;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface ClientMapper {

    ClientResponseDto toResponseDto(Client client);

    Client toEntity(ClientRequestDto dto);

    void updateEntityFromDto(ClientRequestDto dto, @MappingTarget Client client);
}
