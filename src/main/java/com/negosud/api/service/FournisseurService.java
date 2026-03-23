package com.negosud.api.service;

import com.negosud.api.dto.request.FournisseurRequestDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.dto.response.FournisseurResponseDto;

import java.util.List;

public interface FournisseurService {

    List<FournisseurResponseDto> findAll();

    FournisseurResponseDto findById(Long id);

    List<ArticleResponseDto> findArticlesByFournisseur(Long id);

    FournisseurResponseDto create(FournisseurRequestDto dto);

    FournisseurResponseDto update(Long id, FournisseurRequestDto dto);

    void delete(Long id);
}
