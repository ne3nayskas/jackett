#!/bin/bash
# Налаштування часової зони (UTC+3 для Києва)
export TZ="Europe/Kyiv"
CURRENT_HOUR=$(date +%H)
CURRENT_MINUTE=$(date +%M)

# Логування часу для налагодження
echo "$(date '+%Y-%m-%d %H:%M:%S') - DEBUG: Час сервера (UTC+3): $(date '+%H:%M:%S %Z')" >> /home/dockeruser/wake_jackett.log

# Визначаємо "нічний" час (01:30-06:30 за Києвом)
if { [ "$CURRENT_HOUR" -eq 1 ] && [ "$CURRENT_MINUTE" -ge 30 ]; } || \
   { [ "$CURRENT_HOUR" -ge 2 ] && [ "$CURRENT_HOUR" -le 5 ]; } || \
   { [ "$CURRENT_HOUR" -eq 6 ] && [ "$CURRENT_MINUTE" -lt 30 ]; }; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Зараз нічний час (01:30-06:30 за Києвом). Скрипт не працює." >> /home/dockeruser/wake_jackett.log
    exit 0
fi

# Основна логіка скрипта
API_KEY="ВАШ_API_KEY"
SEARCH_WORDS=("minecraft" "matrix" "venom" "marvel" "sonic" "doom" "avengers")
QUERY=${SEARCH_WORDS[$RANDOM % ${#SEARCH_WORDS[@]}]}
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER=$(whoami)
URL="http://localhost:9117/api/v2.0/indexers/all/results/torznab/api?apikey=$API_KEY&q=$QUERY"

# Перевірка доступності Jackett
if ! curl -s --max-time 5 http://localhost:9117 >/dev/null; then
    echo "$TIMESTAMP - Помилка: Jackett не відповідає" >> /home/dockeruser/wake_jackett.log
    exit 1
fi

echo "$TIMESTAMP - Скрипт запущено від користувача: $USER, роблю запит: $URL" >> /home/dockeruser/wake_jackett.log

# Вимірювання часу виконання
START_TIME=$(date +%s%3N)
HTTP_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" --max-time 30 "$URL")
HTTP_CODE=$(echo "$HTTP_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

# Обробка результату
if [ "$HTTP_CODE" -eq 200 ]; then
  echo "$TIMESTAMP - Запит з словом \"$QUERY\" пройшов успішно. HTTP $HTTP_CODE, час: ${DURATION}мс" >> /home/dockeruser/wake_jackett.log
else
  echo "$TIMESTAMP - Помилка при запиті з словом \"$QUERY\". HTTP код: $HTTP_CODE, час: ${DURATION}мс, відповідь: ${HTTP_RESPONSE:0:200}..." >> /home/dockeruser/wake_jackett.log
fi
