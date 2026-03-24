package com.negosud.api.controller;

import com.negosud.api.dto.request.ClientRequestDto;
import com.negosud.api.dto.response.ClientResponseDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.service.ClientService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/clients")
@RequiredArgsConstructor
@Tag(name = "Clients", description = "Gestion des clients")
public class ClientController {

    private final ClientService clientService;

    @GetMapping
    @Operation(summary = "Lister tous les clients")
    public ResponseEntity<List<ClientResponseDto>> findAll() {
        return ResponseEntity.ok(clientService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir un client par son ID")
    public ResponseEntity<ClientResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(clientService.findById(id));
    }

    @GetMapping("/{id}/commandes")
    @Operation(summary = "Lister les commandes d'un client")
    public ResponseEntity<List<CommandeClientResponseDto>> findCommandes(@PathVariable Long id) {
        return ResponseEntity.ok(clientService.findCommandesByClient(id));
    }

    @PostMapping
    @Operation(summary = "Créer un nouveau client")
    public ResponseEntity<ClientResponseDto> create(@Valid @RequestBody ClientRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(clientService.create(dto));
    }

    @GetMapping("/by-email")
    @Operation(summary = "Trouver un client par email — pré-remplissage boutique")
    public ResponseEntity<ClientResponseDto> findByEmail(@RequestParam String email) {
        return clientService.findByEmail(email)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/login")
    @Operation(summary = "Connexion client boutique (email + mot de passe)")
    public ResponseEntity<?> loginClient(@RequestBody Map<String, String> body) {
        try {
            ClientResponseDto client = clientService.loginClient(body.get("email"), body.get("motDePasse"));
            return ResponseEntity.ok(client);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        }
    }

    @GetMapping("/has-password")
    @Operation(summary = "Vérifier si un client a un mot de passe (boutique)")
    public ResponseEntity<Map<String, Object>> hasPassword(@RequestParam String email) {
        boolean exists = clientService.findByEmail(email).isPresent();
        boolean hasPassword = clientService.hasPassword(email);
        return ResponseEntity.ok(Map.of("exists", exists, "hasPassword", hasPassword));
    }

    @PostMapping("/find-or-create")
    @Operation(summary = "Trouver un client par email ou le créer s'il n'existe pas (boutique)")
    public ResponseEntity<ClientResponseDto> findOrCreate(@Valid @RequestBody ClientRequestDto dto) {
        return ResponseEntity.ok(clientService.findOrCreate(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Mettre à jour un client")
    public ResponseEntity<ClientResponseDto> update(@PathVariable Long id,
                                                     @Valid @RequestBody ClientRequestDto dto) {
        return ResponseEntity.ok(clientService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un client")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        clientService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
