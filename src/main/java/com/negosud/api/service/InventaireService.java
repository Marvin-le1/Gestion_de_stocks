package com.negosud.api.service;

import com.negosud.api.dto.request.InventaireRequestDto;
import com.negosud.api.dto.response.InventaireResponseDto;

import java.util.List;

public interface InventaireService {

    List<InventaireResponseDto> findAll();

    InventaireResponseDto findById(Long id);

    InventaireResponseDto create(InventaireRequestDto dto);

    /**
     * Applique les quantités constatées comme nouvelles quantités en stock.
     * Un inventaire ne peut être régularisé qu'une seule fois.
     */
    InventaireResponseDto regulariser(Long id);
}
