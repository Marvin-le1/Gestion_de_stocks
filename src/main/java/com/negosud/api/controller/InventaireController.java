package com.negosud.api.controller;

import com.negosud.api.dto.request.InventaireRequestDto;
import com.negosud.api.dto.response.InventaireResponseDto;
import com.negosud.api.service.InventaireService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventaires")
@RequiredArgsConstructor
@Tag(name = "Inventaires", description = "Gestion des inventaires et régularisation de stock")
public class InventaireController {

    private final InventaireService inventaireService;

    @GetMapping
    @Operation(summary = "Lister tous les inventaires")
    public ResponseEntity<List<InventaireResponseDto>> findAll() {
        return ResponseEntity.ok(inventaireService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un inventaire par son ID")
    public ResponseEntity<InventaireResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(inventaireService.findById(id));
    }

    @PostMapping
    @Operation(summary = "Créer un nouvel inventaire (saisie des quantités constatées)")
    public ResponseEntity<InventaireResponseDto> create(@Valid @RequestBody InventaireRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(inventaireService.create(dto));
    }

    @PostMapping("/{id}/regulariser")
    @Operation(summary = "Régulariser le stock : applique les quantités constatées comme quantités réelles. Action irréversible.")
    public ResponseEntity<InventaireResponseDto> regulariser(@PathVariable Long id) {
        return ResponseEntity.ok(inventaireService.regulariser(id));
    }
}
