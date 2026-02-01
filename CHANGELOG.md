# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.0.0] - 2024-09-28

### Hinzugefügt
- Vollautomatisches Installations-Script für Minecraft Server
- Interaktive Konfiguration für alle wichtigen Server-Einstellungen
- Dynamische Versionserkennung basierend auf Client-Version
- Unterstützung für Minecraft 1.21.x Versionen (1.21, 1.21.1, 1.21.2, 1.21.3, 1.21.4, 1.21.5, 1.21.6, 1.21.7, 1.21.8)
- Systemd Service für automatischen Start beim Booten
- UFW Firewall-Konfiguration
- Optionales automatisches Backup-System (alle 6 Stunden)
- Farbige Terminal-Ausgabe mit Statusmeldungen
- Versions-Verifizierung nach Installation
- Umfassende README-Dokumentation

### Sicherheit
- Dedicated Minecraft-User für Server-Prozess
- Systemd Service mit Sicherheits-Flags (ProtectHome, ProtectSystem, NoNewPrivileges)
- Screen-Session für sichere Konsolen-Verwaltung

## [Unreleased]

### Geplant
- Unterstützung für Paper/Spigot Server
- Plugin-Installation
- Automatische Versions-Updates
- Web-Interface für Verwaltung
