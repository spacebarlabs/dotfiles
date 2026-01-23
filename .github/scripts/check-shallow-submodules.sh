#!/bin/bash

# This script checks that all git submodules in .gitmodules are marked as shallow.
# Exit with error code 1 if any submodule is not shallow.

set -e

GITMODULES_FILE=".gitmodules"
EXIT_CODE=0

echo "Checking that all submodules are marked as shallow..."

# Read .gitmodules and extract submodules
CURRENT_SUBMODULE=""
CURRENT_SHALLOW=""
NON_SHALLOW_SUBMODULES=()

while IFS= read -r line; do
  # Check if we're starting a new submodule section
  if [[ $line =~ ^\[submodule ]]; then
    # If we have a previous submodule, check if it was shallow
    if [[ -n "$CURRENT_SUBMODULE" ]]; then
      if [[ "$CURRENT_SHALLOW" != "true" ]]; then
        NON_SHALLOW_SUBMODULES+=("$CURRENT_SUBMODULE")
        EXIT_CODE=1
      fi
    fi
    
    # Extract submodule name from the line
    CURRENT_SUBMODULE=$(echo "$line" | sed 's/\[submodule "\(.*\)"\]/\1/')
    CURRENT_SHALLOW=""
  elif [[ $line =~ shallow[[:space:]]*=[[:space:]]*true ]]; then
    CURRENT_SHALLOW="true"
  fi
done < "$GITMODULES_FILE"

# Check the last submodule
if [[ -n "$CURRENT_SUBMODULE" ]]; then
  if [[ "$CURRENT_SHALLOW" != "true" ]]; then
    NON_SHALLOW_SUBMODULES+=("$CURRENT_SUBMODULE")
    EXIT_CODE=1
  fi
fi

# Report results
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "✓ All submodules are marked as shallow"
else
  echo "✗ The following submodules are NOT marked as shallow:"
  for submodule in "${NON_SHALLOW_SUBMODULES[@]}"; do
    echo "  - $submodule"
  done
  echo ""
  echo "Please add 'shallow = true' to each submodule in .gitmodules"
fi

exit $EXIT_CODE
