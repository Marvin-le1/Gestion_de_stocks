package com.negosud.api.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "inventaires")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "lignes")
public class Inventaire {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime dateInventaire = LocalDateTime.now();

    private String commentaire;

    /** True si la régularisation des stocks a été appliquée */
    @Column(nullable = false)
    private Boolean regularise = false;

    @OneToMany(mappedBy = "inventaire", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<LigneInventaire> lignes = new ArrayList<>();
}
