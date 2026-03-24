package com.negosud.api.controller;

import com.negosud.api.dto.request.CommandeFournisseurRequestDto;
import com.negosud.api.dto.request.LigneCommandeRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeFournisseurResponseDto;
import com.negosud.api.dto.response.LigneCommandeFournisseurResponseDto;
import com.negosud.api.service.CommandeFournisseurService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/commandes-fournisseurs")
@RequiredArgsConstructor
@Tag(name = "Commandes Fournisseurs", description = "Gestion des commandes fournisseurs et réapprovisionnements")
public class CommandeFournisseurController {

    private final CommandeFournisseurService commandeFournisseurService;

    @GetMapping
    @Operation(summary = "Lister toutes les commandes fournisseurs")
    public ResponseEntity<List<CommandeFournisseurResponseDto>> findAll() {
        return ResponseEntity.ok(commandeFournisseurService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une commande fournisseur par son ID")
    public ResponseEntity<CommandeFournisseurResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(commandeFournisseurService.findById(id));
    }

    @PostMapping
    @Operation(summary = "Créer une nouvelle commande fournisseur (manuelle)")
    public ResponseEntity<CommandeFournisseurResponseDto> create(@Valid @RequestBody CommandeFournisseurRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commandeFournisseurService.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour une commande fournisseur (uniquement si EN_ATTENTE)")
    public ResponseEntity<CommandeFournisseurResponseDto> update(@PathVariable Long id,
                                                                  @Valid @RequestBody CommandeFournisseurRequestDto dto) {
        return ResponseEntity.ok(commandeFournisseurService.update(id, dto));
    }

    @PatchMapping("/{id}/statut")
    @Operation(summary = "Changer le statut d'une commande fournisseur. Passer à LIVREE met à jour le stock automatiquement.")
    public ResponseEntity<CommandeFournisseurResponseDto> changerStatut(@PathVariable Long id,
                                                                         @Valid @RequestBody StatutCommandeDto dto) {
        return ResponseEntity.ok(commandeFournisseurService.changerStatut(id, dto));
    }

    @PostMapping("/{id}/lignes")
    @Operation(summary = "Ajouter une ligne à une commande fournisseur")
    public ResponseEntity<LigneCommandeFournisseurResponseDto> ajouterLigne(@PathVariable Long id,
                                                                              @Valid @RequestBody LigneCommandeRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commandeFournisseurService.ajouterLigne(id, dto));
    }

    @DeleteMapping("/{id}/lignes/{ligneId}")
    @Operation(summary = "Supprimer une ligne d'une commande fournisseur")
    public ResponseEntity<Void> supprimerLigne(@PathVariable Long id, @PathVariable Long ligneId) {
        commandeFournisseurService.supprimerLigne(id, ligneId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer une commande fournisseur")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        commandeFournisseurService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
