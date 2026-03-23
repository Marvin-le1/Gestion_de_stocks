# NEGOSUD — API Gestion de Stock

API REST Spring Boot pour la gestion des stocks, commandes clients et fournisseurs de la société NEGOSUD (négociant en vins).

---

## Prérequis

- Java 17+
- Maven 3.8+
- MySQL 8+

---

## Installation et lancement

### 1. Créer la base de données

```sql
CREATE DATABASE negosud;
```

### 2. Configurer les identifiants MySQL

Modifier `src/main/resources/application.properties` :

```properties
spring.datasource.username=root
spring.datasource.password=votre_mot_de_passe
```

### 3. Lancer l'application

```bash
mvn spring-boot:run
```

L'API démarre sur **http://localhost:8080**

### 4. Accéder à la documentation Swagger

```
http://localhost:8080/swagger-ui.html
```

---

## Endpoints principaux

| Ressource               | Base URL                         |
|-------------------------|----------------------------------|
| Articles                | `/api/articles`                  |
| Familles                | `/api/familles`                  |
| Fournisseurs            | `/api/fournisseurs`              |
| Clients                 | `/api/clients`                   |
| Commandes clients       | `/api/commandes-clients`         |
| Commandes fournisseurs  | `/api/commandes-fournisseurs`    |
| Inventaires             | `/api/inventaires`               |

---

## Structure du projet

```
src/main/java/com/negosud/api/
├── NegosudApiApplication.java
├── config/
│   └── OpenApiConfig.java
├── controller/
│   ├── ArticleController.java
│   ├── ClientController.java
│   ├── CommandeClientController.java
│   ├── CommandeFournisseurController.java
│   ├── FamilleController.java
│   ├── FournisseurController.java
│   └── InventaireController.java
├── service/
│   ├── ArticleService.java  (+ impl/)
│   ├── ClientService.java   (+ impl/)
│   ├── CommandeClientService.java  (+ impl/)
│   ├── CommandeFournisseurService.java  (+ impl/)
│   ├── FamilleService.java  (+ impl/)
│   ├── FournisseurService.java  (+ impl/)
│   └── InventaireService.java  (+ impl/)
├── repository/            (JpaRepository pour chaque entité)
├── model/
│   ├── entity/            (Article, Client, Commande*, Famille, Fournisseur, Inventaire, Ligne*)
│   └── enums/             (StatutCommande, TypeFamille)
├── dto/
│   ├── request/           (*RequestDto)
│   └── response/          (*ResponseDto)
├── mapper/                (MapStruct)
└── exception/
    ├── GlobalExceptionHandler.java
    ├── ResourceNotFoundException.java
    └── StockInsuffisantException.java
```

---

## Fonctionnalités métier clés

- **Réapprovisionnement automatique** : lors de la création d'une commande client, si le stock d'un article passe sous son seuil minimum et que l'option est activée, une commande fournisseur est générée automatiquement.
- **Mise à jour du stock à la livraison** : passer une commande fournisseur en statut `LIVREE` incrémente automatiquement le stock des articles concernés.
- **Inventaire** : création d'un inventaire avec saisie des quantités constatées, puis régularisation (action irréversible) pour mettre à jour les stocks réels.
