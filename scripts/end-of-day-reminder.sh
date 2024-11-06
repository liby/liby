#!/bin/bash

# Get today's date (format: YYYY-MM-DD)
today=$(date +"%Y-%m-%d")

# Find today's first wake event (excluding DarkWake)
first_wake_time=$(pmset -g log | awk -v today="$today" '$0 ~ today && $0 ~ /Wake from/ && $0 !~ /DarkWake/ {print $1 " " $2; exit}')

# Check if today's wake time was found
if [ -z "$first_wake_time" ]; then
  echo "Unable to find today's wake event."
  exit 1
fi

# Print the first wake time
echo "First wake time: $first_wake_time"

# Convert the first wake time to a timestamp
remind_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$first_wake_time" +%s)
# Add 9 hours and 12 minutes (total 55200 seconds)
remind_time=$(date -r $remind_time -v+9H -v+12M +"%Y-%m-%d %H:%M:%S")

# Print the end-of-day reminder time
echo "End-of-day reminder time: $remind_time"

# Calculate the difference between the current time and the reminder time
current_time=$(date +%s)
delay=$((remind_time - current_time))

# If the reminder time has already passed, do not send a reminder
if [ $delay -le 0 ]; then
  echo "The end-of-day reminder time has passed, no reminder will be sent."
  exit 0
fi

# Send a reminder after the delay
sleep $delay && osascript -e "display notification \"Time to leave work!\" with title \"End-of-Day Reminder\" subtitle \"Current time: $(date +"%H:%M:%S")\""

