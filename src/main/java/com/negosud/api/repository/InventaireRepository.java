package com.negosud.api.repository;

import com.negosud.api.model.entity.Inventaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InventaireRepository extends JpaRepository<Inventaire, Long> {

    List<Inventaire> findByRegulariseOrderByDateInventaireDesc(boolean regularise);
}
