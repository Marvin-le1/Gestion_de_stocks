package com.negosud.api.repository;

import com.negosud.api.model.entity.Article;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {

    Optional<Article> findByReference(String reference);

    List<Article> findByFamilleId(Long familleId);

    List<Article> findByFournisseurId(Long fournisseurId);

    List<Article> findByDesignationContainingIgnoreCase(String designation);

    /** Articles dont le stock est sous ou égal au seuil minimum avec réappro auto activé */
    @Query("SELECT a FROM Article a WHERE a.quantiteStock <= a.seuilMinimum AND a.reapprovisionnementAuto = true")
    List<Article> findArticlesAReapprovisionner();
}
