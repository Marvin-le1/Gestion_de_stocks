package com.negosud.api.service.impl;

import com.negosud.api.dto.request.CommandeFournisseurRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeFournisseurResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.CommandeFournisseurMapper;
import com.negosud.api.model.entity.*;
import com.negosud.api.model.enums.StatutCommande;
import com.negosud.api.repository.*;
import com.negosud.api.service.CommandeFournisseurService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CommandeFournisseurServiceImpl implements CommandeFournisseurService {

    private final CommandeFournisseurRepository commandeFournisseurRepository;
    private final LigneCommandeFournisseurRepository ligneCommandeFournisseurRepository;
    private final FournisseurRepository fournisseurRepository;
    private final ArticleRepository articleRepository;
    private final CommandeFournisseurMapper commandeFournisseurMapper;

    @Override
    @Transactional(readOnly = true)
    public List<CommandeFournisseurResponseDto> findAll() {
        return commandeFournisseurRepository.findAll().stream()
                .map(commandeFournisseurMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CommandeFournisseurResponseDto findById(Long id) {
        return commandeFournisseurMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    public CommandeFournisseurResponseDto create(CommandeFournisseurRequestDto dto) {
        Fournisseur fournisseur = fournisseurRepository.findById(dto.getFournisseurId())
                .orElseThrow(() -> new ResourceNotFoundException("Fournisseur", dto.getFournisseurId()));

        CommandeFournisseur commande = new CommandeFournisseur();
        commande.setFournisseur(fournisseur);
        commande.setCommentaire(dto.getCommentaire());
        commande.setStatut(StatutCommande.EN_ATTENTE);
        commande.setGenereeAutomatiquement(false);

        for (var ligneDto : dto.getLignes()) {
            Article article = articleRepository.findById(ligneDto.getArticleId())
                    .orElseThrow(() -> new ResourceNotFoundException("Article", ligneDto.getArticleId()));
            LigneCommandeFournisseur ligne = new LigneCommandeFournisseur();
            ligne.setArticle(article);
            ligne.setQuantite(ligneDto.getQuantite());
            ligne.setPrixUnitaire(article.getPrixUnitaire());
            ligne.setCommandeFournisseur(commande);
            commande.getLignes().add(ligne);
        }

        return commandeFournisseurMapper.toResponseDto(commandeFournisseurRepository.save(commande));
    }

    @Override
    public CommandeFournisseurResponseDto update(Long id, CommandeFournisseurRequestDto dto) {
        CommandeFournisseur commande = getOrThrow(id);
        if (commande.getStatut() != StatutCommande.EN_ATTENTE) {
            throw new IllegalArgumentException("Seule une commande EN_ATTENTE peut être modifiée");
        }
        commande.setCommentaire(dto.getCommentaire());
        return commandeFournisseurMapper.toResponseDto(commandeFournisseurRepository.save(commande));
    }

    @Override
    public CommandeFournisseurResponseDto changerStatut(Long id, StatutCommandeDto dto) {
        CommandeFournisseur commande = getOrThrow(id);
        StatutCommande ancienStatut = commande.getStatut();
        commande.setStatut(dto.getStatut());

        // Si la commande passe à LIVREE, on incrémente le stock de chaque article
        if (dto.getStatut() == StatutCommande.LIVREE && ancienStatut != StatutCommande.LIVREE) {
            for (LigneCommandeFournisseur ligne : commande.getLignes()) {
                Article article = ligne.getArticle();
                article.setQuantiteStock(article.getQuantiteStock() + ligne.getQuantite());
                articleRepository.save(article);
            }
        }

        return commandeFournisseurMapper.toResponseDto(commandeFournisseurRepository.save(commande));
    }

    @Override
    public void delete(Long id) {
        commandeFournisseurRepository.delete(getOrThrow(id));
    }

    /**
     * Crée automatiquement une commande fournisseur de réapprovisionnement.
     * La quantité commandée est calculée pour remonter à 2x le seuil minimum.
     */
    @Override
    public void creerReapprovisionnementAuto(Article article) {
        int qteACommander = (article.getSeuilMinimum() * 2) - article.getQuantiteStock();
        if (qteACommander <= 0) return;

        CommandeFournisseur commande = new CommandeFournisseur();
        commande.setFournisseur(article.getFournisseur());
        commande.setStatut(StatutCommande.EN_ATTENTE);
        commande.setGenereeAutomatiquement(true);
        commande.setCommentaire("Réapprovisionnement automatique — stock sous le seuil pour : " + article.getDesignation());

        LigneCommandeFournisseur ligne = new LigneCommandeFournisseur();
        ligne.setArticle(article);
        ligne.setQuantite(qteACommander);
        ligne.setPrixUnitaire(article.getPrixUnitaire());
        ligne.setCommandeFournisseur(commande);
        commande.getLignes().add(ligne);

        commandeFournisseurRepository.save(commande);
    }

    private CommandeFournisseur getOrThrow(Long id) {
        return commandeFournisseurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("CommandeFournisseur", id));
    }
}
