package com.negosud.api.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class CommandeClientRequestDto {

    @NotNull(message = "Le client est obligatoire")
    private Long clientId;

    private String commentaire;

    @Valid
    private List<LigneCommandeRequestDto> lignes = new ArrayList<>();
}
