# Diagrammes de séquence — NEGOSUD

---

## 1. Passage de commande boutique (avec réapprovisionnement automatique)

```mermaid
sequenceDiagram
    actor Client
    participant Boutique as Boutique React
    participant API as API Spring Boot
    participant DB as Base de données

    Client->>Boutique: Ajoute des articles au panier
    Client->>Boutique: Valide la commande (formulaire coordonnées)

    Boutique->>API: POST /api/clients/find-or-create {email, nom, ...}
    API->>DB: Recherche client par email
    alt Client existant
        DB-->>API: Client trouvé
    else Nouveau client
        API->>DB: Crée le client
        DB-->>API: Client créé
    end
    API-->>Boutique: ClientResponseDto {id, ...}

    Boutique->>API: POST /api/commandes-clients {clientId, lignes[]}
    API->>DB: Crée CommandeClient + LignesCommandeClient
    loop Pour chaque article commandé
        API->>DB: Vérifie stock article
        alt Stock < seuil minimum ET réappro activé
            API->>DB: Crée CommandeFournisseur automatique
            Note over API,DB: genereeAutomatiquement = true
        end
    end
    DB-->>API: Commande enregistrée
    API-->>Boutique: CommandeClientResponseDto {id, statut: EN_ATTENTE}
    Boutique-->>Client: Page de confirmation
```

---

## 2. Livraison d'une commande fournisseur (mise à jour du stock)

```mermaid
sequenceDiagram
    actor Employe as Employé
    participant BackOffice as Back-office React
    participant API as API Spring Boot
    participant DB as Base de données

    Employe->>BackOffice: Ouvre la commande fournisseur
    Employe->>BackOffice: Clique "Passer en LIVREE"
    BackOffice->>API: PATCH /api/commandes-fournisseurs/{id}/statut {statut: LIVREE}

    API->>DB: Vérifie statut actuel (doit être VALIDEE)
    DB-->>API: Statut OK

    loop Pour chaque ligne de la commande
        API->>DB: Article.quantiteStock += ligne.quantite
        DB-->>API: Stock mis à jour
    end

    API->>DB: CommandeFournisseur.statut = LIVREE
    DB-->>API: Commande mise à jour
    API-->>BackOffice: CommandeFournisseurResponseDto
    BackOffice-->>Employe: Commande marquée LIVRÉE, stocks mis à jour
```

---

## 3. Connexion et accès back-office

```mermaid
sequenceDiagram
    actor User as Admin / Employé
    participant Login as Page Connexion
    participant API as API Spring Boot
    participant BackOffice as Back-office React

    User->>Login: Saisit email + mot de passe
    Login->>API: POST /api/auth/login {email, motDePasse}
    API->>API: Vérifie identifiants (BCrypt)

    alt Identifiants valides
        API-->>Login: {token JWT, nom, email, role}
        Login->>Login: Stocke token dans localStorage
        Login-->>BackOffice: Redirige vers /articles
        User->>BackOffice: Navigue dans le back-office
        BackOffice->>API: Requêtes avec Authorization: Bearer {token}
        API-->>BackOffice: Données protégées
    else Identifiants invalides
        API-->>Login: 401 Unauthorized
        Login-->>User: "Email ou mot de passe incorrect"
    end
```

---

## 4. Inventaire et régularisation du stock

```mermaid
sequenceDiagram
    actor Employe as Employé
    participant BackOffice as Back-office React
    participant API as API Spring Boot
    participant DB as Base de données

    Employe->>BackOffice: Crée un nouvel inventaire
    BackOffice->>API: POST /api/inventaires
    API->>DB: Crée Inventaire (regularise = false)
    DB-->>API: Inventaire créé
    API-->>BackOffice: InventaireResponseDto

    loop Pour chaque article
        Employe->>BackOffice: Saisit quantité constatée
        BackOffice->>API: POST /api/inventaires/{id}/lignes {articleId, quantiteConstatee}
        API->>DB: Crée LigneInventaire (stocke quantité avant régularisation)
        DB-->>API: Ligne créée
    end

    Employe->>BackOffice: Clique "Régulariser le stock"
    BackOffice->>API: POST /api/inventaires/{id}/regulariser
    API->>DB: Vérifie inventaire non déjà régularisé

    loop Pour chaque ligne d'inventaire
        API->>DB: Article.quantiteStock = ligne.quantiteConstatee
    end

    API->>DB: Inventaire.regularise = true
    DB-->>API: Stocks régularisés
    API-->>BackOffice: Inventaire finalisé
    BackOffice-->>Employe: Confirmation régularisation
```
