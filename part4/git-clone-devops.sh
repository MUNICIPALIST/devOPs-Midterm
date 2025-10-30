#!/bin/bash

# Git Auto-Clone Script for DevOps Midterm Project
# This script clones or updates the project from Git repository

# Configuration
REPO_URL="https://github.com/your-username/devops-midterm.git"
PROJECT_DIR="/opt/devops-midterm"
LOG_FILE="/var/log/git-clone.log"
BRANCH="main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Error handling
set -e

log "Starting Git auto-clone script..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    log "${RED}ERROR: Git is not installed. Installing...${NC}"
    apt update && apt install -y git
fi

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Create project directory if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    log "Creating project directory: $PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Check if directory is already a git repository
if [ -d ".git" ]; then
    log "Git repository already exists. Pulling latest changes..."
    # Stash any local changes
    git stash push -m "Auto-stash before pull" 2>/dev/null || true

    # Pull latest changes
    if git pull origin "$BRANCH"; then
        log "${GREEN}Successfully pulled latest changes from $BRANCH branch${NC}"
    else
        log "${RED}ERROR: Failed to pull changes${NC}"
        exit 1
    fi

    # Restore stashed changes if any
    git stash pop 2>/dev/null || true
else
    log "Cloning repository from $REPO_URL..."

    # Remove any existing files in the directory
    rm -rf "$PROJECT_DIR"/*
    rm -rf "$PROJECT_DIR"/.*

    # Clone the repository
    if git clone -b "$BRANCH" "$REPO_URL" .; then
        log "${GREEN}Successfully cloned repository${NC}"
    else
        log "${RED}ERROR: Failed to clone repository${NC}"
        exit 1
    fi
fi

# Check if package.json exists and install dependencies
if [ -f "package.json" ]; then
    log "Installing Node.js dependencies..."
    if command -v npm &> /dev/null; then
        npm install
        log "${GREEN}Dependencies installed successfully${NC}"
    else
        log "${YELLOW}WARNING: npm not found, skipping dependency installation${NC}"
    fi
fi

# Set proper permissions
chown -R root:root "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

log "${GREEN}Git auto-clone script completed successfully${NC}"
