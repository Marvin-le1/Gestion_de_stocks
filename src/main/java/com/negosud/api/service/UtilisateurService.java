package com.negosud.api.service;

import com.negosud.api.dto.request.UtilisateurRequestDto;
import com.negosud.api.dto.response.UtilisateurResponseDto;

import java.util.List;

public interface UtilisateurService {

    List<UtilisateurResponseDto> findAll();

    UtilisateurResponseDto create(UtilisateurRequestDto dto);

    void delete(Long id);
}
