# DevOps Toolkit — Week 01

A collection of shell scripts and configs for managing a Linux server.
Built as part of CSOT DevOps 2026.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/sysreport.sh` | System health monitor |
| `scripts/backup.sh` | Backup a directory to .tar.gz |
| `scripts/log_parser.sh` | Parse nginx/Apache access logs |
| `scripts/user_manager.sh` | Create/delete users from a CSV |
| `scripts/deploy.sh` | Deploy app with nginx + HTTPS |

## How to Run

## Project Structure
- `scripts/` - shell utility scripts
- `systemd/` - systemd unit files
- `nginx/` - nginx configuration

### System Health Monitor
```bash
./scripts/sysreport.sh
```

### Backup
```bash
./scripts/backup.sh <source-dir> <dest-dir>
```

### Log Parser
```bash
./scripts/log_parser.sh <access.log>
```

### User Manager
```bash
./scripts/user_manager.sh <users.csv>
```

### Deploy
```bash
./scripts/deploy.sh
```

## Requirements
- Ubuntu Linux
- nginx
- openssl
- systemd

## License
MIT
