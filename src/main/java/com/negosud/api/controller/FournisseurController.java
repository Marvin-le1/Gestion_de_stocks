package com.negosud.api.controller;

import com.negosud.api.dto.request.FournisseurRequestDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.dto.response.FournisseurResponseDto;
import com.negosud.api.service.FournisseurService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fournisseurs")
@RequiredArgsConstructor
@Tag(name = "Fournisseurs", description = "Gestion des fournisseurs")
public class FournisseurController {

    private final FournisseurService fournisseurService;

    @GetMapping
    @Operation(summary = "Lister tous les fournisseurs")
    public ResponseEntity<List<FournisseurResponseDto>> findAll() {
        return ResponseEntity.ok(fournisseurService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un fournisseur par son ID")
    public ResponseEntity<FournisseurResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(fournisseurService.findById(id));
    }

    @GetMapping("/{id}/articles")
    @Operation(summary = "Lister les articles d'un fournisseur")
    public ResponseEntity<List<ArticleResponseDto>> findArticles(@PathVariable Long id) {
        return ResponseEntity.ok(fournisseurService.findArticlesByFournisseur(id));
    }

    @PostMapping
    @Operation(summary = "Créer un nouveau fournisseur")
    public ResponseEntity<FournisseurResponseDto> create(@Valid @RequestBody FournisseurRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(fournisseurService.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un fournisseur")
    public ResponseEntity<FournisseurResponseDto> update(@PathVariable Long id,
                                                          @Valid @RequestBody FournisseurRequestDto dto) {
        return ResponseEntity.ok(fournisseurService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un fournisseur")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        fournisseurService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
