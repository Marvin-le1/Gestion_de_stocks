package com.negosud.api.mapper;

import com.negosud.api.dto.request.FournisseurRequestDto;
import com.negosud.api.dto.response.FournisseurResponseDto;
import com.negosud.api.model.entity.Fournisseur;
import org.springframework.stereotype.Component;

@Component
public class FournisseurMapper {

    public FournisseurResponseDto toResponseDto(Fournisseur fournisseur) {
        if (fournisseur == null) return null;
        FournisseurResponseDto dto = new FournisseurResponseDto();
        dto.setId(fournisseur.getId());
        dto.setNom(fournisseur.getNom());
        dto.setAdresse(fournisseur.getAdresse());
        dto.setVille(fournisseur.getVille());
        dto.setCodePostal(fournisseur.getCodePostal());
        dto.setTelephone(fournisseur.getTelephone());
        dto.setEmail(fournisseur.getEmail());
        dto.setContactNom(fournisseur.getContactNom());
        return dto;
    }

    public Fournisseur toEntity(FournisseurRequestDto dto) {
        if (dto == null) return null;
        Fournisseur fournisseur = new Fournisseur();
        updateEntityFromDto(dto, fournisseur);
        return fournisseur;
    }

    public void updateEntityFromDto(FournisseurRequestDto dto, Fournisseur fournisseur) {
        if (dto == null || fournisseur == null) return;
        fournisseur.setNom(dto.getNom());
        fournisseur.setAdresse(dto.getAdresse());
        fournisseur.setVille(dto.getVille());
        fournisseur.setCodePostal(dto.getCodePostal());
        fournisseur.setTelephone(dto.getTelephone());
        fournisseur.setEmail(dto.getEmail());
        fournisseur.setContactNom(dto.getContactNom());
    }
}
