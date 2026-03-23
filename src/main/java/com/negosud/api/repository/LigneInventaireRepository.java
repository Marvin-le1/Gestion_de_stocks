package com.negosud.api.repository;

import com.negosud.api.model.entity.LigneInventaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LigneInventaireRepository extends JpaRepository<LigneInventaire, Long> {

    List<LigneInventaire> findByInventaireId(Long inventaireId);
}
