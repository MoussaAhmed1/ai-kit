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
CYAN='\033[0;36m'
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
    [[ -f "$dir/pnpm-workspace.yaml" ]] && return 0
    [[ -f "$dir/turbo.json" ]] && return 0
    [[ -f "$dir/nx.json" ]] && return 0
    [[ -f "$dir/lerna.json" ]] && return 0
    if [[ -f "$dir/package.json" ]]; then
        grep -q '"workspaces"' "$dir/package.json" 2>/dev/null && return 0
    fi
    return 1
}

# Get worktree path from branch name
get_worktree_path() {
    local branch="$1"
    local safe_branch="${branch//\//-}"
    echo "${REPO_PARENT}/${REPO_NAME}--${safe_branch}"
}

# Strip main repo name prefix from worktree basename
get_branch_from_worktree() {
    local wt_path="$1"
    local wt_name=$(basename "$wt_path")
    echo "${wt_name#${REPO_NAME}--}"
}

# =============================================================================
# Phase 1: .worktreeinclude Parsing & File Copying
# =============================================================================

# Generate default .worktreeinclude if it doesn't exist
generate_default_worktreeinclude() {
    local target="$REPO_ROOT/.worktreeinclude"
    [[ -f "$target" ]] && return 0

    cat > "$target" << 'TEMPLATE'
# .worktreeinclude — Files to copy to new worktrees
# Commit this file so your team shares the same config
.env*

# Monorepo (uncomment as needed)
# apps/*/.env*
# packages/*/.env*
# services/*/.env*

[rewrite]
auto

[docker]
auto
# file=apps/backend/docker-compose.local.yml
# port_offset=10
TEMPLATE
    info "Generated .worktreeinclude (commit this file)"
}

# Parse .worktreeinclude into 3 arrays: file patterns, rewrite lines, docker lines
parse_worktreeinclude() {
    local include_file="$REPO_ROOT/.worktreeinclude"
    WT_FILE_PATTERNS=()
    WT_REWRITE_LINES=()
    WT_DOCKER_LINES=()

    [[ -f "$include_file" ]] || return 0

    local current_section="files"
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Strip trailing whitespace
        line="${line%"${line##*[![:space:]]}"}"
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" == \#* ]] && continue

        # Detect section headers
        if [[ "$line" == "[rewrite]" ]]; then
            current_section="rewrite"
            continue
        elif [[ "$line" == "[docker]" ]]; then
            current_section="docker"
            continue
        fi

        case "$current_section" in
            files)   WT_FILE_PATTERNS+=("$line") ;;
            rewrite) WT_REWRITE_LINES+=("$line") ;;
            docker)  WT_DOCKER_LINES+=("$line") ;;
        esac
    done < "$include_file"
}

# Expand glob patterns against main worktree, return matched files (relative paths)
match_files_by_patterns() {
    local src="$1"
    MATCHED_FILES=()

    for pattern in "${WT_FILE_PATTERNS[@]}"; do
        # Use subshell with nullglob to safely expand globs
        while IFS= read -r -d '' file; do
            local rel="${file#"$src"/}"
            MATCHED_FILES+=("$rel")
        done < <(
            cd "$src"
            shopt -s nullglob
            shopt -s globstar 2>/dev/null || true  # bash 4+ only, needed for **
            for f in $pattern; do
                [[ -f "$f" ]] && printf '%s\0' "$src/$f"
            done
        )
    done
}

# Copy matched files preserving directory structure
copy_matched_files() {
    local src="$1"
    local dst="$2"
    local count=0

    for rel in "${MATCHED_FILES[@]+"${MATCHED_FILES[@]}"}"; do
        local dir=$(dirname "$rel")
        [[ "$dir" != "." ]] && mkdir -p "$dst/$dir"
        cp "$src/$rel" "$dst/$rel"
        ((count++))
    done

    echo "$count"
}

# =============================================================================
# Phase 2: Env Var Rewriting
# =============================================================================

# Branch name → safe slug for suffixing (lowercase, special chars → _, max 30)
sanitize_branch_for_suffix() {
    local branch="$1"
    local slug
    slug=$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')
    # Trim leading/trailing underscores
    slug="${slug#_}"
    slug="${slug%_}"
    # Truncate to 30 chars
    printf '%s' "${slug:0:30}"
}

# Rewrite a single .env file — auto-detect known keys + template {{BRANCH}}
rewrite_env_file() {
    local env_file="$1"
    local branch_slug="$2"
    [[ -f "$env_file" ]] || return 0
    local has_auto=false

    # Check if auto mode is enabled
    for line in "${WT_REWRITE_LINES[@]}"; do
        [[ "$line" == "auto" ]] && has_auto=true
    done

    local tmpfile
    tmpfile=$(mktemp)
    local changed=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        local newline="$line"

        # Template: replace {{BRANCH}} placeholders
        if [[ "$line" == *'{{BRANCH}}'* ]]; then
            newline="${line//\{\{BRANCH\}\}/$branch_slug}"
            changed=true
        elif [[ "$has_auto" == true ]]; then
            # Auto-detect known keys (only lines with = that aren't comments)
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*) ]]; then
                local key="${BASH_REMATCH[1]}"
                local val="${BASH_REMATCH[2]}"
                # Strip surrounding quotes from val for processing
                local raw_val="$val"
                raw_val="${raw_val#\"}"
                raw_val="${raw_val%\"}"
                raw_val="${raw_val#\'}"
                raw_val="${raw_val%\'}"

                case "$key" in
                    DB_NAME|POSTGRES_DB|MYSQL_DATABASE|DATABASE_NAME)
                        # Suffix the value
                        newline="${key}=${raw_val}_${branch_slug}"
                        changed=true
                        ;;
                    DATABASE_URL|POSTGRES_URL)
                        # Parse URL: scheme://user:pass@host:port/dbname?params
                        # Suffix the database name portion
                        if [[ "$raw_val" =~ ^(.*://[^/]*/?)([^?]+)(.*) ]]; then
                            local prefix="${BASH_REMATCH[1]}"
                            local dbname="${BASH_REMATCH[2]}"
                            local suffix="${BASH_REMATCH[3]}"
                            newline="${key}=${prefix}${dbname}_${branch_slug}${suffix}"
                            changed=true
                        fi
                        ;;
                    COMPOSE_PROJECT_NAME)
                        newline="${key}=${raw_val}_${branch_slug}"
                        changed=true
                        ;;
                esac
            fi
        fi

        printf '%s\n' "$newline"
    done < "$env_file" > "$tmpfile"

    if [[ "$changed" == true ]]; then
        mv "$tmpfile" "$env_file"
    else
        rm -f "$tmpfile"
    fi

    echo "$changed"
}

# Find and rewrite all .env* files in the worktree
rewrite_all_env_files() {
    local wt_path="$1"
    local branch_slug="$2"
    local count=0

    # Only proceed if there are rewrite lines configured
    [[ ${#WT_REWRITE_LINES[@]} -gt 0 ]] || return 0

    while IFS= read -r -d '' env_file; do
        local basename_f
        basename_f=$(basename "$env_file")
        # Only process .env* files (not .envrc or similar non-env files)
        [[ "$basename_f" == .env* ]] || continue
        local result
        result=$(rewrite_env_file "$env_file" "$branch_slug")
        [[ "$result" == "true" ]] && ((count++))
    done < <(find "$wt_path" -type f -name '.env*' -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 2>/dev/null)

    echo "$count"
}

# =============================================================================
# Phase 3: Docker Compose Isolation
# =============================================================================

# Deterministic port offset from branch name (1-100 range via cksum)
branch_to_port_offset() {
    local branch="$1"
    local hash
    hash=$(printf '%s' "$branch" | cksum | awk '{print $1}')
    echo $(( (hash % 100) + 1 ))
}

# Minimal YAML parser: extract host ports from docker-compose services
# Uses indentation-aware state machine — no exclusion list needed
# Output format: service_name:host_port:container_port (one per line)
parse_docker_compose_ports() {
    local compose_file="$1"
    awk '
    {
        # Calculate indent level (number of leading spaces)
        indent = 0
        for (i = 1; i <= length($0); i++) {
            if (substr($0, i, 1) == " ") indent++
            else break
        }
        line = $0
        gsub(/^[[:space:]]+/, "", line)
        gsub(/[[:space:]]+$/, "", line)

        # Skip blank lines and comments
        if (line == "" || substr(line, 1, 1) == "#") next
    }

    # "services:" at indent 0 → enter services block
    indent == 0 && line == "services:" {
        in_services = 1
        next
    }

    # Any other indent-0 key → leave services block
    indent == 0 && /^[a-zA-Z]/ {
        in_services = 0
        next
    }

    # Service name = indent-2 key inside services block
    in_services && indent == 2 && /^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_-]*:/ {
        svc = line
        gsub(/:.*/, "", svc)
        current_service = svc
        in_ports = 0
        next
    }

    # "ports:" at indent 4 inside a service
    in_services && indent == 4 && line == "ports:" {
        in_ports = 1
        next
    }

    # Any other indent-4 key → leave ports
    in_services && indent == 4 && line != "ports:" {
        in_ports = 0
        next
    }

    # Port entry at indent 6 (list item under ports)
    in_ports && indent == 6 && /^[[:space:]]*-[[:space:]]*"?[0-9]/ {
        entry = line
        gsub(/^-[[:space:]]*/, "", entry)
        gsub(/"/, "", entry)
        gsub(/[[:space:]].*/, "", entry)
        # entry is now like "5432:5432" or "8025:8025"
        split(entry, parts, ":")
        if (length(parts) >= 2) {
            print current_service ":" parts[1] ":" parts[2]
        }
        next
    }
    ' "$compose_file"
}

# Detect compose file path — checks [docker] file= directive, then auto-detects
detect_compose_file() {
    local wt_path="$1"
    local compose_file=""

    # Check for file= directive in [docker] config
    for line in "${WT_DOCKER_LINES[@]}"; do
        if [[ "$line" =~ ^file=(.+) ]]; then
            local specified="${BASH_REMATCH[1]}"
            specified="${specified#"${specified%%[![:space:]]*}"}"  # trim leading
            specified="${specified%"${specified##*[![:space:]]}"}"  # trim trailing
            if [[ -f "$wt_path/$specified" ]]; then
                echo "$specified"
                return 0
            else
                warn "Specified compose file not found: $specified"
            fi
        fi
    done

    # Auto-detect in standard locations
    local candidates=(
        "local.yml"
        "docker-compose.local.yml"
        "docker-compose.yml"
        "docker-compose.yaml"
        "compose.yml"
        "compose.yaml"
    )

    # Check root first
    for candidate in "${candidates[@]}"; do
        if [[ -f "$wt_path/$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    # Check nested app directories
    for subdir in apps services; do
        [[ -d "$wt_path/$subdir" ]] || continue
        for app_dir in "$wt_path/$subdir"/*/; do
            [[ -d "$app_dir" ]] || continue
            for candidate in "${candidates[@]}"; do
                if [[ -f "$app_dir$candidate" ]]; then
                    local rel="${app_dir#"$wt_path"/}$candidate"
                    echo "$rel"
                    return 0
                fi
            done
        done
    done

    return 1
}

# Generate docker-compose.worktree.yml override with port offsets
generate_docker_compose_override() {
    local compose_file="$1"  # full path to original compose file
    local offset="$2"
    local override_dir
    override_dir=$(dirname "$compose_file")
    local override_file="$override_dir/docker-compose.worktree.yml"

    local ports_data
    ports_data=$(parse_docker_compose_ports "$compose_file")

    [[ -z "$ports_data" ]] && return 1

    local tmpfile
    tmpfile=$(mktemp)

    cat > "$tmpfile" << 'HEADER'
# Auto-generated by wt — DO NOT EDIT
# Port offsets for worktree isolation
services:
HEADER

    local current_service=""
    while IFS=: read -r service host_port container_port; do
        [[ -z "$service" ]] && continue
        local new_port=$((host_port + offset))

        if [[ "$service" != "$current_service" ]]; then
            printf '  %s:\n' "$service" >> "$tmpfile"
            printf '    ports:\n' >> "$tmpfile"
            current_service="$service"
        fi
        printf '      - "%d:%s"\n' "$new_port" "$container_port" >> "$tmpfile"
    done <<< "$ports_data"

    mv "$tmpfile" "$override_file"
    echo "$override_file"
}

# Orchestrate Docker isolation: detect, offset, generate override, update .env
setup_docker_isolation() {
    local wt_path="$1"
    local branch="$2"
    local branch_slug="$3"

    # Check if docker section has 'auto' or any config
    local has_docker=false
    for line in "${WT_DOCKER_LINES[@]}"; do
        [[ "$line" == "auto" || "$line" =~ ^file= ]] && has_docker=true
    done
    [[ "$has_docker" == true ]] || return 0

    local compose_rel
    compose_rel=$(detect_compose_file "$wt_path") || {
        warn "No docker-compose file found, skipping Docker isolation"
        return 0
    }

    local compose_full="$wt_path/$compose_rel"
    local offset
    offset=$(branch_to_port_offset "$branch")

    # Check for custom port_offset
    for line in "${WT_DOCKER_LINES[@]}"; do
        if [[ "$line" =~ ^port_offset=([0-9]+) ]]; then
            offset="${BASH_REMATCH[1]}"
        fi
    done

    info "Docker isolation: $compose_rel (port offset +$offset)"

    local override_file
    override_file=$(generate_docker_compose_override "$compose_full" "$offset") || {
        warn "No ports found in compose file, skipping port override"
        return 0
    }

    local override_rel="${override_file#"$wt_path"/}"
    success "Generated $override_rel"

    # Set COMPOSE_FILE and COMPOSE_PROJECT_NAME in root .env
    local root_env="$wt_path/.env"
    local compose_file_val="${compose_rel}:${override_rel}"
    local project_name="${REPO_NAME}_${branch_slug}"

    # Append or update COMPOSE_FILE in .env
    if [[ -f "$root_env" ]]; then
        local tmpfile
        tmpfile=$(mktemp)
        local found_cf=false
        local found_cpn=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^COMPOSE_FILE= ]]; then
                printf 'COMPOSE_FILE=%s\n' "$compose_file_val"
                found_cf=true
            elif [[ "$line" =~ ^COMPOSE_PROJECT_NAME= ]]; then
                printf 'COMPOSE_PROJECT_NAME=%s\n' "$project_name"
                found_cpn=true
            else
                printf '%s\n' "$line"
            fi
        done < "$root_env" > "$tmpfile"
        [[ "$found_cf" == false ]] && printf 'COMPOSE_FILE=%s\n' "$compose_file_val" >> "$tmpfile"
        [[ "$found_cpn" == false ]] && printf 'COMPOSE_PROJECT_NAME=%s\n' "$project_name" >> "$tmpfile"
        mv "$tmpfile" "$root_env"
    else
        printf 'COMPOSE_FILE=%s\n' "$compose_file_val" > "$root_env"
        printf 'COMPOSE_PROJECT_NAME=%s\n' "$project_name" >> "$root_env"
    fi

    # Print port mapping summary
    local ports_data
    ports_data=$(parse_docker_compose_ports "$compose_full")
    if [[ -n "$ports_data" ]]; then
        echo ""
        echo -e "  ${CYAN}Port mappings:${NC}"
        while IFS=: read -r service host_port container_port; do
            [[ -z "$service" ]] && continue
            local new_port=$((host_port + offset))
            echo -e "    ${service}: ${host_port} → ${GREEN}${new_port}${NC}"
        done <<< "$ports_data"
    fi
}

# =============================================================================
# Phase 4: Database Auto-Creation
# =============================================================================

# Detect Postgres — checks Docker containers first, then local
detect_postgres() {
    # Check Docker containers for postgres
    if command -v docker &>/dev/null; then
        local pg_container
        pg_container=$(docker ps --filter "ancestor=postgres" --filter "status=running" --format '{{.Names}}' 2>/dev/null | head -1)
        if [[ -n "$pg_container" ]]; then
            echo "docker:$pg_container"
            return 0
        fi
        # Also check by port binding (for custom images)
        pg_container=$(docker ps --filter "publish=5432" --filter "status=running" --format '{{.Names}}' 2>/dev/null | head -1)
        if [[ -n "$pg_container" ]]; then
            echo "docker:$pg_container"
            return 0
        fi
    fi

    # Check local postgres
    if command -v pg_isready &>/dev/null && pg_isready -q 2>/dev/null; then
        echo "local"
        return 0
    fi

    return 1
}

# Create database if it doesn't exist (idempotent)
create_database_if_not_exists() {
    local db_name="$1"
    local pg_source="$2"  # "docker:container_name" or "local"

    local exists_query="SELECT 1 FROM pg_database WHERE datname='$db_name'"
    local create_query="CREATE DATABASE \"$db_name\""
    local result=""

    if [[ "$pg_source" == local ]]; then
        result=$(psql -tAc "$exists_query" postgres 2>/dev/null || true)
        if [[ "$result" != "1" ]]; then
            psql -c "$create_query" postgres 2>/dev/null && return 0 || return 1
        fi
    elif [[ "$pg_source" == docker:* ]]; then
        local container="${pg_source#docker:}"
        result=$(docker exec "$container" psql -U postgres -tAc "$exists_query" postgres 2>/dev/null || true)
        if [[ "$result" != "1" ]]; then
            docker exec "$container" psql -U postgres -c "$create_query" postgres 2>/dev/null && return 0 || return 1
        fi
    fi

    return 0  # Already exists
}

# Read rewritten DB name from .env files and auto-create databases
auto_create_databases() {
    local wt_path="$1"
    local pg_source

    pg_source=$(detect_postgres) || {
        warn "Postgres not running, skipping database auto-creation"
        return 0
    }

    # Collect unique database names from all .env files
    local db_names=()
    while IFS= read -r -d '' env_file; do
        while IFS= read -r line; do
            if [[ "$line" =~ ^(DB_NAME|POSTGRES_DB|MYSQL_DATABASE|DATABASE_NAME)=(.+) ]]; then
                local val="${BASH_REMATCH[2]}"
                val="${val#\"}" ; val="${val%\"}"
                val="${val#\'}" ; val="${val%\'}"
                # Only add if not already in array
                local found=false
                for existing in "${db_names[@]+"${db_names[@]}"}"; do
                    [[ "$existing" == "$val" ]] && found=true
                done
                [[ "$found" == false ]] && db_names+=("$val")
            elif [[ "$line" =~ ^(DATABASE_URL|POSTGRES_URL)=(.+) ]]; then
                local url="${BASH_REMATCH[2]}"
                url="${url#\"}" ; url="${url%\"}"
                # Extract db name from URL: scheme://user:pass@host:port/dbname
                if [[ "$url" =~ ://[^/]*/([^?]+) ]]; then
                    local val="${BASH_REMATCH[1]}"
                    local found=false
                    for existing in "${db_names[@]+"${db_names[@]}"}"; do
                        [[ "$existing" == "$val" ]] && found=true
                    done
                    [[ "$found" == false ]] && db_names+=("$val")
                fi
            fi
        done < "$env_file"
    done < <(find "$wt_path" -maxdepth 3 -name '.env*' -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 2>/dev/null)

    for db_name in "${db_names[@]+"${db_names[@]}"}"; do
        if create_database_if_not_exists "$db_name" "$pg_source"; then
            success "Database ready: $db_name"
        else
            warn "Could not create database: $db_name"
        fi
    done
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

    # --- Step 1: Create git worktree ---
    info "Creating worktree for branch: $branch"

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

    # --- Step 2: Load .worktreeinclude ---
    generate_default_worktreeinclude
    parse_worktreeinclude

    # --- Step 3: Copy files matching patterns ---
    if [[ ${#WT_FILE_PATTERNS[@]} -gt 0 ]]; then
        info "Copying files from .worktreeinclude..."
        match_files_by_patterns "$REPO_ROOT"
        local file_count
        file_count=$(copy_matched_files "$REPO_ROOT" "$wt_path")
        if [[ "$file_count" -gt 0 ]]; then
            success "Copied $file_count file(s)"
        else
            warn "No matching files found to copy"
        fi
    fi

    # --- Step 4: Rewrite env vars ---
    local branch_slug
    branch_slug=$(sanitize_branch_for_suffix "$branch")

    if [[ ${#WT_REWRITE_LINES[@]} -gt 0 ]]; then
        info "Rewriting env vars (suffix: _$branch_slug)..."
        local rewrite_count
        rewrite_count=$(rewrite_all_env_files "$wt_path" "$branch_slug")
        if [[ "$rewrite_count" -gt 0 ]]; then
            success "Rewrote $rewrite_count .env file(s)"
        fi
    fi

    # --- Step 5: Docker Compose isolation ---
    if [[ ${#WT_DOCKER_LINES[@]} -gt 0 ]]; then
        setup_docker_isolation "$wt_path" "$branch" "$branch_slug"
    fi

    # --- Step 6: Auto-create database ---
    if [[ ${#WT_REWRITE_LINES[@]} -gt 0 ]]; then
        auto_create_databases "$wt_path"
    fi

    # --- Step 7: Install dependencies ---
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

    # --- Step 8: Summary ---
    echo ""
    success "Worktree ready!"
    echo ""
    echo -e "${GREEN}cd ${wt_path}${NC}"
}

cmd_list() {
    get_repo_info

    info "Worktrees for: $REPO_NAME"
    echo ""

    local found=0
    while IFS= read -r line; do
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

    # Stop Docker containers if compose setup exists
    if [[ -f "$wt_path/.env" ]]; then
        local compose_file_val=""
        while IFS= read -r line; do
            [[ "$line" =~ ^COMPOSE_FILE=(.+) ]] && compose_file_val="${BASH_REMATCH[1]}"
        done < "$wt_path/.env"

        if [[ -n "$compose_file_val" ]] && command -v docker &>/dev/null; then
            info "Stopping Docker containers..."
            (cd "$wt_path" && docker compose down 2>/dev/null) || warn "Could not stop containers (may not be running)"
        fi
    fi

    info "Removing worktree: $wt_path"
    git worktree remove "$wt_path" --force
    success "Worktree removed"
    info "Note: databases are preserved — drop manually if no longer needed"

    if [[ "$delete_branch" == true ]]; then
        info "Deleting branch: $branch"
        git branch -D "$branch" 2>/dev/null || warn "Branch not found or already deleted"
        success "Branch deleted"
    fi
}

cmd_open() {
    local branch=""
    local editor=""

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
    echo "  create, c <branch>     Create worktree with isolation (env, docker, db)"
    echo "  list, ls               List all worktrees for current repo"
    echo "  remove, rm <branch>    Remove worktree (add -d to delete branch too)"
    echo "  open, o <branch>       Open worktree (flag > WT_EDITOR > auto-detect)"
    echo "                         Options: --cursor|-c, --agy|-a, --code|-v"
    echo "  help, -h, --help       Show this help"
    echo ""
    echo "Environment:"
    echo "  WT_EDITOR              Default editor (cursor, agy, code)"
    echo ""
    echo "Isolation (.worktreeinclude):"
    echo "  Auto-generated on first 'wt create' if missing."
    echo "  Controls which files to copy and how to isolate services."
    echo ""
    echo "  Sections:"
    echo "    (top)       Glob patterns for files to copy (e.g., .env*)"
    echo "    [rewrite]   'auto' to suffix DB_NAME, DATABASE_URL, etc."
    echo "                Use {{BRANCH}} for custom templates"
    echo "    [docker]    'auto' to generate port-offset override"
    echo "                'file=path' for custom compose file"
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
