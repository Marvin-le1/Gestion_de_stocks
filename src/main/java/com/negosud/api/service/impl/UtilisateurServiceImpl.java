package com.negosud.api.service.impl;

import com.negosud.api.dto.request.UtilisateurRequestDto;
import com.negosud.api.dto.response.UtilisateurResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.model.entity.Utilisateur;
import com.negosud.api.model.enums.Role;
import com.negosud.api.repository.UtilisateurRepository;
import com.negosud.api.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class UtilisateurServiceImpl implements UtilisateurService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional(readOnly = true)
    public List<UtilisateurResponseDto> findAll() {
        return utilisateurRepository.findAll().stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public UtilisateurResponseDto create(UtilisateurRequestDto dto) {
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Un utilisateur avec l'email " + dto.getEmail() + " existe déjà");
        }

        Role role;
        try {
            role = (dto.getRole() != null && !dto.getRole().isBlank())
                    ? Role.valueOf(dto.getRole().toUpperCase())
                    : Role.EMPLOYE;
        } catch (IllegalArgumentException e) {
            role = Role.EMPLOYE;
        }

        Utilisateur user = new Utilisateur();
        user.setNom(dto.getNom());
        user.setEmail(dto.getEmail());
        user.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        user.setRole(role);

        return toDto(utilisateurRepository.save(user));
    }

    @Override
    public void delete(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", id));
        utilisateurRepository.delete(user);
    }

    private UtilisateurResponseDto toDto(Utilisateur u) {
        return new UtilisateurResponseDto(u.getId(), u.getNom(), u.getEmail(), u.getRole().name());
    }
}
