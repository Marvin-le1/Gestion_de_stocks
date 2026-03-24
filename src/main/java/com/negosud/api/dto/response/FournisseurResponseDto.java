package com.negosud.api.dto.response;

import lombok.Data;

@Data
public class FournisseurResponseDto {

    private Long id;
    private String nom;
    private String adresse;
    private String ville;
    private String codePostal;
    private String pays;
    private String telephone;
    private String email;
    private String contactNom;
}
