package com.negosud.api.repository;

import com.negosud.api.model.entity.CommandeClient;
import com.negosud.api.model.enums.StatutCommande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommandeClientRepository extends JpaRepository<CommandeClient, Long> {

    List<CommandeClient> findByClientId(Long clientId);

    List<CommandeClient> findByStatut(StatutCommande statut);
}
