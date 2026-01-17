#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# wt.sh - Git Worktree Manager
# Naming: ~/code/project/ → ~/code/project--branch-name/
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helpers
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }

# Get repo root and name (finds main worktree, not current worktree)
get_repo_info() {
    # First check we're in a git repo
    git rev-parse --show-toplevel &>/dev/null || {
        error "Not in a git repository"
        exit 1
    }

    # Get the main worktree (first line of git worktree list)
    REPO_ROOT=$(git worktree list --porcelain | grep "^worktree " | head -1 | sed 's/^worktree //')

    if [[ -z "$REPO_ROOT" ]]; then
        error "Could not determine main worktree"
        exit 1
    fi

    REPO_NAME=$(basename "$REPO_ROOT")
    REPO_PARENT=$(dirname "$REPO_ROOT")
}

# Detect package manager
detect_pkg_manager() {
    local dir="${1:-$REPO_ROOT}"
    if [[ -f "$dir/bun.lockb" ]] || [[ -f "$dir/bun.lock" ]]; then
        echo "bun"
    elif [[ -f "$dir/pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "$dir/yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "$dir/package-lock.json" ]] || [[ -f "$dir/package.json" ]]; then
        echo "npm"
    else
        echo ""
    fi
}

# Detect if monorepo
is_monorepo() {
    local dir="${1:-$REPO_ROOT}"
    # Check for monorepo indicators
    [[ -f "$dir/pnpm-workspace.yaml" ]] && return 0
    [[ -f "$dir/turbo.json" ]] && return 0
    [[ -f "$dir/nx.json" ]] && return 0
    [[ -f "$dir/lerna.json" ]] && return 0
    # Check for workspaces in package.json
    if [[ -f "$dir/package.json" ]]; then
        grep -q '"workspaces"' "$dir/package.json" 2>/dev/null && return 0
    fi
    return 1
}

# Copy .env files from source to destination
copy_env_files() {
    local src="$1"
    local dst="$2"
    local count=0

    # Copy root .env* files
    for envfile in "$src"/.env*; do
        [[ -f "$envfile" ]] || continue
        local filename=$(basename "$envfile")
        cp "$envfile" "$dst/$filename"
        ((count++))
    done

    # Copy nested .env* files from common monorepo directories
    for subdir in apps packages services libs modules; do
        [[ -d "$src/$subdir" ]] || continue
        for app_dir in "$src/$subdir"/*/; do
            [[ -d "$app_dir" ]] || continue
            local app_name=$(basename "$app_dir")
            for envfile in "$app_dir".env*; do
                [[ -f "$envfile" ]] || continue
                local filename=$(basename "$envfile")
                # Ensure target directory exists
                mkdir -p "$dst/$subdir/$app_name"
                cp "$envfile" "$dst/$subdir/$app_name/$filename"
                ((count++))
            done
        done
    done

    echo "$count"
}

# Get worktree path from branch name
get_worktree_path() {
    local branch="$1"
    # Replace slashes with dashes for branch names like feature/auth
    local safe_branch="${branch//\//-}"
    echo "${REPO_PARENT}/${REPO_NAME}--${safe_branch}"
}

# Strip main repo name prefix from worktree basename
get_branch_from_worktree() {
    local wt_path="$1"
    local wt_name=$(basename "$wt_path")
    # Remove the repo name prefix and --
    echo "${wt_name#${REPO_NAME}--}"
}

# =============================================================================
# Commands
# =============================================================================

cmd_create() {
    local branch="${1:-}"

    if [[ -z "$branch" ]]; then
        error "Usage: wt create <branch-name>"
        echo "  Creates a new worktree for the given branch"
        exit 1
    fi

    get_repo_info
    local wt_path=$(get_worktree_path "$branch")

    if [[ -d "$wt_path" ]]; then
        error "Worktree already exists: $wt_path"
        exit 1
    fi

    info "Creating worktree for branch: $branch"

    # Check if branch exists (local or remote)
    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        info "Checking out existing local branch: $branch"
        git worktree add "$wt_path" "$branch"
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
        info "Checking out existing remote branch: origin/$branch"
        git worktree add "$wt_path" "$branch"
    else
        info "Creating new branch: $branch"
        git worktree add -b "$branch" "$wt_path"
    fi
    success "Worktree created at: $wt_path"

    # Copy .env files
    info "Copying .env files..."
    local env_count=$(copy_env_files "$REPO_ROOT" "$wt_path")
    if [[ "$env_count" -gt 0 ]]; then
        success "Copied $env_count .env file(s)"
    else
        warn "No .env files found to copy"
    fi

    # Detect and run package manager install
    local pkg_mgr=$(detect_pkg_manager "$wt_path")
    if [[ -n "$pkg_mgr" ]]; then
        info "Detected package manager: $pkg_mgr"

        if is_monorepo "$wt_path"; then
            info "Monorepo detected, installing at root..."
        fi

        info "Running $pkg_mgr install..."
        cd "$wt_path"
        case "$pkg_mgr" in
            bun)  bun install ;;
            pnpm) pnpm install ;;
            yarn) yarn install ;;
            npm)  npm install ;;
        esac
        success "Dependencies installed"
    fi

    echo ""
    success "Worktree ready!"
    echo ""
    echo -e "${GREEN}cd ${wt_path}${NC}"
}

cmd_list() {
    get_repo_info

    info "Worktrees for: $REPO_NAME"
    echo ""

    # Get all worktrees
    local found=0
    while IFS= read -r line; do
        # Parse worktree output (format: "path HEAD branch")
        local wt_path=$(echo "$line" | awk '{print $1}')
        local wt_branch=$(echo "$line" | awk '{print $3}' | sed 's/\[//;s/\]//')

        if [[ "$wt_path" == "$REPO_ROOT" ]]; then
            echo -e "  ${BLUE}●${NC} $wt_path ${GREEN}(main)${NC}"
        else
            local branch_display=$(get_branch_from_worktree "$wt_path")
            echo -e "  ${YELLOW}○${NC} $wt_path ${YELLOW}($branch_display)${NC}"
        fi
        ((found++))
    done < <(git worktree list --porcelain | grep "^worktree " | sed 's/^worktree //')

    if [[ "$found" -eq 0 ]]; then
        warn "No worktrees found"
    fi
    echo ""
}

cmd_remove() {
    local branch="${1:-}"
    local delete_branch=false

    # Check for --delete-branch flag
    if [[ "${2:-}" == "--delete-branch" ]] || [[ "${2:-}" == "-d" ]]; then
        delete_branch=true
    fi

    if [[ -z "$branch" ]]; then
        error "Usage: wt remove <branch-name> [--delete-branch|-d]"
        echo "  Removes the worktree for the given branch"
        echo "  --delete-branch, -d: Also delete the git branch"
        exit 1
    fi

    get_repo_info
    local wt_path=$(get_worktree_path "$branch")

    if [[ ! -d "$wt_path" ]]; then
        error "Worktree not found: $wt_path"
        exit 1
    fi

    info "Removing worktree: $wt_path"
    git worktree remove "$wt_path" --force
    success "Worktree removed"

    if [[ "$delete_branch" == true ]]; then
        info "Deleting branch: $branch"
        git branch -D "$branch" 2>/dev/null || warn "Branch not found or already deleted"
        success "Branch deleted"
    fi
}

cmd_open() {
    local branch=""
    local editor=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --cursor|-c)
                editor="cursor"
                shift
                ;;
            --agy|-a)
                editor="agy"
                shift
                ;;
            --code|-v)
                editor="code"
                shift
                ;;
            -*)
                error "Unknown option: $1"
                exit 1
                ;;
            *)
                branch="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$branch" ]]; then
        error "Usage: wt open <branch-name> [--cursor|-c] [--agy|-a] [--code|-v]"
        echo "  Opens the worktree in specified editor (auto-detects if not specified)"
        exit 1
    fi

    get_repo_info
    local wt_path=$(get_worktree_path "$branch")

    if [[ ! -d "$wt_path" ]]; then
        error "Worktree not found: $wt_path"
        echo "  Run 'wt create $branch' first"
        exit 1
    fi

    # Priority: flag > WT_EDITOR env > auto-detect
    if [[ -z "$editor" && -n "${WT_EDITOR:-}" ]]; then
        editor="$WT_EDITOR"
    fi

    if [[ -n "$editor" ]]; then
        if ! command -v "$editor" &>/dev/null; then
            error "$editor not found in PATH"
            exit 1
        fi
        info "Opening in $editor: $wt_path"
        "$editor" "$wt_path"
    else
        # Auto-detect: Cursor → Antigravity → VS Code
        if command -v cursor &>/dev/null; then
            info "Opening in Cursor: $wt_path"
            cursor "$wt_path"
        elif command -v agy &>/dev/null; then
            info "Opening in Antigravity: $wt_path"
            agy "$wt_path"
        elif command -v code &>/dev/null; then
            info "Opening in VS Code: $wt_path"
            code "$wt_path"
        else
            error "No supported editor found (cursor, agy, code)"
            exit 1
        fi
    fi
    success "Opened!"
}

cmd_help() {
    echo "wt - Git Worktree Manager"
    echo ""
    echo "Usage: wt <command> [args]"
    echo ""
    echo "Commands:"
    echo "  create, c <branch>     Create worktree, copy .env files, install deps"
    echo "  list, ls               List all worktrees for current repo"
    echo "  remove, rm <branch>    Remove worktree (add -d to delete branch too)"
    echo "  open, o <branch>       Open worktree (flag > WT_EDITOR > auto-detect)"
    echo "                         Options: --cursor|-c, --agy|-a, --code|-v"
    echo "  help, -h, --help       Show this help"
    echo ""
    echo "Environment:"
    echo "  WT_EDITOR              Default editor (cursor, agy, code)"
    echo ""
    echo "Naming convention:"
    echo "  ~/code/project/              → main repo"
    echo "  ~/code/project--feat-auth/   → worktree for feat-auth branch"
    echo ""
    echo "Examples:"
    echo "  wt create feature/authentication"
    echo "  wt c feat-payments"
    echo "  wt ls"
    echo "  wt rm feature/authentication"
    echo "  wt rm feat-payments -d"
    echo "  wt o feat-payments"
    echo "  wt o feat-payments --agy"
    echo "  WT_EDITOR=agy wt o feat-payments"
}

# =============================================================================
# Main
# =============================================================================

main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        create|c)
            cmd_create "$@"
            ;;
        list|ls)
            cmd_list "$@"
            ;;
        remove|rm)
            cmd_remove "$@"
            ;;
        open|o)
            cmd_open "$@"
            ;;
        help|-h|--help)
            cmd_help
            ;;
        *)
            error "Unknown command: $cmd"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
