package com.negosud.api.service;

import com.negosud.api.dto.request.CommandeFournisseurRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeFournisseurResponseDto;

import java.util.List;

public interface CommandeFournisseurService {

    List<CommandeFournisseurResponseDto> findAll();

    CommandeFournisseurResponseDto findById(Long id);

    CommandeFournisseurResponseDto create(CommandeFournisseurRequestDto dto);

    CommandeFournisseurResponseDto update(Long id, CommandeFournisseurRequestDto dto);

    /**
     * Change le statut de la commande.
     * Si le statut passe à LIVREE, le stock des articles est mis à jour automatiquement.
     */
    CommandeFournisseurResponseDto changerStatut(Long id, StatutCommandeDto dto);

    void delete(Long id);

    /**
     * Crée automatiquement une commande fournisseur de réapprovisionnement pour un article
     * dont le stock est passé sous le seuil minimum.
     */
    void creerReapprovisionnementAuto(com.negosud.api.model.entity.Article article);
}
