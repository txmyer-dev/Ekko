#!/usr/bin/env bash
# PAI Infrastructure Audit & Migration Tool
# ==========================================
# Reads ~/.claude/MEMORY/STATE/infrastructure.yaml and performs:
#   audit   — grep codebase for each registered pattern, flag unknown consumers
#   show    — print registry summary
#   migrate — update a value across all consumers
#
# Usage:
#   bash ~/.claude/tools/pai-infra.sh show
#   bash ~/.claude/tools/pai-infra.sh audit
#   bash ~/.claude/tools/pai-infra.sh migrate <key> <old_value> <new_value>

set -euo pipefail

REGISTRY="$HOME/.claude/MEMORY/STATE/infrastructure.yaml"
SEARCH_DIRS=(
    "$HOME/.claude"
    "$HOME/My Drive/SecondBrain/Heartbeat"
)
# Exclude patterns for grep — skip generated content, logs, and ephemeral data
EXCLUDE_DIRS="--exclude-dir=.git --exclude-dir=node_modules --exclude-dir=__pycache__ --exclude-dir=shell-snapshots --exclude-dir=SecondBrain-fallback --exclude-dir=LEARNING --exclude-dir=RELATIONSHIP --exclude-dir=WORK --exclude-dir=RESEARCH --exclude-dir=extractions --exclude-dir=fabric-patterns --exclude-dir=algorithms --exclude-dir=plans --exclude-dir=projects --exclude-dir=tasks --exclude-dir=teams --exclude-dir=usage-data --exclude-dir=Clips --exclude-dir=Knowledge --exclude-dir=Sessions --exclude-dir=Inbox --exclude-dir=Templates --exclude-dir=custom-agents --exclude-dir=macos-service"
# Files to always exclude from audit (self-reference, generated, archived)
EXCLUDE_FILES=(
    "$HOME/.claude/MEMORY/STATE/infrastructure.yaml"  # self-reference
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Parse registry YAML (lightweight — no yq dependency)
# ---------------------------------------------------------------------------
get_keys() {
    # Top-level keys (lines that start with a word and end with :)
    grep -E '^[a-z_]+:' "$REGISTRY" | sed 's/:.*//'
}

get_field() {
    local key="$1" field="$2"
    # Extract field value from under a key block
    awk -v key="$key:" -v field="$field:" '
        $0 ~ "^"key { found=1; next }
        found && /^[a-z_]+:/ { found=0 }
        found && $0 ~ "^  "field { gsub(/^  [a-z_]+: *"?/, ""); gsub(/"$/, ""); print; exit }
    ' "$REGISTRY"
}

get_consumers() {
    local key="$1"
    # Extract consumer file paths from under a key block
    awk -v key="$key:" '
        $0 ~ "^"key { found=1; next }
        found && /^[a-z_]+:/ { found=0 }
        found && /- file:/ { gsub(/^.*- file: */, ""); print }
    ' "$REGISTRY"
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_show() {
    echo -e "${BOLD}PAI Infrastructure Registry${NC}"
    echo -e "Source: $REGISTRY"
    echo ""

    for key in $(get_keys); do
        local desc=$(get_field "$key" "description")
        local pattern=$(get_field "$key" "grep_pattern")
        local sensitive=$(get_field "$key" "sensitive")
        local consumer_count=$(get_consumers "$key" | wc -l)

        echo -e "  ${BLUE}${BOLD}$key${NC}"
        echo -e "    ${desc}"
        if [[ "$sensitive" == "true" ]]; then
            echo -e "    Value: ${RED}[REDACTED]${NC}"
        else
            # Show first value field we find
            local val=$(get_field "$key" "value")
            [[ -z "$val" ]] && val=$(get_field "$key" "value_win")
            [[ -z "$val" ]] && val=$(get_field "$key" "value_url")
            [[ -n "$val" ]] && echo -e "    Value: $val"
        fi
        echo -e "    Pattern: ${pattern:-n/a}"
        echo -e "    Consumers: ${consumer_count} files"
        echo ""
    done
}

cmd_audit() {
    echo -e "${BOLD}PAI Infrastructure Audit${NC}"
    echo -e "Scanning: ${SEARCH_DIRS[*]}"
    echo ""

    local total_registered=0
    local total_found=0
    local total_unknown=0

    for key in $(get_keys); do
        local desc=$(get_field "$key" "description")
        local pattern=$(get_field "$key" "grep_pattern")

        if [[ -z "$pattern" ]]; then
            continue
        fi

        echo -e "${BLUE}${BOLD}[$key]${NC} $desc"
        echo -e "  Pattern: '$pattern'"

        # Get registered consumers
        local registered_files=()
        while IFS= read -r f; do
            # Expand ~ to $HOME
            f="${f/#\~/$HOME}"
            registered_files+=("$f")
        done < <(get_consumers "$key")
        total_registered=$((total_registered + ${#registered_files[@]}))

        # Grep for actual references
        local found_files=()
        for dir in "${SEARCH_DIRS[@]}"; do
            if [[ -d "$dir" ]]; then
                while IFS= read -r f; do
                    # Skip excluded files (self-reference, etc.)
                    local skip=false
                    for excl in "${EXCLUDE_FILES[@]}"; do
                        if [[ "$f" == "$excl" ]]; then skip=true; break; fi
                    done
                    # Skip old algorithm versions (archived, not active consumers)
                    if [[ "$f" == *"/Components/Algorithm/v"* && "$f" != *"/v1.6.0.md" ]]; then
                        skip=true
                    fi
                    [[ "$skip" == true ]] && continue
                    found_files+=("$f")
                done < <(grep -rl "$pattern" "$dir" \
                    --include="*.json" --include="*.md" --include="*.sh" \
                    --include="*.ts" --include="*.yaml" --include="*.py" \
                    $EXCLUDE_DIRS 2>/dev/null || true)
            fi
        done
        total_found=$((total_found + ${#found_files[@]}))

        # Build lookup set from registered paths (normalize once)
        declare -A reg_lookup=()
        for reg in "${registered_files[@]}"; do
            # Normalize: lowercase drive letter, forward slashes, collapse //
            local norm="${reg//\\//}"
            norm="${norm,,}"
            reg_lookup["$norm"]=1
        done

        # Compare: registered vs found
        local unknown_count=0
        for found in "${found_files[@]}"; do
            local norm_found="${found//\\//}"
            norm_found="${norm_found,,}"
            if [[ -n "${reg_lookup[$norm_found]:-}" ]]; then
                echo -e "  ${GREEN}✓${NC} $found"
            else
                echo -e "  ${YELLOW}? UNREGISTERED${NC} $found"
                unknown_count=$((unknown_count + 1))
            fi
        done
        total_unknown=$((total_unknown + unknown_count))

        # Check for registered files that no longer match
        for reg in "${registered_files[@]}"; do
            if [[ ! -f "$reg" ]]; then
                echo -e "  ${RED}✗ MISSING${NC} $reg"
            fi
        done

        echo ""
    done

    echo -e "${BOLD}Summary:${NC}"
    echo -e "  Registered consumers: $total_registered"
    echo -e "  Found references:     $total_found"
    if [[ $total_unknown -gt 0 ]]; then
        echo -e "  ${YELLOW}Unregistered:           $total_unknown (add these to infrastructure.yaml)${NC}"
    else
        echo -e "  ${GREEN}Unregistered:           0 (registry is complete)${NC}"
    fi
}

cmd_migrate() {
    local key="$1"
    local old_val="$2"
    local new_val="$3"

    echo -e "${BOLD}PAI Infrastructure Migration${NC}"
    echo -e "Key:       $key"
    echo -e "Old value: $old_val"
    echo -e "New value: $new_val"
    echo ""

    local consumers=()
    while IFS= read -r f; do
        f="${f/#\~/$HOME}"
        consumers+=("$f")
    done < <(get_consumers "$key")

    if [[ ${#consumers[@]} -eq 0 ]]; then
        echo -e "${RED}No consumers found for key '$key'${NC}"
        exit 1
    fi

    local updated=0
    local skipped=0

    for file in "${consumers[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo -e "  ${YELLOW}SKIP${NC} $file (not found)"
            skipped=$((skipped + 1))
            continue
        fi

        if grep -q "$old_val" "$file" 2>/dev/null; then
            # Perform replacement
            sed -i "s|$old_val|$new_val|g" "$file"
            echo -e "  ${GREEN}UPDATED${NC} $file"
            updated=$((updated + 1))
        else
            echo -e "  ${BLUE}NO MATCH${NC} $file (old value not found — may use different format)"
            skipped=$((skipped + 1))
        fi
    done

    echo ""
    echo -e "${BOLD}Results:${NC}"
    echo -e "  Updated: $updated files"
    echo -e "  Skipped: $skipped files"
    echo ""

    # Update the registry itself
    if grep -q "$old_val" "$REGISTRY" 2>/dev/null; then
        sed -i "s|$old_val|$new_val|g" "$REGISTRY"
        echo -e "  ${GREEN}Registry updated${NC}"
    fi

    # Sweep: also replace in ALL matching files across search dirs (catches unregistered consumers)
    echo ""
    echo -e "${BOLD}Sweep (unregistered consumers):${NC}"
    local sweep_count=0
    for dir in "${SEARCH_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r f; do
                # Skip already-updated registered consumers
                local already_done=false
                for c in "${consumers[@]}"; do
                    if [[ "$f" == "$c" ]]; then already_done=true; break; fi
                done
                [[ "$already_done" == true ]] && continue
                # Skip registry self-reference
                [[ "$f" == "$REGISTRY" ]] && continue

                sed -i "s|$old_val|$new_val|g" "$f"
                echo -e "  ${GREEN}SWEPT${NC} $f"
                sweep_count=$((sweep_count + 1))
            done < <(grep -rl "$old_val" "$dir" \
                --include="*.json" --include="*.md" --include="*.sh" \
                --include="*.ts" --include="*.yaml" --include="*.py" \
                $EXCLUDE_DIRS 2>/dev/null || true)
        fi
    done

    if [[ $sweep_count -gt 0 ]]; then
        echo -e "  Sweep updated: $sweep_count additional files"
    else
        echo -e "  ${GREEN}No additional files found.${NC}"
    fi

    echo -e "\n${YELLOW}Run 'pai-infra audit' to verify all references are updated.${NC}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-help}" in
    show)
        cmd_show
        ;;
    audit)
        cmd_audit
        ;;
    migrate)
        if [[ $# -lt 4 ]]; then
            echo "Usage: pai-infra migrate <key> <old_value> <new_value>"
            exit 1
        fi
        cmd_migrate "$2" "$3" "$4"
        ;;
    *)
        echo "PAI Infrastructure Tool"
        echo ""
        echo "Usage:"
        echo "  pai-infra show                          Show all registered infrastructure"
        echo "  pai-infra audit                         Scan codebase, flag unregistered references"
        echo "  pai-infra migrate <key> <old> <new>     Update a value across all consumers"
        echo ""
        echo "Registry: $REGISTRY"
        ;;
esac
