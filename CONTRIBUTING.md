# Beitragen

Vielen Dank für dein Interesse, zu diesem Projekt beizutragen! 🎮

## Wie kann ich beitragen?

### Bug Reports

Wenn du einen Bug gefunden hast:

1. Überprüfe, ob der Bug bereits in den [Issues](../../issues) gemeldet wurde
2. Wenn nicht, erstelle ein neues Issue mit:
   - Einer klaren Beschreibung des Problems
   - Schritten zur Reproduktion
   - Erwartetes vs. tatsächliches Verhalten
   - Deine Systemumgebung (OS, Version, etc.)

### Feature Requests

Hast du eine Idee für ein neues Feature?

1. Überprüfe die [Issues](../../issues), ob es bereits vorgeschlagen wurde
2. Erstelle ein neues Issue mit dem Label "enhancement"
3. Beschreibe das Feature und warum es nützlich wäre

### Code-Beiträge

1. **Fork** das Repository
2. Erstelle einen **Feature-Branch** (`git checkout -b feature/mein-feature`)
3. **Committe** deine Änderungen (`git commit -m 'Add: Beschreibung'`)
4. **Push** zum Branch (`git push origin feature/mein-feature`)
5. Erstelle einen **Pull Request**

### Commit-Nachrichten

Bitte verwende aussagekräftige Commit-Nachrichten:

- `Add:` für neue Features
- `Fix:` für Bugfixes
- `Update:` für Änderungen an bestehendem Code
- `Docs:` für Dokumentationsänderungen
- `Refactor:` für Code-Umstrukturierungen

Beispiele:
```
Add: Support für Minecraft 1.22
Fix: Backup-Script Berechtigung
Update: Server-URL für Version 1.21.9
Docs: README Installation erweitert
```

## Code-Style

- Verwende 4 Spaces für Einrückungen in Bash
- Kommentiere komplexe Logik
- Teste deine Änderungen auf einem frischen Debian 12/13 System

## Neue Minecraft-Versionen

Wenn eine neue Minecraft-Version erscheint und du die Server-URL hinzufügen möchtest:

1. Finde die offizielle Server JAR URL auf [minecraft.net/download/server](https://www.minecraft.net/download/server)
2. Füge sie zum `SERVER_URLS` Array im Script hinzu
3. Teste den Download
4. Erstelle einen Pull Request

## Fragen?

Erstelle einfach ein Issue mit dem Label "question"!
