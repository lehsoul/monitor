#!/bin/bash

# Configuration
EMAIL_GROUP="saithejas27@gmail.com"  # Change this to your email group
THRESHOLD=60  # usage threshold in percentage
HOSTNAME=$(hostname)
ALERT_FILE="/tmp/resource_alert.txt"
> "$ALERT_FILE"  # clear previous contents

# RAM usage check
RAM_USAGE=$(free | awk '/Mem/ { printf("%.0f", $3/$2 * 100) }')
if [ "$RAM_USAGE" -ge "$THRESHOLD" ]; then
    echo "⚠️ RAM usage is at ${RAM_USAGE}%" >> "$ALERT_FILE"
fi

# Disk usage check
DISK_ALERT=false
df -h --output=pcent,target | tail -n +2 | while read -r percent mount; do
    usage=$(echo $percent | tr -d '%')
    if [ "$usage" -ge "$THRESHOLD" ]; then
        echo "⚠️ Disk usage on $mount is at $usage%" >> "$ALERT_FILE"
        DISK_ALERT=true
    fi
done

# Check for unused processes (zombie or sleeping > 24h)
ZOMBIES=$(ps -eo stat,etime,pid,cmd | grep -E "^Z" | wc -l)
SLEEPERS=$(ps -eo stat,etime,pid,cmd | awk '$1 ~ /^S/ && $2 ~ /-/{print}' | wc -l)

if [ "$ZOMBIES" -gt 0 ]; then
    echo "⚠️ Found $ZOMBIES zombie processes" >> "$ALERT_FILE"
    ps -eo stat,etime,pid,cmd | grep -E "^Z" >> "$ALERT_FILE"
fi

if [ "$SLEEPERS" -gt 0 ]; then
    echo "⚠️ Found $SLEEPERS sleeping processes running over a day" >> "$ALERT_FILE"
    ps -eo stat,etime,pid,cmd | awk '$1 ~ /^S/ && $2 ~ /-/' >> "$ALERT_FILE"
fi

# Send alert if file has content
if [ -s "$ALERT_FILE" ]; then
    SUBJECT="Alert: Resource usage high on $HOSTNAME"
    mail -s "$SUBJECT" "$EMAIL_GROUP" < "$ALERT_FILE"
fi
