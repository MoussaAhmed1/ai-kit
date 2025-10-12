#!/bin/bash
# Smicolon Post-Write Visual Testing Hook
# Suggests visual testing for frontend files

FILE_PATH="$1"

# Only run for frontend component files
if [[ ! "$FILE_PATH" =~ \.(tsx|jsx)$ ]]; then
    exit 0
fi

# Check if it's a component (contains JSX/TSX)
if ! grep -q "return (" "$FILE_PATH" 2>/dev/null; then
    exit 0
fi

# Check if it's a page or component that should be visually tested
if [[ "$FILE_PATH" =~ (components|app|pages|features)/ ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📸 Visual Testing Recommendation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "New frontend component created: $(basename "$FILE_PATH")"
    echo ""
    echo "Consider using @frontend-visual agent to verify:"
    echo "  • Pixel-perfect implementation"
    echo "  • Responsive behavior"
    echo "  • Visual states (hover, focus, disabled)"
    echo "  • Accessibility"
    echo ""
    echo "Quick start:"
    echo "  1. Start dev server: npm run dev"
    echo "  2. Use @frontend-visual agent"
    echo "  3. Agent will use Playwright MCP to capture and verify"
    echo ""
fi
