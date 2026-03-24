package com.negosud.api.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class FournisseurRequestDto {

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    private String adresse;
    private String ville;
    private String codePostal;
    private String pays;
    private String telephone;

    @Email(message = "Email invalide")
    private String email;

    private String contactNom;
}
