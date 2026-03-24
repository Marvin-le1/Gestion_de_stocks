package com.negosud.api.dto.response;

import lombok.Data;

@Data
public class ClientResponseDto {

    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private String adresse;
    private String ville;
    private String codePostal;
    private String pays;
}
