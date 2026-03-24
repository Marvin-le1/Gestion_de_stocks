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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ClientServiceImpl implements ClientService {

    private final ClientRepository clientRepository;
    private final CommandeClientRepository commandeClientRepository;
    private final ClientMapper clientMapper;
    private final CommandeClientMapper commandeClientMapper;
    private final PasswordEncoder passwordEncoder;

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
    @Transactional(readOnly = true)
    public Optional<ClientResponseDto> findByEmail(String email) {
        return clientRepository.findByEmail(email).map(clientMapper::toResponseDto);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean hasPassword(String email) {
        return clientRepository.findByEmail(email)
                .map(c -> c.getMotDePasse() != null)
                .orElse(false);
    }

    @Override
    public ClientResponseDto loginClient(String email, String motDePasse) {
        Client client = clientRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Aucun compte trouvé pour cet email"));
        if (client.getMotDePasse() == null) {
            throw new IllegalArgumentException("Ce compte n'a pas de mot de passe défini");
        }
        if (!passwordEncoder.matches(motDePasse, client.getMotDePasse())) {
            throw new IllegalArgumentException("Mot de passe incorrect");
        }
        return clientMapper.toResponseDto(client);
    }

    @Override
    public ClientResponseDto findOrCreate(ClientRequestDto dto) {
        return clientRepository.findByEmail(dto.getEmail())
                .map(clientMapper::toResponseDto)
                .orElseGet(() -> {
                    Client client = clientMapper.toEntity(dto);
                    // Crée un mot de passe si le client souhaite un compte
                    if (dto.getMotDePasse() != null && !dto.getMotDePasse().isBlank()) {
                        client.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
                    }
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
