package com.negosud.api.mapper;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.model.entity.Client;
import org.springframework.stereotype.Component;

@Component
public class ClientMapper {

    public ClientResponseDto toResponseDto(Client client) {
        if (client == null) return null;
        ClientResponseDto dto = new ClientResponseDto();
        dto.setId(client.getId());
        dto.setNom(client.getNom());
        dto.setPrenom(client.getPrenom());
        dto.setEmail(client.getEmail());
        dto.setTelephone(client.getTelephone());
        dto.setAdresse(client.getAdresse());
        dto.setVille(client.getVille());
        dto.setCodePostal(client.getCodePostal());
        dto.setPays(client.getPays());
        return dto;
    }

    public Client toEntity(ClientRequestDto dto) {
        if (dto == null) return null;
        Client client = new Client();
        updateEntityFromDto(dto, client);
        return client;
    }

    public void updateEntityFromDto(ClientRequestDto dto, Client client) {
        if (dto == null || client == null) return;
        client.setNom(dto.getNom());
        client.setPrenom(dto.getPrenom());
        client.setEmail(dto.getEmail());
        client.setTelephone(dto.getTelephone());
        client.setAdresse(dto.getAdresse());
        client.setVille(dto.getVille());
        client.setCodePostal(dto.getCodePostal());
        client.setPays(dto.getPays());
    }
}
