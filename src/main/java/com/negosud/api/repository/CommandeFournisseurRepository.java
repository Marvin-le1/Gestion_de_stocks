package com.negosud.api.repository;

import com.negosud.api.model.entity.CommandeFournisseur;
import com.negosud.api.model.enums.StatutCommande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommandeFournisseurRepository extends JpaRepository<CommandeFournisseur, Long> {

    List<CommandeFournisseur> findByFournisseurId(Long fournisseurId);

    List<CommandeFournisseur> findByStatut(StatutCommande statut);
}
