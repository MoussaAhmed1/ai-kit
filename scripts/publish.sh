#!/bin/bash

# Smicolon Claude Infrastructure - Publisher
# Publishes packages to hosting location (CDN/S3/server)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
CHANNEL=${1:-production}  # production, dev, beta, etc.
PUBLISH_METHOD=${SMICOLON_PUBLISH_METHOD:-rsync}  # rsync, s3, scp
PUBLISH_HOST=${SMICOLON_PUBLISH_HOST:-""}
PUBLISH_PATH=${SMICOLON_PUBLISH_PATH:-"/var/www/smicolon-claude"}
S3_BUCKET=${SMICOLON_S3_BUCKET:-""}

echo "Smicolon Package Publisher"
echo "=========================="
echo "Channel: $CHANNEL"
echo ""

# Build package first
echo "Building package..."
bash "$SCRIPT_DIR/package.sh"

# Get the latest package
LATEST_PACKAGE=$(ls -t "$REPO_DIR/dist/"*.tar.gz | head -1)
PACKAGE_NAME=$(basename "$LATEST_PACKAGE")

if [ ! -f "$LATEST_PACKAGE" ]; then
    echo "Error: No package found in dist/"
    exit 1
fi

echo "Package: $PACKAGE_NAME"
echo "Publish method: $PUBLISH_METHOD"
echo ""

# Create manifest with metadata
MANIFEST_FILE="$REPO_DIR/dist/manifest.json"
cat > "$MANIFEST_FILE" <<EOF
{
  "version": "$(cat $REPO_DIR/agents/django-architect.md | grep -m1 "Version" || echo "unknown")",
  "channel": "$CHANNEL",
  "package": "$PACKAGE_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "git_commit": "$(git -C "$REPO_DIR" rev-parse HEAD)",
  "git_branch": "$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)"
}
EOF

# Publish based on method
case $PUBLISH_METHOD in
    rsync)
        if [ -z "$PUBLISH_HOST" ]; then
            echo "Error: SMICOLON_PUBLISH_HOST not set"
            echo "Set with: export SMICOLON_PUBLISH_HOST=user@your-server.com"
            exit 1
        fi

        echo "Publishing via rsync to $PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"

        # Create remote directory
        ssh "$PUBLISH_HOST" "mkdir -p $PUBLISH_PATH/$CHANNEL"

        # Upload package and manifest
        rsync -avz "$LATEST_PACKAGE" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"
        rsync -avz "$SCRIPT_DIR/quick-install.sh" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"
        rsync -avz "$MANIFEST_FILE" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"

        # For production channel, also update 'latest' symlink
        if [ "$CHANNEL" = "production" ]; then
            ssh "$PUBLISH_HOST" "cd $PUBLISH_PATH && ln -sf $CHANNEL/\$PACKAGE_NAME smicolon-claude-latest.tar.gz"
        fi

        echo "✓ Published to $PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"
        echo ""
        echo "Install URL:"
        echo "  curl -fsSL https://$(echo $PUBLISH_HOST | cut -d@ -f2)/smicolon-claude/$CHANNEL/quick-install.sh | bash"
        ;;

    s3)
        if [ -z "$S3_BUCKET" ]; then
            echo "Error: SMICOLON_S3_BUCKET not set"
            echo "Set with: export SMICOLON_S3_BUCKET=s3://your-bucket/smicolon-claude"
            exit 1
        fi

        echo "Publishing to S3: $S3_BUCKET/$CHANNEL/"

        # Upload to S3
        aws s3 cp "$LATEST_PACKAGE" "$S3_BUCKET/$CHANNEL/$PACKAGE_NAME" --acl public-read
        aws s3 cp "$SCRIPT_DIR/quick-install.sh" "$S3_BUCKET/$CHANNEL/quick-install.sh" --acl public-read
        aws s3 cp "$MANIFEST_FILE" "$S3_BUCKET/$CHANNEL/manifest.json" --acl public-read

        # For production, update latest
        if [ "$CHANNEL" = "production" ]; then
            aws s3 cp "$LATEST_PACKAGE" "$S3_BUCKET/smicolon-claude-latest.tar.gz" --acl public-read
        fi

        echo "✓ Published to S3"
        echo ""
        echo "Install URL:"
        echo "  curl -fsSL https://your-cdn.com/smicolon-claude/$CHANNEL/quick-install.sh | bash"
        ;;

    scp)
        if [ -z "$PUBLISH_HOST" ]; then
            echo "Error: SMICOLON_PUBLISH_HOST not set"
            exit 1
        fi

        echo "Publishing via scp to $PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"

        ssh "$PUBLISH_HOST" "mkdir -p $PUBLISH_PATH/$CHANNEL"
        scp "$LATEST_PACKAGE" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"
        scp "$SCRIPT_DIR/quick-install.sh" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"
        scp "$MANIFEST_FILE" "$PUBLISH_HOST:$PUBLISH_PATH/$CHANNEL/"

        echo "✓ Published via scp"
        ;;

    local)
        # For testing - copy to local directory
        LOCAL_PUBLISH_PATH=${SMICOLON_LOCAL_PUBLISH:-"$HOME/public_html/smicolon-claude"}
        echo "Publishing to local directory: $LOCAL_PUBLISH_PATH/$CHANNEL/"

        mkdir -p "$LOCAL_PUBLISH_PATH/$CHANNEL"
        cp "$LATEST_PACKAGE" "$LOCAL_PUBLISH_PATH/$CHANNEL/"
        cp "$SCRIPT_DIR/quick-install.sh" "$LOCAL_PUBLISH_PATH/$CHANNEL/"
        cp "$MANIFEST_FILE" "$LOCAL_PUBLISH_PATH/$CHANNEL/"

        echo "✓ Published locally"
        echo ""
        echo "Test with: bash $LOCAL_PUBLISH_PATH/$CHANNEL/quick-install.sh"
        ;;

    *)
        echo "Error: Unknown publish method: $PUBLISH_METHOD"
        echo "Supported: rsync, s3, scp, local"
        exit 1
        ;;
esac

echo ""
echo "Publication complete!"
