#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
echo "Installing required dependencies..."
sudo apt install -y curl git build-essential

# Install NVM (Node Version Manager)
echo "Installing NVM..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
fi

# Load NVM into current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Install Node.js (LTS version)
echo "Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# Verify installation
echo "Verifying Node.js and npm installation..."
node -v
npm -v

# Install PNPM (Package Manager)
echo "Installing PNPM..."
curl -fsSL https://get.pnpm.io/install.sh | sh -
export PATH="$HOME/.local/share/pnpm:$PATH"
echo 'export PATH="$HOME/.local/share/pnpm:$PATH"' >> ~/.bashrc

# Install PM2 for process management
echo "Installing PM2 with PNPM..."
pnpm add -g pm2
pm2 startup

# Clone the repository
echo "Cloning the OpenAgri repository..."
PROJECT_DIR="/home/$USER/openagri-node"
GIT_REPO="https://github.com/openagri-lab/openagri-node.git"

if [ -d "$PROJECT_DIR" ]; then
    echo "Project directory already exists. Pulling latest changes..."
    cd $PROJECT_DIR
    git pull origin main
else
    echo "Cloning repository..."
    git clone $GIT_REPO $PROJECT_DIR
    cd $PROJECT_DIR
fi

# Install dependencies with PNPM
echo "Installing dependencies..."
pnpm install

# Build the project
echo "Building the project..."
pnpm run build

# Start the application with PM2
echo "Starting the application with PM2..."
pm2 start dist/src/main.js --name openagri-node
pm2 save

# Enable PM2 startup
PME_CMD=$(pm2 startup | tail -n 1)

if [ -z "$PME_CMD" ]; then
    echo "PM2 startup command not found. Please run the following command manually:"
    exit 1
fi

# Check if the PM2 startup command is already enabled
echo "Enabling PM2 startup..."
eval $PME_CMD

echo "Installation and deployment complete! The application is now running."