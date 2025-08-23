#!/bin/bash

# Workspace Synchronization Script
# Usage: ./sync-workspace.sh [branch-name]
# If no branch name provided, uses current date-based name

set -e  # Exit on any error

# Get branch name (default to date-based if not provided)
if [ -z "$1" ]; then
    BRANCH_NAME="feature/sync-$(date +%Y-%m-%d)"
else
    BRANCH_NAME="$1"
fi

echo "🔄 Syncing workspace to branch: $BRANCH_NAME"
echo "================================================"

# Function to sync a submodule
sync_submodule() {
    local submodule_path="$1"
    local submodule_name=$(basename "$submodule_path")
    
    echo "📁 Syncing $submodule_name..."
    
    cd "$submodule_path"
    
    # Check if we're already on the target branch
    if [ "$(git branch --show-current)" = "$BRANCH_NAME" ]; then
        echo "   ✅ Already on $BRANCH_NAME"
    else
        # Create and switch to new branch
        echo "   🔀 Creating and switching to $BRANCH_NAME"
        git checkout -b "$BRANCH_NAME"
        
        # Push to remote
        echo "   📤 Pushing to remote..."
        git push origin "$BRANCH_NAME"
    fi
    
    cd - > /dev/null
    echo "   ✅ $submodule_name synced"
}

# Main workspace
echo "🏠 Main workspace..."
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
echo "   ✅ Main workspace on $BRANCH_NAME"

# Sync all submodules
echo ""
echo "🔄 Syncing submodules..."
for submodule in moku-dev-examples moku-dev-obsd-vault moku-dev-python moku-dev-vhdl; do
    if [ -d "$submodule" ]; then
        sync_submodule "$submodule"
    else
        echo "   ⚠️  Submodule $submodule not found, skipping"
    fi
done

# Update main workspace to point to new submodule branches
echo ""
echo "🔗 Updating main workspace submodule pointers..."
git add moku-dev-examples moku-dev-obsd-vault moku-dev-python moku-dev-vhdl
git commit -m "Sync all submodules to $BRANCH_NAME branch

- All submodules now on consistent $BRANCH_NAME branch
- Ensures workspace and submodules are in sync
- Creates unified development state across all components" || echo "   ℹ️  No changes to commit"

# Create a tag for this sync point
TAG_NAME="v$(date +%Y.%m.%d)-workspace-sync"
echo ""
echo "🏷️  Creating tag: $TAG_NAME"
git tag -a "$TAG_NAME" -m "Workspace sync point - all submodules on $BRANCH_NAME

- Created: $(date)
- Branch: $BRANCH_NAME
- All submodules synchronized
- Perfect checkpoint for development"

echo ""
echo "🎉 Workspace synchronization complete!"
echo "================================================"
echo "📋 Summary:"
echo "   Branch: $BRANCH_NAME"
echo "   Tag: $TAG_NAME"
echo "   All submodules: ✅ Synced"
echo ""
echo "💡 To return to this state later:"
echo "   git checkout $TAG_NAME"
echo "   or"
echo "   git checkout $BRANCH_NAME"
echo ""
echo "🚀 Ready for development!"
