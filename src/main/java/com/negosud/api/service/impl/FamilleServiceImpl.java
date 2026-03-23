package com.negosud.api.service.impl;

import com.negosud.api.dto.request.FamilleRequestDto;
import com.negosud.api.dto.response.FamilleResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.FamilleMapper;
import com.negosud.api.model.entity.Famille;
import com.negosud.api.repository.FamilleRepository;
import com.negosud.api.service.FamilleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class FamilleServiceImpl implements FamilleService {

    private final FamilleRepository familleRepository;
    private final FamilleMapper familleMapper;

    @Override
    @Transactional(readOnly = true)
    public List<FamilleResponseDto> findAll() {
        return familleRepository.findAll().stream()
                .map(familleMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public FamilleResponseDto findById(Long id) {
        return familleMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    public FamilleResponseDto create(FamilleRequestDto dto) {
        if (familleRepository.existsByType(dto.getType())) {
            throw new IllegalArgumentException("Une famille de type " + dto.getType() + " existe déjà");
        }
        Famille famille = familleMapper.toEntity(dto);
        return familleMapper.toResponseDto(familleRepository.save(famille));
    }

    @Override
    public FamilleResponseDto update(Long id, FamilleRequestDto dto) {
        Famille famille = getOrThrow(id);
        familleMapper.updateEntityFromDto(dto, famille);
        return familleMapper.toResponseDto(familleRepository.save(famille));
    }

    @Override
    public void delete(Long id) {
        familleRepository.delete(getOrThrow(id));
    }

    private Famille getOrThrow(Long id) {
        return familleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Famille", id));
    }
}
