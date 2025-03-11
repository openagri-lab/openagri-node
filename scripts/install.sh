#!/bin/bash

set -e  # Stop the script if any command fails

# Update system packages
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
echo "📦 Installing required dependencies..."
sudo apt install -y curl git build-essential software-properties-common apt-transport-https gnupg wget lsb-release postgresql-common

# Install PostgreSQL 17 & TimescaleDB if not installed ---
if ! psql --version 2>/dev/null | grep -q " 17"; then
    echo "📥 Adding PostgreSQL 17 repository using the official script..."
    sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

    # Update package list
    sudo apt update

    # Install PostgreSQL 17
    sudo apt install -y postgresql-17 postgresql-client-17 postgresql-contrib-17

    # Start PostgreSQL
    echo "🚀 Starting PostgreSQL service..."
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
else
    echo "✅ PostgreSQL 17 is already installed."
fi

# Install TimescaleDB 2.17 if not installed ---
if ! sudo -u postgres psql -c "SELECT * FROM pg_extension WHERE extname = 'timescaledb';" | grep -q "timescaledb"; then
    echo "📥 Adding TimescaleDB repository..."
    wget -qO- https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
    echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list

    # Update package list again
    sudo apt update

    # Install TimescaleDB 2.17
    sudo apt install -y timescaledb-2-postgresql-17

    # Configure PostgreSQL to optimize for TimescaleDB
    echo "⚙️ Configuring TimescaleDB..."
    sudo timescaledb-tune --quiet --yes

    # Restart PostgreSQL to apply changes
    sudo systemctl restart postgresql

    # Enable TimescaleDB in PostgreSQL
    sudo -u postgres psql <<EOF
    CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
EOF
else
    echo "✅ TimescaleDB 2.17 is already installed."
fi

# Setup PostgreSQL database if not exists ---
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw openagri; then
    echo "🛠️ Creating PostgreSQL database and user..."

    sudo -u postgres psql <<EOF
    CREATE USER openagri WITH PASSWORD 'openagri';
    CREATE DATABASE openagri OWNER openagri;
    \c openagri;
    CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
EOF
else
    echo "✅ Database 'openagri' already exists."
fi

echo "✅ PostgreSQL 17 + TimescaleDB 2.17 setup complete!"

# Install NVM, Node.js, PNPM, and PM2 only if not installed ---
if ! command -v node &> /dev/null; then
    echo "📦 Installing NVM..."
    export NVM_DIR="$HOME/.nvm"
    if [ ! -d "$NVM_DIR" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

    echo "📦 Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
else
    echo "✅ Node.js is already installed."
fi

echo "🔍 Verifying Node.js and npm installation..."
node -v
npm -v

# Install PNPM package manager
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing PNPM..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    export PATH="$HOME/.local/share/pnpm:$PATH"
    echo 'export PATH="$HOME/.local/share/pnpm:$PATH"' >> ~/.bashrc
else
    echo "✅ PNPM is already installed."
fi

# Install PM2 for process management
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2 with PNPM..."
    pnpm add -g pm2
else
    echo "✅ PM2 is already installed."
fi

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
echo "📦 Installing dependencies..."
pnpm install

# Build the project
echo "🛠️ Building the project..."
pnpm run build

# Start the application with PM2
echo "🚀 Starting the application with PM2..."
pm2 start dist/src/main.js --name openagri-node
pm2 save

# Enable PM2 startup
PME_CMD=$(pm2 startup | tail -n 1)

if [ -z "$PME_CMD" ]; then
    echo "⚠️ PM2 startup command not found. Please run the following command manually:"
    exit 1
fi

# Check if the PM2 startup command is already enabled
echo "🔄 Enabling PM2 startup..."
eval $PME_CMD

echo "Installation and deployment complete! The application is now running."