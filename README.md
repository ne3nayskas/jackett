# 🛠️ Jackett Wake Script
Automatically "wakes up" Jackett with random search queries. 
Works only daytime (06:30-01:30 Kyiv time).

## 🎯 Purpose
- Jackett API health-check every X minutes (cron)
- Warm up indexers via torznab API
- Detailed logging to `/home/dockeruser/wake_jackett.log`

## ⚙️ Configuration
Jackett API key (Settings -> General -> API Key)
```API_KEY="you_jackett_api_key"```
Search words (add your own)
```SEARCH_WORDS=("minecraft" "matrix" "ukraine" "linux")```

## 📋 Cron Setup
Every 15 minutes daytime
```*/15 6-23 * * * /path/to/wake_jackett.sh```

## 📊 Log Example
`2026-02-19 16:53:42 - Script started by user: dockeruser
2026-02-19 16:53:45 - Query "sonic" successful. HTTP 200, time: 247ms`

## 🚀 Quick Start
```chmod +x wake_jackett.sh```
Set your API_KEY
crontab -e → add cron entry
`./wake_jackett.sh to test`

## 📝 Services
Jackett: localhost:9117
Log: `/home/dockeruser/wake_jackett.log`
