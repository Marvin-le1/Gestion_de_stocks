package com.negosud.api.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "articles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = {"famille", "fournisseur", "lignesCommandeClient", "lignesCommandeFournisseur"})
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String reference;

    @Column(nullable = false)
    private String designation;

    private String description;

    /** Domaine viticole / maison productrice */
    private String maison;

    /** Millésime */
    private Integer annee;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal prixUnitaire;

    @Column(precision = 10, scale = 2)
    private BigDecimal prixCarton;

    /** Nombre de bouteilles en stock */
    @Column(nullable = false)
    private Integer quantiteStock = 0;

    /** Seuil en dessous duquel un réappro est déclenché */
    @Column(nullable = false)
    private Integer seuilMinimum = 0;

    /** Si false, aucun réappro automatique ne sera généré */
    @Column(nullable = false)
    private Boolean reapprovisionnementAuto = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "famille_id", nullable = false)
    private Famille famille;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fournisseur_id", nullable = false)
    private Fournisseur fournisseur;

    @OneToMany(mappedBy = "article", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<LigneCommandeClient> lignesCommandeClient = new ArrayList<>();

    @OneToMany(mappedBy = "article", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<LigneCommandeFournisseur> lignesCommandeFournisseur = new ArrayList<>();
}
