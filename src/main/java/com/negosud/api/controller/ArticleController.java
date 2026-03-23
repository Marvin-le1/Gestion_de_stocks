package com.negosud.api.controller;

import com.negosud.api.dto.request.ArticleRequestDto;
import com.negosud.api.dto.request.ReapprovisionnementDto;
import com.negosud.api.dto.request.StockAjustementDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.service.ArticleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/articles")
@RequiredArgsConstructor
@Tag(name = "Articles", description = "Gestion du catalogue et des stocks")
public class ArticleController {

    private final ArticleService articleService;

    @GetMapping
    @Operation(summary = "Lister tous les articles")
    public ResponseEntity<List<ArticleResponseDto>> findAll() {
        return ResponseEntity.ok(articleService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un article par son ID")
    public ResponseEntity<ArticleResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(articleService.findById(id));
    }

    @GetMapping("/famille/{familleId}")
    @Operation(summary = "Lister les articles par famille")
    public ResponseEntity<List<ArticleResponseDto>> findByFamille(@PathVariable Long familleId) {
        return ResponseEntity.ok(articleService.findByFamille(familleId));
    }

    @GetMapping("/fournisseur/{fournisseurId}")
    @Operation(summary = "Lister les articles par fournisseur")
    public ResponseEntity<List<ArticleResponseDto>> findByFournisseur(@PathVariable Long fournisseurId) {
        return ResponseEntity.ok(articleService.findByFournisseur(fournisseurId));
    }

    @PostMapping
    @Operation(summary = "Créer un nouvel article")
    public ResponseEntity<ArticleResponseDto> create(@Valid @RequestBody ArticleRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(articleService.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un article")
    public ResponseEntity<ArticleResponseDto> update(@PathVariable Long id,
                                                      @Valid @RequestBody ArticleRequestDto dto) {
        return ResponseEntity.ok(articleService.update(id, dto));
    }

    @PatchMapping("/{id}/stock")
    @Operation(summary = "Ajuster le stock d'un article (quantité positive ou négative)")
    public ResponseEntity<ArticleResponseDto> ajusterStock(@PathVariable Long id,
                                                            @Valid @RequestBody StockAjustementDto dto) {
        return ResponseEntity.ok(articleService.ajusterStock(id, dto));
    }

    @PatchMapping("/{id}/reapprovisionnement")
    @Operation(summary = "Activer ou désactiver le réapprovisionnement automatique")
    public ResponseEntity<ArticleResponseDto> toggleReapprovisionnement(@PathVariable Long id,
                                                                         @Valid @RequestBody ReapprovisionnementDto dto) {
        return ResponseEntity.ok(articleService.toggleReapprovisionnement(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un article")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        articleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
