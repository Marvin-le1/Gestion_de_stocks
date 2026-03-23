package com.negosud.api.service.impl;

import com.negosud.api.dto.request.CommandeClientRequestDto;
import com.negosud.api.dto.request.LigneCommandeRequestDto;
import com.negosud.api.dto.request.StatutCommandeDto;
import com.negosud.api.dto.response.CommandeClientResponseDto;
import com.negosud.api.dto.response.LigneCommandeClientResponseDto;
import com.negosud.api.exception.ResourceNotFoundException;
import com.negosud.api.mapper.CommandeClientMapper;
import com.negosud.api.model.entity.*;
import com.negosud.api.model.enums.StatutCommande;
import com.negosud.api.repository.*;
import com.negosud.api.service.CommandeClientService;
import com.negosud.api.service.CommandeFournisseurService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class CommandeClientServiceImpl implements CommandeClientService {

    private final CommandeClientRepository commandeClientRepository;
    private final LigneCommandeClientRepository ligneCommandeClientRepository;
    private final ClientRepository clientRepository;
    private final ArticleRepository articleRepository;
    private final CommandeClientMapper commandeClientMapper;
    private final CommandeFournisseurService commandeFournisseurService;

    public CommandeClientServiceImpl(
            CommandeClientRepository commandeClientRepository,
            LigneCommandeClientRepository ligneCommandeClientRepository,
            ClientRepository clientRepository,
            ArticleRepository articleRepository,
            CommandeClientMapper commandeClientMapper,
            @Lazy CommandeFournisseurService commandeFournisseurService) {
        this.commandeClientRepository = commandeClientRepository;
        this.ligneCommandeClientRepository = ligneCommandeClientRepository;
        this.clientRepository = clientRepository;
        this.articleRepository = articleRepository;
        this.commandeClientMapper = commandeClientMapper;
        this.commandeFournisseurService = commandeFournisseurService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<CommandeClientResponseDto> findAll() {
        return commandeClientRepository.findAll().stream()
                .map(commandeClientMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CommandeClientResponseDto findById(Long id) {
        return commandeClientMapper.toResponseDto(getOrThrow(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LigneCommandeClientResponseDto> findLignesByCommande(Long id) {
        getOrThrow(id);
        return ligneCommandeClientRepository.findByCommandeClientId(id).stream()
                .map(commandeClientMapper::ligneToResponseDto)
                .toList();
    }

    @Override
    public CommandeClientResponseDto create(CommandeClientRequestDto dto) {
        Client client = clientRepository.findById(dto.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client", dto.getClientId()));

        CommandeClient commande = new CommandeClient();
        commande.setClient(client);
        commande.setCommentaire(dto.getCommentaire());
        commande.setStatut(StatutCommande.EN_ATTENTE);

        for (LigneCommandeRequestDto ligneDto : dto.getLignes()) {
            Article article = getArticleOrThrow(ligneDto.getArticleId());
            LigneCommandeClient ligne = new LigneCommandeClient();
            ligne.setArticle(article);
            ligne.setQuantite(ligneDto.getQuantite());
            // Snapshot du prix au moment de la commande
            ligne.setPrixUnitaire(article.getPrixUnitaire());
            ligne.setCommandeClient(commande);
            commande.getLignes().add(ligne);
        }

        CommandeClient saved = commandeClientRepository.save(commande);

        // Vérification du réapprovisionnement automatique pour chaque article commandé
        verifierEtDeclencher_Reapprovisionnement(saved);

        return commandeClientMapper.toResponseDto(saved);
    }

    @Override
    public CommandeClientResponseDto update(Long id, CommandeClientRequestDto dto) {
        CommandeClient commande = getOrThrow(id);
        if (commande.getStatut() != StatutCommande.EN_ATTENTE) {
            throw new IllegalArgumentException("Seule une commande EN_ATTENTE peut être modifiée");
        }
        commande.setCommentaire(dto.getCommentaire());
        return commandeClientMapper.toResponseDto(commandeClientRepository.save(commande));
    }

    @Override
    public CommandeClientResponseDto changerStatut(Long id, StatutCommandeDto dto) {
        CommandeClient commande = getOrThrow(id);
        commande.setStatut(dto.getStatut());
        return commandeClientMapper.toResponseDto(commandeClientRepository.save(commande));
    }

    @Override
    public LigneCommandeClientResponseDto ajouterLigne(Long id, LigneCommandeRequestDto dto) {
        CommandeClient commande = getOrThrow(id);
        Article article = getArticleOrThrow(dto.getArticleId());

        LigneCommandeClient ligne = new LigneCommandeClient();
        ligne.setCommandeClient(commande);
        ligne.setArticle(article);
        ligne.setQuantite(dto.getQuantite());
        ligne.setPrixUnitaire(article.getPrixUnitaire());

        LigneCommandeClient saved = ligneCommandeClientRepository.save(ligne);
        verifierEtDeclencher_Reapprovisionnement(commande);
        return commandeClientMapper.ligneToResponseDto(saved);
    }

    @Override
    public void supprimerLigne(Long commandeId, Long ligneId) {
        getOrThrow(commandeId);
        LigneCommandeClient ligne = ligneCommandeClientRepository.findById(ligneId)
                .orElseThrow(() -> new ResourceNotFoundException("LigneCommandeClient", ligneId));
        ligneCommandeClientRepository.delete(ligne);
    }

    @Override
    public void delete(Long id) {
        commandeClientRepository.delete(getOrThrow(id));
    }

    /**
     * Pour chaque article d'une commande client, si le stock est sous le seuil
     * et que le réapprovisionnement auto est activé, on crée une commande fournisseur.
     */
    private void verifierEtDeclencher_Reapprovisionnement(CommandeClient commande) {
        for (LigneCommandeClient ligne : commande.getLignes()) {
            Article article = ligne.getArticle();
            if (Boolean.TRUE.equals(article.getReapprovisionnementAuto())
                    && article.getQuantiteStock() <= article.getSeuilMinimum()) {
                commandeFournisseurService.creerReapprovisionnementAuto(article);
            }
        }
    }

    private CommandeClient getOrThrow(Long id) {
        return commandeClientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("CommandeClient", id));
    }

    private Article getArticleOrThrow(Long id) {
        return articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", id));
    }
}
