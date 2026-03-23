# NEGOSUD - Front mobile Flutter

Application mobile (sans authentification pour le moment) avec deux espaces:

- Back-office gerant: gestion des articles, familles, fournisseurs, clients, commandes clients, commandes fournisseurs, inventaires.
- Front-office client: catalogue, panier, passage de commande, suivi des commandes.

## Prerequis

- Flutter 3.41+ / Dart 3.11+
- Backend Spring Boot NEGOSUD lance localement
- (Optionnel) ngrok pour exposer le backend en HTTPS

## Configuration

1. Copier `.env.example` vers `.env` si besoin.
2. La variable utilisee est `URL_NGROK`.
3. Si `URL_NGROK` est absente, fallback automatique sur `http://10.0.2.2:8080/api`.

## Lancement local

Depuis `stive_flutter`:

```powershell
flutter pub get
flutter run
```

## ngrok + .env automatique

Depuis le dossier `stive_flutter`, lance:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-ngrok.ps1
```

Ce script:

- detecte le port backend automatiquement (`server.port` dans `application.properties`, sinon `8080`)
- demarre `ngrok http <port>`
- recupere l'URL publique via l'API locale ngrok
- met a jour `URL_NGROK=...` dans `.env`

Options utiles:

```powershell
# Si ngrok.exe n'est pas dans le PATH
powershell -ExecutionPolicy Bypass -File .\scripts\start-ngrok.ps1 -NgrokPath "C:\\outils\\ngrok.exe"

# Met a jour seulement .env depuis un ngrok deja lance
powershell -ExecutionPolicy Bypass -File .\scripts\start-ngrok.ps1 -NoStart

# Copie aussi l'URL dans le presse-papiers
powershell -ExecutionPolicy Bypass -File .\scripts\start-ngrok.ps1 -CopyToClipboard

# Verifier le statut de ngrok
Get-Process ngrok -ErrorAction SilentlyContinue

# Stopper ngrok
Stop-Process -Name ngrok -Force
```

## Procedure complete (demo mobile)

1. Lancer le backend Spring Boot a la racine du repo (`pom.xml`):

```powershell
mvn spring-boot:run
```

2. Lancer ngrok et mettre a jour `.env`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-ngrok.ps1
```

3. Lancer l'app Flutter:

```powershell
flutter run
```

## Couverture cahier des charges

- Separation des espaces gerant/client: OK.
- CRUD principaux (articles, familles, fournisseurs, clients): OK.
- Commandes clients: creation, statut, suppression, gestion des lignes: OK.
- Commandes fournisseurs: creation, statut, suppression, gestion des lignes: OK.
- Inventaires: creation avec lignes + historique: OK.
- Front-office client: recherche catalogue, panier, validation commande, suivi + detail des lignes: OK.

## Verification qualite

```powershell
flutter analyze
flutter test
```
