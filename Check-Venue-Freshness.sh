#!/bin/bash
# check-venues-freshness.sh
# Runs as an Xcode Build Phase. Warns if DanceHalls.json's `lastUpdated`
# field is more than 6 months in the past, reminding the dev to audit
# venue addresses, descriptions, and closures.
#
# To install:
#   1. Xcode → blue project icon → target → Build Phases
#   2. Click + → New Run Script Phase
#   3. Name it "Check Venue Freshness"
#   4. Paste: bash "${SRCROOT}/check-venues-freshness.sh"
#   5. Drag the phase above "Copy Bundle Resources"

set -e

JSON_PATH="${SRCROOT}/DanceHalls.json"

if [ ! -f "$JSON_PATH" ]; then
  echo "warning: DanceHalls.json not found at $JSON_PATH — cannot verify freshness"
  exit 0
fi

# Extract the lastUpdated date from the JSON. Expected format: "YYYY-MM-DD".
LAST_UPDATED=$(grep -o '"lastUpdated"[[:space:]]*:[[:space:]]*"[^"]*"' "$JSON_PATH" \
  | head -1 \
  | sed -E 's/.*"([0-9]{4}-[0-9]{2}-[0-9]{2})".*/\1/')

if [ -z "$LAST_UPDATED" ]; then
  echo "warning: could not parse lastUpdated from DanceHalls.json"
  exit 0
fi

# Convert to epoch seconds. macOS `date` uses -j -f for input parsing.
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" 2>/dev/null || echo "0")
NOW_EPOCH=$(date "+%s")

if [ "$LAST_EPOCH" -eq 0 ]; then
  echo "warning: could not parse lastUpdated '$LAST_UPDATED' as a date"
  exit 0
fi

SIX_MONTHS_SECONDS=$((60 * 60 * 24 * 183))   # ~6 months
AGE_SECONDS=$((NOW_EPOCH - LAST_EPOCH))

if [ "$AGE_SECONDS" -gt "$SIX_MONTHS_SECONDS" ]; then
  AGE_DAYS=$((AGE_SECONDS / 86400))
  # Emit an Xcode-recognized warning. The "warning:" prefix on its own line
  # makes Xcode surface this in the issue navigator.
  echo "warning: DanceHalls.json was last updated $LAST_UPDATED ($AGE_DAYS days ago)."
  echo "warning: Audit the venue master list — addresses, descriptions, and closures."
  echo "warning: After auditing, update the lastUpdated field in DanceHalls.json."
fi

exit 0
