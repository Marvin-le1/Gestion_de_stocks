package com.negosud.api.config;

import com.negosud.api.model.entity.*;
import com.negosud.api.model.enums.StatutCommande;
import com.negosud.api.model.enums.TypeFamille;
import com.negosud.api.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final FamilleRepository familleRepository;
    private final FournisseurRepository fournisseurRepository;
    private final ArticleRepository articleRepository;
    private final ClientRepository clientRepository;
    private final CommandeClientRepository commandeClientRepository;
    private final CommandeFournisseurRepository commandeFournisseurRepository;
    private final LigneCommandeClientRepository ligneCommandeClientRepository;
    private final LigneCommandeFournisseurRepository ligneCommandeFournisseurRepository;
    private final InventaireRepository inventaireRepository;
    private final LigneInventaireRepository ligneInventaireRepository;

    @Override
    @Transactional
    public void run(String... args) {
        // On ne charge les données que si la base est vide
        if (familleRepository.count() > 0) {
            log.info("Base de données déjà peuplée — initialisation ignorée.");
            return;
        }

        log.info("Initialisation des données de démonstration NEGOSUD...");

        // ── Familles ─────────────────────────────────────────────────────────
        Famille rouge     = famille(TypeFamille.ROUGE,     "Vins rouges de toutes régions");
        Famille blanc     = famille(TypeFamille.BLANC,     "Vins blancs secs et moelleux");
        Famille rose      = famille(TypeFamille.ROSE,      "Vins rosés de Provence et d'ailleurs");
        Famille petillant = famille(TypeFamille.PETILLANT, "Champagnes, crémants et mousseux");
        Famille digestif  = famille(TypeFamille.DIGESTIF,  "Alcools et digestifs de qualité");

        familleRepository.saveAll(List.of(rouge, blanc, rose, petillant, digestif));
        log.info("✔ Familles créées");

        // ── Fournisseurs ──────────────────────────────────────────────────────
        Fournisseur chateauMargaux = fournisseur(
                "Château Margaux", "33460 Margaux", "Margaux", "33460",
                "05 57 88 83 83", "contact@chateau-margaux.com", "Jean-Luc Bordes");

        Fournisseur maisonsLafite = fournisseur(
                "Domaines Barons de Rothschild", "33250 Pauillac", "Pauillac", "33250",
                "05 56 73 18 18", "contact@lafite.com", "Eric de Rothschild");

        Fournisseur champagneMoet = fournisseur(
                "Moët & Chandon", "20 Avenue de Champagne, 51200 Épernay", "Épernay", "51200",
                "03 26 51 20 00", "contact@moet.fr", "Stéphane Baschiera");

        Fournisseur domaineRichard = fournisseur(
                "Domaine Richard", "84190 Gigondas", "Gigondas", "84190",
                "04 90 65 85 20", "richard@gigondas.fr", "Paul Richard");

        fournisseurRepository.saveAll(List.of(chateauMargaux, maisonsLafite, champagneMoet, domaineRichard));
        log.info("✔ Fournisseurs créés");

        // ── Articles ──────────────────────────────────────────────────────────
        Article a1 = article("MAR-2018", "Château Margaux 2018",
                "Grand cru classé, tanins soyeux, notes de cassis et cèdre",
                "Château Margaux", 2018,
                new BigDecimal("420.00"), new BigDecimal("4800.00"),
                48, 12, true, rouge, chateauMargaux);

        Article a2 = article("LAF-2019", "Lafite Rothschild 2019",
                "1er Grand Cru Classé, élégant et complexe",
                "Domaines Barons de Rothschild", 2019,
                new BigDecimal("680.00"), new BigDecimal("7800.00"),
                24, 6, true, rouge, maisonsLafite);

        Article a3 = article("MOE-NV", "Moët & Chandon Brut Impérial",
                "Champagne emblématique, équilibre entre fraîcheur et maturité",
                "Moët & Chandon", null,
                new BigDecimal("38.00"), new BigDecimal("432.00"),
                120, 24, true, petillant, champagneMoet);

        Article a4 = article("MOE-ROSE", "Moët & Chandon Rosé Impérial",
                "Champagne rosé, notes de fruits rouges et pêche",
                "Moët & Chandon", null,
                new BigDecimal("45.00"), new BigDecimal("516.00"),
                60, 12, true, petillant, champagneMoet);

        Article a5 = article("GIG-2021", "Gigondas Domaine Richard 2021",
                "Grenache dominant, robe grenat, épices et fruits noirs",
                "Domaine Richard", 2021,
                new BigDecimal("18.50"), new BigDecimal("210.00"),
                96, 24, true, rouge, domaineRichard);

        Article a6 = article("GIG-BL-2022", "Gigondas Blanc Domaine Richard 2022",
                "Rare blanc de Gigondas, viognier et clairette, floral et gras",
                "Domaine Richard", 2022,
                new BigDecimal("22.00"), new BigDecimal("252.00"),
                36, 12, true, blanc, domaineRichard);

        Article a7 = article("PRO-ROSE-2023", "Provence Rosé Domaine Richard 2023",
                "Rosé de Provence pâle, fraîcheur et notes de fraise",
                "Domaine Richard", 2023,
                new BigDecimal("12.00"), new BigDecimal("138.00"),
                5, 18, true, rose, domaineRichard);  // stock bas → réappro démo

        Article a8 = article("ARM-XO", "Armagnac XO Hors d'Âge",
                "Armagnac vieilli 20 ans minimum, vanille, pruneaux, chocolat",
                "Domaine Richard", null,
                new BigDecimal("95.00"), null,
                18, 6, false, digestif, domaineRichard);

        articleRepository.saveAll(List.of(a1, a2, a3, a4, a5, a6, a7, a8));
        log.info("✔ Articles créés");

        // ── Clients ───────────────────────────────────────────────────────────
        Client c1 = client("Dupont", "Alice",   "alice.dupont@gmail.com",   "06 12 34 56 78", "12 rue de la Paix", "Paris",      "75001");
        Client c2 = client("Martin", "Bruno",   "bruno.martin@orange.fr",   "06 98 76 54 32", "5 avenue des Fleurs", "Lyon",    "69002");
        Client c3 = client("Leblanc", "Claire", "claire.leblanc@yahoo.fr",  "07 11 22 33 44", "8 allée des Vignes",  "Bordeaux","33000");
        Client c4 = client("Moreau", "David",   "david.moreau@hotmail.com", "06 55 66 77 88", "22 bd Haussmann",     "Paris",   "75009");

        clientRepository.saveAll(List.of(c1, c2, c3, c4));
        log.info("✔ Clients créés");

        // ── Commandes clients ─────────────────────────────────────────────────
        CommandeClient cc1 = new CommandeClient();
        cc1.setClient(c1);
        cc1.setDateCommande(LocalDateTime.now().minusDays(10));
        cc1.setStatut(StatutCommande.LIVREE);
        cc1.setCommentaire("Commande anniversaire");
        commandeClientRepository.save(cc1);

        LigneCommandeClient lcc1a = ligne(cc1, a3, 6, a3.getPrixUnitaire());
        LigneCommandeClient lcc1b = ligne(cc1, a5, 12, a5.getPrixUnitaire());
        ligneCommandeClientRepository.saveAll(List.of(lcc1a, lcc1b));

        CommandeClient cc2 = new CommandeClient();
        cc2.setClient(c2);
        cc2.setDateCommande(LocalDateTime.now().minusDays(3));
        cc2.setStatut(StatutCommande.VALIDEE);
        commandeClientRepository.save(cc2);

        LigneCommandeClient lcc2a = ligne(cc2, a1, 2, a1.getPrixUnitaire());
        LigneCommandeClient lcc2b = ligne(cc2, a4, 3, a4.getPrixUnitaire());
        ligneCommandeClientRepository.saveAll(List.of(lcc2a, lcc2b));

        CommandeClient cc3 = new CommandeClient();
        cc3.setClient(c3);
        cc3.setDateCommande(LocalDateTime.now().minusHours(5));
        cc3.setStatut(StatutCommande.EN_ATTENTE);
        cc3.setCommentaire("Livraison avant vendredi svp");
        commandeClientRepository.save(cc3);

        LigneCommandeClient lcc3a = ligne(cc3, a6, 6, a6.getPrixUnitaire());
        ligneCommandeClientRepository.save(lcc3a);

        log.info("✔ Commandes clients créées");

        // ── Commandes fournisseurs ────────────────────────────────────────────
        CommandeFournisseur cf1 = new CommandeFournisseur();
        cf1.setFournisseur(champagneMoet);
        cf1.setDateCommande(LocalDateTime.now().minusDays(20));
        cf1.setStatut(StatutCommande.LIVREE);
        cf1.setGenereeAutomatiquement(false);
        cf1.setCommentaire("Réassort avant fêtes");
        commandeFournisseurRepository.save(cf1);

        LigneCommandeFournisseur lcf1a = ligneFournisseur(cf1, a3, 48, a3.getPrixUnitaire());
        LigneCommandeFournisseur lcf1b = ligneFournisseur(cf1, a4, 24, a4.getPrixUnitaire());
        ligneCommandeFournisseurRepository.saveAll(List.of(lcf1a, lcf1b));

        CommandeFournisseur cf2 = new CommandeFournisseur();
        cf2.setFournisseur(domaineRichard);
        cf2.setDateCommande(LocalDateTime.now().minusDays(1));
        cf2.setStatut(StatutCommande.EN_ATTENTE);
        cf2.setGenereeAutomatiquement(true);
        cf2.setCommentaire("Réapprovisionnement automatique — stock sous le seuil pour : Provence Rosé Domaine Richard 2023");
        commandeFournisseurRepository.save(cf2);

        LigneCommandeFournisseur lcf2a = ligneFournisseur(cf2, a7, 36, a7.getPrixUnitaire());
        ligneCommandeFournisseurRepository.save(lcf2a);

        log.info("✔ Commandes fournisseurs créées");

        // ── Inventaire ────────────────────────────────────────────────────────
        Inventaire inv = new Inventaire();
        inv.setDateInventaire(LocalDateTime.now().minusDays(30));
        inv.setCommentaire("Inventaire mensuel de février");
        inv.setRegularise(true);
        inventaireRepository.save(inv);

        LigneInventaire li1 = ligneInv(inv, a5, 95, 96);
        LigneInventaire li2 = ligneInv(inv, a6, 36, 37);
        LigneInventaire li3 = ligneInv(inv, a3, 120, 118);
        ligneInventaireRepository.saveAll(List.of(li1, li2, li3));

        log.info("✔ Inventaire créé");
        log.info("✅ Données NEGOSUD initialisées avec succès !");
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private Famille famille(TypeFamille type, String description) {
        Famille f = new Famille();
        f.setType(type);
        f.setDescription(description);
        return f;
    }

    private Fournisseur fournisseur(String nom, String adresse, String ville,
                                    String cp, String tel, String email, String contact) {
        Fournisseur f = new Fournisseur();
        f.setNom(nom);
        f.setAdresse(adresse);
        f.setVille(ville);
        f.setCodePostal(cp);
        f.setTelephone(tel);
        f.setEmail(email);
        f.setContactNom(contact);
        return f;
    }

    private Article article(String ref, String designation, String description,
                             String maison, Integer annee,
                             BigDecimal prixUnitaire, BigDecimal prixCarton,
                             int stock, int seuil, boolean reappro,
                             Famille famille, Fournisseur fournisseur) {
        Article a = new Article();
        a.setReference(ref);
        a.setDesignation(designation);
        a.setDescription(description);
        a.setMaison(maison);
        a.setAnnee(annee);
        a.setPrixUnitaire(prixUnitaire);
        a.setPrixCarton(prixCarton);
        a.setQuantiteStock(stock);
        a.setSeuilMinimum(seuil);
        a.setReapprovisionnementAuto(reappro);
        a.setFamille(famille);
        a.setFournisseur(fournisseur);
        return a;
    }

    private Client client(String nom, String prenom, String email,
                           String tel, String adresse, String ville, String cp) {
        Client c = new Client();
        c.setNom(nom);
        c.setPrenom(prenom);
        c.setEmail(email);
        c.setTelephone(tel);
        c.setAdresse(adresse);
        c.setVille(ville);
        c.setCodePostal(cp);
        return c;
    }

    private LigneCommandeClient ligne(CommandeClient commande, Article article,
                                       int quantite, BigDecimal prix) {
        LigneCommandeClient l = new LigneCommandeClient();
        l.setCommandeClient(commande);
        l.setArticle(article);
        l.setQuantite(quantite);
        l.setPrixUnitaire(prix);
        return l;
    }

    private LigneCommandeFournisseur ligneFournisseur(CommandeFournisseur commande,
                                                       Article article,
                                                       int quantite, BigDecimal prix) {
        LigneCommandeFournisseur l = new LigneCommandeFournisseur();
        l.setCommandeFournisseur(commande);
        l.setArticle(article);
        l.setQuantite(quantite);
        l.setPrixUnitaire(prix);
        return l;
    }

    private LigneInventaire ligneInv(Inventaire inventaire, Article article,
                                      int constatee, int avantRegularisation) {
        LigneInventaire l = new LigneInventaire();
        l.setInventaire(inventaire);
        l.setArticle(article);
        l.setQuantiteConstatee(constatee);
        l.setQuantiteAvantRegularisation(avantRegularisation);
        return l;
    }
}
