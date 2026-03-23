package com.negosud.api.model.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "lignes_inventaire")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = {"inventaire", "article"})
public class LigneInventaire {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Quantité constatée physiquement */
    @Column(nullable = false)
    private Integer quantiteConstatee;

    /** Quantité en base avant régularisation (snapshot) */
    @Column(nullable = false)
    private Integer quantiteAvantRegularisation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventaire_id", nullable = false)
    private Inventaire inventaire;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;
}
