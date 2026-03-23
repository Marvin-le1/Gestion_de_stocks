# stive_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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

# Connaitre le statut de Ngrok
Get-Process ngrok -ErrorAction SilentlyContinue

# Stopper Ngrok
Stop-Process -Name ngrok -Force
```
