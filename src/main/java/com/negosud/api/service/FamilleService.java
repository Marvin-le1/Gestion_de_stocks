package com.negosud.api.service;

import com.negosud.api.dto.request.FamilleRequestDto;
import com.negosud.api.dto.response.FamilleResponseDto;

import java.util.List;

public interface FamilleService {

    List<FamilleResponseDto> findAll();

    FamilleResponseDto findById(Long id);

    FamilleResponseDto create(FamilleRequestDto dto);

    FamilleResponseDto update(Long id, FamilleRequestDto dto);

    void delete(Long id);
}
