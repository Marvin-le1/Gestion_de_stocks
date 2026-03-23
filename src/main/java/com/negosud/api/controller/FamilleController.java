package com.negosud.api.controller;

import com.negosud.api.dto.request.FamilleRequestDto;
import com.negosud.api.dto.response.FamilleResponseDto;
import com.negosud.api.service.FamilleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/familles")
@RequiredArgsConstructor
@Tag(name = "Familles", description = "Gestion des familles de vins")
public class FamilleController {

    private final FamilleService familleService;

    @GetMapping
    @Operation(summary = "Lister toutes les familles")
    public ResponseEntity<List<FamilleResponseDto>> findAll() {
        return ResponseEntity.ok(familleService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une famille par son ID")
    public ResponseEntity<FamilleResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(familleService.findById(id));
    }

    @PostMapping
    @Operation(summary = "Créer une nouvelle famille")
    public ResponseEntity<FamilleResponseDto> create(@Valid @RequestBody FamilleRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(familleService.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour une famille")
    public ResponseEntity<FamilleResponseDto> update(@PathVariable Long id,
                                                      @Valid @RequestBody FamilleRequestDto dto) {
        return ResponseEntity.ok(familleService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer une famille")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        familleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
