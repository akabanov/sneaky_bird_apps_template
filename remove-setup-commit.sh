#!/bin/bash

# Exit on error
set -e

# Function to get current branch name
get_current_branch() {
    git symbolic-ref --short HEAD
}

# Function to check if remote exists and has current branch
check_remote() {
    if ! git ls-remote --exit-code origin "$current_branch" > /dev/null 2>&1; then
        echo "No remote master branch found"
        return 1
    fi
    return 0
}

# Main execution starts here
current_branch=$(get_current_branch)

# Find commit with message "Initial setup"
commit_hash=$(git log --grep="^Initial setup$" --format="%H" "$current_branch")

if [ -z "$commit_hash" ]; then
    echo "No commit with message 'Initial setup' found in master branch"
    exit 0
fi

echo "Found 'Initial setup' commit: $commit_hash"

# Check if this is the first commit
if [ "$(git rev-list --max-parents=0 HEAD)" = "$commit_hash" ]; then
    echo "This is the first commit in the repository. Cannot remove it."
    exit 1
fi

# Check if commit has been pushed to remote
has_remote=false
if check_remote; then
    has_remote=true
    if git branch -r --contains "$commit_hash" | grep -q "origin/$current_branch"; then
        echo "Warning: This commit has been pushed to remote"
        read -p "Do you want to force push after removing the commit? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Operation cancelled"
            exit 1
        fi
    fi
fi

# Remove the commit
echo "Removing the commit..."
git rebase -i "$commit_hash"^ --exec "git commit --amend -m \"$(git log --format=%B -n1)\"" > /dev/null 2>&1

# Force push if requested
if [ "$has_remote" = true ] && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Force pushing to remote..."
    git push -f origin "$current_branch"
fi

echo "Operation completed successfully"
