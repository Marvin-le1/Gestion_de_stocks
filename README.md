# NEGOSUD — Application de Gestion de Stock

Application complète de gestion de stock pour la société NEGOSUD, négociant en vins du terroir gascon.

## Architecture

```
┌─────────────────────┐     REST API     ┌──────────────────────┐
│  Back-office React  │ ◄──────────────► │  Spring Boot API     │
│  (Gestion interne)  │                  │  (Port 8080)         │
└─────────────────────┘                  │                      │
┌─────────────────────┐     REST API     │  MySQL               │
│  Boutique React     │ ◄──────────────► │  (Base de données)   │
│  (Front-office)     │                  └──────────────────────┘
└─────────────────────┘
```

---

## Prérequis

| Outil | Version minimum |
|-------|----------------|
| Java (JDK) | 21 |
| Maven | 3.8+ |
| MySQL | 8.0+ |
| Node.js | 18+ |
| npm | 9+ |

---

## Installation

### 1. Cloner le projet

```bash
git clone https://github.com/Marvin-le1/Gestion_de_stocks.git
cd Gestion_de_stocks
```

### 2. Configurer la base de données

Créer la base de données MySQL :

```sql
CREATE DATABASE negosud;
```

Copier le fichier de configuration et l'adapter :

```bash
cp src/main/resources/application.properties.example src/main/resources/application.properties
```

Modifier `src/main/resources/application.properties` avec vos identifiants MySQL :

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/negosud?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=Europe/Paris
spring.datasource.username=root
spring.datasource.password=votre_mot_de_passe
```

> ⚠️ Le fichier `application.properties` est ignoré par Git — chaque développeur garde sa propre configuration locale.

### 3. Lancer l'API Spring Boot

```bash
mvn spring-boot:run
```

L'API démarre sur **http://localhost:8080**

Au premier démarrage, Hibernate crée automatiquement les tables et les données de démonstration sont insérées.

**Compte administrateur créé automatiquement :**
| Email | Mot de passe |
|-------|-------------|
| admin@negosud.fr | negosud2024 |

### 4. Lancer le front-end React

```bash
cd front
npm install
npm start
```

L'application démarre sur **http://localhost:3000**

---

## Accès à l'application

| Interface | URL | Accès |
|-----------|-----|-------|
| Boutique (clients) | http://localhost:3000/boutique | Public |
| Back-office (gestion) | http://localhost:3000/login | Admin / Employé |
| Documentation Swagger | http://localhost:8080/swagger-ui.html | Public |

---

## Fonctionnalités

### Back-office (Admin & Employés)

- **Articles** — CRUD complet, gestion du stock, seuil de réapprovisionnement
- **Familles** — Classification des vins (Rouge, Blanc, Rosé, Pétillant, Digestif)
- **Fournisseurs** — Gestion des domaines partenaires
- **Clients** — Base clients
- **Commandes clients** — Suivi des commandes (EN_ATTENTE → VALIDÉE → LIVRÉE / ANNULÉE)
- **Commandes fournisseurs** — Réapprovisionnement manuel et automatique
- **Inventaire** — Saisie des quantités constatées et régularisation du stock
- **Utilisateurs** — Gestion des comptes back-office (Admin uniquement)

### Boutique (Front-office)

- Catalogue filtrable et triable par famille, maison, millésime, prix
- Détail de chaque article (description, prix unitaire, prix carton, stock)
- Panier persistant
- Tunnel d'achat complet avec identification client (connexion ou première commande)
- Formulaire de contact

### Logique métier automatisée

- **Réapprovisionnement automatique** : lors d'une commande client, si le stock d'un article passe sous son seuil minimum, une commande fournisseur est générée automatiquement (désactivable par article)
- **Mise à jour du stock à la livraison fournisseur** : passer une commande fournisseur en `LIVREE` incrémente le stock
- **Décrémentation du stock à la livraison client** : passer une commande client en `LIVREE` décrémente le stock

---

## Rôles et accès

| Rôle | Droits |
|------|--------|
| `ADMIN` | Accès complet + gestion des utilisateurs |
| `EMPLOYE` | Accès complet au back-office sauf gestion des utilisateurs |
| Client boutique | Consulter le catalogue, passer commande |

---

## Endpoints API principaux

| Ressource | URL | Auth |
|-----------|-----|------|
| Authentification | `POST /api/auth/login` | Public |
| Articles | `GET /api/articles` | Public |
| Familles | `GET /api/familles` | Public |
| Clients (boutique) | `POST /api/clients/find-or-create` | Public |
| Commandes clients (boutique) | `POST /api/commandes-clients` | Public |
| Articles (CRUD) | `/api/articles/**` | Authentifié |
| Fournisseurs | `/api/fournisseurs/**` | Authentifié |
| Commandes clients | `/api/commandes-clients/**` | Authentifié |
| Commandes fournisseurs | `/api/commandes-fournisseurs/**` | Authentifié |
| Inventaire | `/api/inventaires/**` | Authentifié |
| Utilisateurs | `/api/utilisateurs/**` | Admin uniquement |

Documentation complète : **http://localhost:8080/swagger-ui.html**

---

## Structure du projet

```
Gestion_de_stocks/
├── src/main/java/com/negosud/api/
│   ├── config/              # SecurityConfig, CorsConfig, DataInitializer
│   ├── controller/          # Contrôleurs REST
│   ├── service/             # Logique métier (interfaces + impl/)
│   ├── repository/          # JpaRepository
│   ├── model/
│   │   ├── entity/          # Entités JPA
│   │   └── enums/           # StatutCommande, TypeFamille, Role
│   ├── dto/
│   │   ├── request/         # DTO entrée
│   │   └── response/        # DTO sortie
│   ├── mapper/              # Conversion Entity <-> DTO
│   ├── security/            # JWT (JwtUtil, JwtAuthFilter)
│   └── exception/           # Gestion des erreurs globale
├── src/main/resources/
│   ├── application.properties.example
│   └── application.properties        # ← ignoré par Git (local uniquement)
├── front/                   # Application React
│   ├── src/
│   │   ├── pages/           # Toutes les pages (back-office + boutique)
│   │   ├── components/      # Composants réutilisables
│   │   ├── services/        # Appels API (axios)
│   │   ├── contexts/        # AuthContext, CartContext, ShopAuthContext
│   │   └── routes/          # AppRoutes avec PrivateRoute / AdminRoute
│   └── .env.example
└── docs/                    # Diagrammes UML et MCD
```

---

## Technologies utilisées

| Couche | Technologie |
|--------|-------------|
| API REST | Spring Boot 3.2, Spring Security, JWT |
| ORM | Hibernate / JPA |
| Base de données | MySQL 8 |
| Documentation API | Swagger / OpenAPI 3 |
| Front-end | React 18, Material UI v5 |
| HTTP Client | Axios |
| Routing | React Router v6 |

---

## Diagrammes

- [Diagramme de classes](docs/diagramme-classes.md)
- [Diagramme de cas d'utilisation](docs/diagramme-cas-utilisation.md)
- [Diagrammes de séquence](docs/diagrammes-sequences.md)
- [MCD / MLD](docs/MCD_MLD_NEGOSUD.drawio)
