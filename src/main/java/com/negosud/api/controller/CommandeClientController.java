package com.negosud.api.controller;

import com.negosud.api.dto.request.CommandeClientRequestDto;
import com.negosud.api.dto.request.LigneCommandeRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.dto.response.LigneCommandeClientResponseDto;
import com.negosud.api.service.CommandeClientService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/commandes-clients")
@RequiredArgsConstructor
@Tag(name = "Commandes Clients", description = "Gestion des commandes clients")
public class CommandeClientController {

    private final CommandeClientService commandeClientService;

    @GetMapping
    @Operation(summary = "Lister toutes les commandes clients")
    public ResponseEntity<List<CommandeClientResponseDto>> findAll() {
        return ResponseEntity.ok(commandeClientService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une commande client par son ID")
    public ResponseEntity<CommandeClientResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(commandeClientService.findById(id));
    }

    @GetMapping("/{id}/lignes")
    @Operation(summary = "Lister les lignes d'une commande client")
    public ResponseEntity<List<LigneCommandeClientResponseDto>> findLignes(@PathVariable Long id) {
        return ResponseEntity.ok(commandeClientService.findLignesByCommande(id));
    }

    @PostMapping
    @Operation(summary = "Créer une nouvelle commande client")
    public ResponseEntity<CommandeClientResponseDto> create(@Valid @RequestBody CommandeClientRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commandeClientService.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour une commande client (uniquement si EN_ATTENTE)")
    public ResponseEntity<CommandeClientResponseDto> update(@PathVariable Long id,
                                                             @Valid @RequestBody CommandeClientRequestDto dto) {
        return ResponseEntity.ok(commandeClientService.update(id, dto));
    }

    @PatchMapping("/{id}/statut")
    @Operation(summary = "Changer le statut d'une commande client")
    public ResponseEntity<CommandeClientResponseDto> changerStatut(@PathVariable Long id,
                                                                    @Valid @RequestBody StatutCommandeDto dto) {
        return ResponseEntity.ok(commandeClientService.changerStatut(id, dto));
    }

    @PostMapping("/{id}/lignes")
    @Operation(summary = "Ajouter une ligne à une commande client")
    public ResponseEntity<LigneCommandeClientResponseDto> ajouterLigne(@PathVariable Long id,
                                                                        @Valid @RequestBody LigneCommandeRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(commandeClientService.ajouterLigne(id, dto));
    }

    @DeleteMapping("/{id}/lignes/{ligneId}")
    @Operation(summary = "Supprimer une ligne d'une commande client")
    public ResponseEntity<Void> supprimerLigne(@PathVariable Long id, @PathVariable Long ligneId) {
        commandeClientService.supprimerLigne(id, ligneId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer une commande client")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        commandeClientService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
