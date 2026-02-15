#!/bin/bash
# Test plugin structure validity
# Validates that all plugins follow required conventions

set -e

echo "Testing Smicolon Marketplace Packs"
echo "====================================="
echo ""

ERRORS=0
WARNINGS=0
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "  ${GREEN}✅${NC} $1"
}

fail() {
    echo -e "  ${RED}❌${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "  ${YELLOW}⚠️${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# Test each pack
for plugin in "$ROOT_DIR"/packs/*/; do
    name=$(basename "$plugin")
    echo "Testing $name..."

    # Check agents directory (optional for utility plugins)
    if [ ! -d "$plugin/agents" ]; then
        # Utility packs (like dev-loop) may not have agents
        if [ -d "$plugin/hooks" ] || [ -d "$plugin/commands" ]; then
            pass "Utility plugin (no agents, has hooks/commands)"
        else
            fail "Missing agents directory"
        fi
    else
        agent_count=$(find "$plugin/agents" -name "*.md" | wc -l | tr -d ' ')
        pass "agents directory exists ($agent_count agents)"
    fi

    # Check for README
    if [ ! -f "$plugin/README.md" ]; then
        fail "Missing README.md"
    else
        pass "README.md exists"
    fi

    # Check hooks.json if hooks dir exists
    if [ -d "$plugin/hooks" ]; then
        if [ ! -f "$plugin/hooks/hooks.json" ]; then
            fail "hooks directory exists but no hooks.json"
        else
            # Validate hooks.json is valid JSON
            if python3 -m json.tool "$plugin/hooks/hooks.json" > /dev/null 2>&1; then
                pass "hooks.json exists and is valid JSON"
            else
                fail "hooks.json is invalid JSON"
            fi
        fi
    fi

    # Check skills directory
    if [ -d "$plugin/skills" ]; then
        skill_count=$(find "$plugin/skills" -name "SKILL.md" | wc -l | tr -d ' ')
        pass "skills directory exists ($skill_count skills)"
    fi

    # Check commands directory
    if [ -d "$plugin/commands" ]; then
        command_count=$(find "$plugin/commands" -name "*.md" | wc -l | tr -d ' ')
        pass "commands directory exists ($command_count commands)"
    fi

    # Check rules directory
    if [ -d "$plugin/rules" ]; then
        rules_count=$(find "$plugin/rules" -name "*.md" | wc -l | tr -d ' ')
        pass "rules directory exists ($rules_count rules)"
    fi

    # Check agent frontmatter has skills (where applicable)
    # Skip for utility packs without agents and architect
    if [ -d "$plugin/agents" ] && [ "$name" != "architect" ]; then
        agents_with_skills=0
        for agent in "$plugin/agents"/*.md; do
            if grep -q "^skills:" "$agent" 2>/dev/null; then
                agents_with_skills=$((agents_with_skills + 1))
            fi
        done
        if [ $agents_with_skills -gt 0 ]; then
            pass "Agents have skills frontmatter ($agents_with_skills agents)"
        else
            warn "No agents have skills frontmatter"
        fi
    fi

    echo ""
done

# Validate marketplace.json
echo "Validating marketplace.json..."
MARKETPLACE_FILE="$ROOT_DIR/.claude-plugin/marketplace.json"
if [ -f "$MARKETPLACE_FILE" ]; then
    if python3 -m json.tool "$MARKETPLACE_FILE" > /dev/null 2>&1; then
        pass "Valid JSON format"

        # Check version
        version=$(python3 -c "import json; print(json.load(open('$MARKETPLACE_FILE'))['version'])")
        pass "Marketplace version: $version"

        # Count plugins
        plugin_count=$(python3 -c "import json; print(len(json.load(open('$MARKETPLACE_FILE'))['plugins']))")
        pass "Contains $plugin_count plugins"
    else
        fail "Invalid JSON format"
    fi
else
    fail "marketplace.json not found"
fi

echo ""
echo "====================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️ Tests passed with $WARNINGS warnings${NC}"
else
    echo -e "${RED}❌ $ERRORS errors found, $WARNINGS warnings${NC}"
    exit 1
fi
