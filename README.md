# 🎮 Minecraft Server Auto-Installer

Ein vollautomatisches Deployment-Script für Minecraft Server auf Debian 12/13 (funktioniert auch auf Ubuntu).

![Bash](https://img.shields.io/badge/Bash-4.0+-green?logo=gnu-bash)
![Debian](https://img.shields.io/badge/Debian-12%2F13-red?logo=debian)
![License](https://img.shields.io/badge/License-MIT-blue)
![Minecraft](https://img.shields.io/badge/Minecraft-1.21.x-brightgreen)

## ✨ Features

- 🚀 **Vollautomatische Installation** – Ein Script, fertig
- 🎯 **Dynamische Versionserkennung** – Fragt nach deiner Client-Version
- 🔄 **Automatische Server-URLs** – Korrekte Download-Links für alle 1.21.x Versionen
- 📊 **Interaktive Konfiguration** – RAM, Spieleranzahl, Gamemode, etc.
- 🛡️ **Sichere Einrichtung** – Eigener Benutzer, Firewall-Konfiguration
- ⚙️ **Systemd-Integration** – Automatischer Start beim Booten
- 💾 **Automatische Backups** – Optional alle 6 Stunden
- 📈 **Status-Übersicht** – Detaillierte Prüfung am Ende

## 📋 Voraussetzungen

- Debian 12/13 oder Ubuntu 22.04+
- Root/Sudo-Zugriff
- Mindestens 2 GB RAM (4 GB empfohlen)
- Mindestens 10 GB freier Speicherplatz
- Internetverbindung

## 🚀 Schnellstart

```bash
# Repository klonen
git clone https://github.com/DEIN-USERNAME/minecraft-server-installer.git
cd minecraft-server-installer

# Script ausführbar machen
chmod +x minecraft-server-install.sh

# Script starten (NICHT als root!)
./minecraft-server-install.sh
```

## 📖 Verwendung

### Installation

Das Script führt dich interaktiv durch die Konfiguration:

1. **RAM-Zuteilung** – Wie viel Arbeitsspeicher für den Server
2. **Maximale Spieler** – Wie viele Spieler gleichzeitig
3. **Server-Name (MOTD)** – Wird in der Serverliste angezeigt
4. **Schwierigkeit** – Peaceful, Easy, Normal, Hard
5. **Spielmodus** – Survival, Creative, Adventure
6. **PvP** – Spieler vs Spieler aktivieren/deaktivieren
7. **Online-Mode** – Original-Accounts oder Cracked Clients
8. **Backups** – Automatische Sicherungen aktivieren
9. **Minecraft-Version** – Passend zu deinem Client

### Nach der Installation

```bash
# Server-Status prüfen
sudo systemctl status minecraft.service

# Server stoppen
sudo systemctl stop minecraft.service

# Server starten
sudo systemctl start minecraft.service

# Server neustarten
sudo systemctl restart minecraft.service

# Logs anzeigen
sudo journalctl -u minecraft.service -f

# Server-Konsole öffnen
sudo -u minecraft screen -r minecraft
# Konsole verlassen: Ctrl+A, dann D
```

### Manuelles Backup

```bash
sudo -u minecraft /opt/minecraft/backup.sh
```

Backups werden gespeichert in: `/opt/minecraft/backups/`

## 🗂️ Verzeichnisstruktur

Nach der Installation:

```
/opt/minecraft/
├── server.jar          # Minecraft Server JAR
├── server.properties   # Server-Konfiguration
├── eula.txt           # EULA (automatisch akzeptiert)
├── world/             # Weltdaten
├── logs/              # Server-Logs
├── backup.sh          # Backup-Script (optional)
└── backups/           # Backup-Verzeichnis (optional)
```

## ⚙️ Konfiguration

### server.properties

Die wichtigsten Einstellungen:

| Einstellung | Beschreibung | Standard |
|-------------|--------------|----------|
| `server-port` | Server-Port | 25565 |
| `max-players` | Max. Spieler | Interaktiv |
| `difficulty` | Schwierigkeit | Interaktiv |
| `gamemode` | Spielmodus | Interaktiv |
| `pvp` | PvP aktiviert | Interaktiv |
| `online-mode` | Account-Prüfung | Interaktiv |
| `motd` | Server-Beschreibung | Interaktiv |

Konfiguration bearbeiten:

```bash
sudo -u minecraft nano /opt/minecraft/server.properties
sudo systemctl restart minecraft.service
```

### RAM anpassen

Bearbeite die Systemd-Service-Datei:

```bash
sudo nano /etc/systemd/system/minecraft.service
```

Ändere die `-Xmx` und `-Xms` Werte:

```ini
ExecStart=/usr/bin/java -Xmx4G -Xms4G -jar server.jar nogui
```

Dann:

```bash
sudo systemctl daemon-reload
sudo systemctl restart minecraft.service
```

## 🔥 Firewall

Das Script konfiguriert automatisch UFW. Falls du eine andere Firewall verwendest:

```bash
# iptables
sudo iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 25565 -j ACCEPT

# firewalld
sudo firewall-cmd --permanent --add-port=25565/tcp
sudo firewall-cmd --permanent --add-port=25565/udp
sudo firewall-cmd --reload
```

## 🌐 Netzwerk-Konfiguration

### Lokales Netzwerk

Verbinde dich über: `SERVER-IP:25565`

### Internet-Zugang

1. **Port-Forwarding** im Router einrichten (Port 25565 → Server-IP)
2. **Dynamisches DNS** einrichten (z.B. DuckDNS, No-IP)
3. Oder eigene Domain mit A-Record auf deine öffentliche IP

### Reverse Proxy (nicht empfohlen)

⚠️ Minecraft verwendet ein binäres Protokoll über TCP. Standard-Reverse-Proxies wie Nginx funktionieren **nicht** für den Spielverkehr. Verwende direkte Port-Weiterleitung.

## 🔧 Troubleshooting

### Server startet nicht

```bash
# Logs prüfen
sudo journalctl -u minecraft.service -n 50

# Java prüfen
java -version

# Berechtigungen prüfen
ls -la /opt/minecraft/
```

### Version stimmt nicht überein

Das Script fragt nach deiner Client-Version. Stelle sicher, dass Server und Client die **exakt gleiche** Version verwenden (z.B. beide 1.21.8).

### Verbindung fehlgeschlagen

```bash
# Port prüfen
sudo netstat -tlnp | grep 25565

# Firewall prüfen
sudo ufw status

# Von außen testen
nc -zv SERVER-IP 25565
```

### Out of Memory

Erhöhe den RAM in der Service-Datei (siehe Konfiguration oben).

## 🔄 Updates

### Server-Version aktualisieren

```bash
# Server stoppen
sudo systemctl stop minecraft.service

# Backup erstellen
sudo -u minecraft cp /opt/minecraft/server.jar /opt/minecraft/server.jar.backup

# Neue Version herunterladen (URL von minecraft.net/download/server)
sudo -u minecraft wget -O /opt/minecraft/server.jar "NEUE_SERVER_JAR_URL"

# Server starten
sudo systemctl start minecraft.service
```

## 📊 Unterstützte Versionen

| Version | Status | URL verfügbar |
|---------|--------|---------------|
| 1.21 | ✅ | Ja |
| 1.21.1 | ✅ | Ja |
| 1.21.2 | ✅ | Ja |
| 1.21.3 | ✅ | Ja |
| 1.21.4 | ✅ | Ja |
| 1.21.8 | ✅ | Ja |

Neue Versionen können durch Eingabe der Client-Version automatisch erkannt werden.

## 📝 Lizenz

MIT License – siehe [LICENSE](LICENSE)

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/NeuesFeature`)
3. Committe deine Änderungen (`git commit -m 'Add: Neues Feature'`)
4. Push zum Branch (`git push origin feature/NeuesFeature`)
5. Öffne einen Pull Request

## ⚠️ Disclaimer

Dieses Script ist nicht mit Mojang oder Microsoft verbunden. Minecraft ist eine eingetragene Marke von Mojang Studios.

---

**Made with ❤️ for the Homelab Community**
