package com.negosud.api.service;

import com.negosud.api.dto.request.CommandeClientRequestDto;
import com.negosud.api.dto.request.LigneCommandeRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.dto.response.LigneCommandeClientResponseDto;

import java.util.List;

public interface CommandeClientService {

    List<CommandeClientResponseDto> findAll();

    CommandeClientResponseDto findById(Long id);

    List<LigneCommandeClientResponseDto> findLignesByCommande(Long id);

    CommandeClientResponseDto create(CommandeClientRequestDto dto);

    CommandeClientResponseDto update(Long id, CommandeClientRequestDto dto);

    CommandeClientResponseDto changerStatut(Long id, StatutCommandeDto dto);

    LigneCommandeClientResponseDto ajouterLigne(Long id, LigneCommandeRequestDto dto);

    void supprimerLigne(Long commandeId, Long ligneId);

    void delete(Long id);
}
