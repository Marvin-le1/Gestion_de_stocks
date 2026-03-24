package com.negosud.api.service;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;

import java.util.List;
import java.util.Optional;

public interface ClientService {

    List<ClientResponseDto> findAll();

    ClientResponseDto findById(Long id);

    List<CommandeClientResponseDto> findCommandesByClient(Long id);

    /** Cherche le client par email sans vérification de mot de passe (boutique) */
    Optional<ClientResponseDto> findByEmail(String email);

    /** Indique si un client possède déjà un mot de passe */
    boolean hasPassword(String email);

    /** Connexion boutique — vérifie email + mot de passe, retourne le client */
    ClientResponseDto loginClient(String email, String motDePasse);

    ClientResponseDto findOrCreate(ClientRequestDto dto);

    ClientResponseDto create(ClientRequestDto dto);

    ClientResponseDto update(Long id, ClientRequestDto dto);

    void delete(Long id);
}
