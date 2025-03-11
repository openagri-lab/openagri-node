#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Load NVM into the current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Update Node.js to the latest LTS version
echo "Updating Node.js to latest LTS..."
nvm install --lts
nvm use --lts

# Update PNPM to the latest version
echo "Updating PNPM..."
pnpm add -g pnpm

# Ensure PM2 is up-to-date
echo "Updating PM2..."
pnpm add -g pm2
pm2 update

# Navigate to the project directory
PROJECT_DIR="/home/$USER/openagri-node"
if [ -d "$PROJECT_DIR" ]; then
    echo "Navigating to project directory: $PROJECT_DIR"
    cd $PROJECT_DIR
else
    echo "Project directory does not exist. Exiting..."
    exit 1
fi

# Pull the latest changes from the repository
echo "Pulling latest changes from repository..."
git pull origin main

# Install updated dependencies
echo "Installing updated dependencies..."
pnpm install

# Build the project
echo "Building the project..."
pnpm run build

echo "Application des migrations Prisma..."
npx prisma migrate deploy  # Appliquer les migrations existantes

# Restart the application with PM2
echo "Restarting the application with PM2..."
pm2 reload openagri-node
pm2 save

echo "Update complete! The application is now running with the latest version."
