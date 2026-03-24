package com.negosud.api.controller;

import com.negosud.api.dto.request.UtilisateurRequestDto;
import com.negosud.api.dto.response.UtilisateurResponseDto;
import com.negosud.api.service.UtilisateurService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/utilisateurs")
@RequiredArgsConstructor
@Tag(name = "Utilisateurs", description = "Gestion des comptes utilisateurs (admin uniquement)")
public class UtilisateurController {

    private final UtilisateurService utilisateurService;

    @GetMapping
    @Operation(summary = "Lister tous les utilisateurs")
    public ResponseEntity<List<UtilisateurResponseDto>> findAll() {
        return ResponseEntity.ok(utilisateurService.findAll());
    }

    @PostMapping
    @Operation(summary = "Créer un nouvel utilisateur (ADMIN ou EMPLOYE)")
    public ResponseEntity<UtilisateurResponseDto> create(@Valid @RequestBody UtilisateurRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(utilisateurService.create(dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un utilisateur")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        utilisateurService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
