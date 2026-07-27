# Linux SRE Lab 14 - Cron

## Objective

Learn how to automate recurring tasks using `cron` and generate a simple system health report.

---

## Project Structure

```
14-cron/
├── README.md
├── logs/
│   └── health.log
└── scripts/
    └── health-report.sh
```

---

## Health Report Script

The script collects basic system information:

- Current date
- Hostname
- System uptime
- Disk usage
- Memory usage
- Load average

Example:

```bash
#!/bin/bash

echo "========== Health Report =========="
echo "Date:"
date
echo

echo "Hostname:"
hostname
echo

echo "Uptime:"
uptime
echo

echo "Disk Usage:"
df -h /
echo

echo "Memory Usage:"
free -h
echo

echo "Load Average:"
cat /proc/loadavg
echo "==================================="
```

Make the script executable:

```bash
chmod +x scripts/health-report.sh
```

Run it manually:

```bash
./scripts/health-report.sh
```

---

## Cron Job

Edit the crontab:

```bash
crontab -e
```

Example entry:

```cron
* * * * * /home/wojtek/Projects/linux-sre-lab/linux/14-cron/scripts/health-report.sh >> /home/wojtek/Projects/linux-sre-lab/linux/14-cron/logs/health.log 2>&1
```

Verify:

```bash
crontab -l
```

---

## Logs

Check generated logs:

```bash
cat logs/health.log
```

or

```bash
tail -f logs/health.log
```

---

## Bonus - Log Rotation

Install and verify logrotate:

```bash
logrotate --version
```

Create configuration:

```bash
sudo vi /etc/logrotate.d/health-report
```

Configuration:

```conf
/home/wojtek/Projects/linux-sre-lab/linux/14-cron/logs/health.log
{
    daily
    rotate 30
    compress
    missingok
    notifempty
    su wojtek wojtek
    create 0644 wojtek wojtek
}
```

Useful commands:

```bash
sudo logrotate -d /etc/logrotate.d/health-report
sudo logrotate -f /etc/logrotate.d/health-report
```

View archived logs:

```bash
ls -lh logs
zcat logs/health.log.1.gz
```

---

## Commands Used

```bash
crontab -e
crontab -l
chmod +x scripts/health-report.sh
tail -f logs/health.log
logrotate --version
sudo logrotate -d /etc/logrotate.d/health-report
sudo logrotate -f /etc/logrotate.d/health-report
```

---

## Skills Practiced

- Cron scheduling
- Bash scripting
- Output redirection
- Logging
- Linux automation
- Log rotation
- Basic system administration
