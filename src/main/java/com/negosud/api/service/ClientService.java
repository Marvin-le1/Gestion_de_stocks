package com.negosud.api.service;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;

import java.util.List;

public interface ClientService {

    List<ClientResponseDto> findAll();

    ClientResponseDto findById(Long id);

    List<CommandeClientResponseDto> findCommandesByClient(Long id);

    ClientResponseDto findOrCreate(ClientRequestDto dto);

    ClientResponseDto create(ClientRequestDto dto);

    ClientResponseDto update(Long id, ClientRequestDto dto);

    void delete(Long id);
}
