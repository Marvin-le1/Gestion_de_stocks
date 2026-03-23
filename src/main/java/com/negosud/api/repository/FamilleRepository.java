package com.negosud.api.repository;

import com.negosud.api.model.entity.Famille;
import com.negosud.api.model.enums.TypeFamille;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FamilleRepository extends JpaRepository<Famille, Long> {

    Optional<Famille> findByType(TypeFamille type);

    boolean existsByType(TypeFamille type);
}
