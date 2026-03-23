package com.negosud.api.service;

import com.negosud.api.dto.request.ArticleRequestDto;
import com.negosud.api.dto.request.ReapprovisionnementDto;
import com.negosud.api.dto.request.StockAjustementDto;
import com.negosud.api.dto.response.ArticleResponseDto;

import java.util.List;

public interface ArticleService {

    List<ArticleResponseDto> findAll();

    List<ArticleResponseDto> findByFamille(Long familleId);

    List<ArticleResponseDto> findByFournisseur(Long fournisseurId);

    ArticleResponseDto findById(Long id);

    ArticleResponseDto create(ArticleRequestDto dto);

    ArticleResponseDto update(Long id, ArticleRequestDto dto);

    ArticleResponseDto ajusterStock(Long id, StockAjustementDto dto);

    ArticleResponseDto toggleReapprovisionnement(Long id, ReapprovisionnementDto dto);

    void delete(Long id);
}
