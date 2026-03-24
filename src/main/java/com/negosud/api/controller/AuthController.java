package com.negosud.api.controller;

import com.negosud.api.dto.request.LoginRequestDto;
import com.negosud.api.dto.request.RegisterRequestDto;
import com.negosud.api.dto.response.AuthResponseDto;
import com.negosud.api.model.entity.Utilisateur;
import com.negosud.api.model.enums.Role;
import com.negosud.api.repository.UtilisateurRepository;
import com.negosud.api.security.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDto dto) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(dto.getEmail(), dto.getMotDePasse())
            );
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Email ou mot de passe incorrect");
        }

        Utilisateur user = utilisateurRepository.findByEmail(dto.getEmail()).orElseThrow();
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
        return ResponseEntity.ok(
                new AuthResponseDto(token, user.getEmail(), user.getNom(), user.getRole().name())
        );
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequestDto dto) {
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            return ResponseEntity.badRequest().body("Cet email est déjà utilisé");
        }

        Utilisateur user = new Utilisateur();
        user.setEmail(dto.getEmail());
        user.setNom(dto.getNom());
        user.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        user.setRole(Role.ADMIN);
        utilisateurRepository.save(user);

        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new AuthResponseDto(token, user.getEmail(), user.getNom(), user.getRole().name()));
    }
}
