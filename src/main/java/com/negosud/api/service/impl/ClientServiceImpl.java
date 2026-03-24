package com.negosud.api.service.impl;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.ClientMapper;
import com.negosud.api.mapper.CommandeClientMapper;
import com.negosud.api.model.entity.Client;
import com.negosud.api.repository.ClientRepository;
import com.negosud.api.repository.CommandeClientRepository;
import com.negosud.api.service.ClientService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ClientServiceImpl implements ClientService {

    private final ClientRepository clientRepository;
    private final CommandeClientRepository commandeClientRepository;
    private final ClientMapper clientMapper;
    private final CommandeClientMapper commandeClientMapper;

    @Override
    @Transactional(readOnly = true)
    public List<ClientResponseDto> findAll() {
        return clientRepository.findAll().stream()
                .map(clientMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ClientResponseDto findById(Long id) {
        return clientMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<CommandeClientResponseDto> findCommandesByClient(Long id) {
        getOrThrow(id);
        return commandeClientRepository.findByClientId(id).stream()
                .map(commandeClientMapper::toResponseDto)
                .toList();
    }

    @Override
    public ClientResponseDto findOrCreate(ClientRequestDto dto) {
        return clientRepository.findByEmail(dto.getEmail())
                .map(clientMapper::toResponseDto)
                .orElseGet(() -> {
                    Client client = clientMapper.toEntity(dto);
                    return clientMapper.toResponseDto(clientRepository.save(client));
                });
    }

    @Override
    public ClientResponseDto create(ClientRequestDto dto) {
        if (clientRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Un client avec l'email " + dto.getEmail() + " existe déjà");
        }
        Client client = clientMapper.toEntity(dto);
        return clientMapper.toResponseDto(clientRepository.save(client));
    }

    @Override
    public ClientResponseDto update(Long id, ClientRequestDto dto) {
        Client client = getOrThrow(id);
        clientMapper.updateEntityFromDto(dto, client);
        return clientMapper.toResponseDto(clientRepository.save(client));
    }

    @Override
    public void delete(Long id) {
        clientRepository.delete(getOrThrow(id));
    }

    private Client getOrThrow(Long id) {
        return clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client", id));
    }
}
