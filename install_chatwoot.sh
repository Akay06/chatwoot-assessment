#!/usr/bin/env bash
set -euo pipefail

# Unattended Chatwoot Local Setup Script
# Supports: Ubuntu 22.04+ and other Debian-based distributions
# Usage: bash install_chatwoot.sh YOUR_GITHUB_USERNAME

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}[STEP]${NC} $1"
    echo -e "${BLUE}=====${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 could not be found. Please install it first."
        exit 1
    fi
}

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    log_error "Please do not run this script as root or with sudo"
    exit 1
fi

# Check arguments
if [ "$#" -ne 1 ]; then
    log_error "Usage: $0 <github_username>"
    exit 1
fi

# Check system compatibility
if ! grep -q "Ubuntu" /etc/os-release; then
    log_error "This script is designed for Ubuntu-based systems only"
    exit 1
fi

GITHUB_USER="$1"
REPO_NAME="chatwoot-assessment"
CHATWOOT_DIR="$HOME/$REPO_NAME"

# Trap errors
trap 'log_error "An error occurred. Exiting..."; exit 1' ERR

log_step "Starting Chatwoot installation..."

# 1. System update and core dependencies
log_step "System Updates and Dependencies"
log_info "Updating system package list..."
sudo apt update || { log_error "Failed to update package list"; exit 1; }
log_info "Upgrading system packages..."
sudo apt upgrade -y || { log_warn "System upgrade failed, continuing anyway..."; }

# Install dependencies with error handling
log_info "Installing system dependencies..."
dependencies=(
    "curl"
    "gnupg2"
    "build-essential"
    "libssl-dev"
    "libreadline-dev"
    "zlib1g-dev"
    "libpq-dev"
    "libsqlite3-dev"
    "libffi-dev"
    "libyaml-dev"
    "postgresql"
    "postgresql-contrib"
    "postgresql-16-pgvector"
    "redis-server"
    "git"
)

for dep in "${dependencies[@]}"; do
    if ! dpkg -l | grep -q "^ii  $dep"; then
        log_info "Installing $dep..."
        sudo apt install -y "$dep" || { log_error "Failed to install $dep"; exit 1; }
    else
        log_info "$dep is already installed"
    fi
done

# 2. Install nvm, Node.js, and pnpm
log_step "Node.js Environment Setup"
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash || { log_error "Failed to install nvm"; exit 1; }
    # Load nvm immediately
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    log_info "nvm is already installed"
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install Node.js if not already installed
if ! command -v node &> /dev/null || [[ $(node -v) != v24* ]]; then
    log_info "Installing Node.js v24..."
    nvm install 24 || { log_error "Failed to install Node.js"; exit 1; }
    nvm use 24
    nvm alias default 24
else
    log_info "Node.js v24 is already installed"
    nvm use 24
fi

# Setup pnpm
log_info "Setting up pnpm..."
if ! command -v pnpm &> /dev/null; then
    log_info "Installing pnpm..."
    npm install -g pnpm@latest || { log_error "Failed to install pnpm"; exit 1; }
else
    log_info "Updating pnpm to latest version..."
    npm install -g pnpm@latest --force || { log_error "Failed to update pnpm"; exit 1; }
fi

# Configure pnpm path
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Add to bashrc if not already present
if ! grep -q "PNPM_HOME" ~/.bashrc; then
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
fi

# 3. Install rbenv and Ruby
log_step "Ruby Environment Setup"
if [ ! -d "$HOME/.rbenv" ]; then
    log_info "Installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv || { log_error "Failed to clone rbenv"; exit 1; }
    cd ~/.rbenv && src/configure && make -C src
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build || { log_error "Failed to clone ruby-build"; exit 1; }
else
    log_info "rbenv is already installed"
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# Install Ruby if not already installed
if ! rbenv versions | grep -q "3.4.4"; then
    log_info "Installing Ruby 3.4.4..."
    rbenv install -s 3.4.4 || { log_error "Failed to install Ruby 3.4.4"; exit 1; }
fi
rbenv global 3.4.4

# Install gems if needed
if ! command -v bundler &> /dev/null || ! command -v foreman &> /dev/null; then
    log_info "Installing required gems..."
    gem install bundler foreman || { log_error "Failed to install bundler and foreman"; exit 1; }
else
    log_info "Required gems are already installed"
fi

# 4. Clone/Update Chatwoot repo
log_step "Repository Setup"
if [ -d "$CHATWOOT_DIR" ]; then
    log_info "Updating existing repository..."
    cd "$CHATWOOT_DIR"
    git pull || { log_error "Failed to update repository"; exit 1; }
else
    log_info "Cloning repository..."
    git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git" "$CHATWOOT_DIR" || { log_error "Failed to clone repository"; exit 1; }
    cd "$CHATWOOT_DIR"
fi

# 5. Environment configuration
log_step "Environment Configuration"
if [ ! -f .env ]; then
    log_info "Creating .env file..."
    cp .env.example .env || { log_error "Failed to create .env file"; exit 1; }

    # Generate secret key base
    if command -v rails > /dev/null; then
        SECRET=$(rails secret)
        sed -i "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$SECRET|" .env
    else
        log_warn "Rails not available yet to generate secret key. You must set SECRET_KEY_BASE manually."
    fi

    # Configure environment variables
    sed -i 's|^REDIS_URL=.*|REDIS_URL=redis://localhost:6379|' .env
    sed -i 's|^POSTGRES_HOST=.*|POSTGRES_HOST=localhost|' .env
    sed -i 's|^POSTGRES_USERNAME=.*|POSTGRES_USERNAME=postgres|' .env
    sed -i 's|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=postgres|' .env
    sed -i 's|^SMTP_DOMAIN=.*|SMTP_DOMAIN=localhost|' .env
else
    log_info ".env file already exists"
fi

# 6. Start services
log_step "Service Configuration"
log_info "Starting Redis..."
if ! sudo service redis-server status &>/dev/null; then
    sudo service redis-server start || { log_warn "Failed to start Redis. Please start it manually."; }
fi

log_info "Starting PostgreSQL..."
if ! sudo service postgresql status &>/dev/null; then
    sudo service postgresql start || { log_warn "Failed to start PostgreSQL. Please start it manually."; }
fi

# Configure PostgreSQL
log_info "Configuring PostgreSQL..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" || { log_error "Failed to set PostgreSQL password"; exit 1; }

# 7. Backend setup
log_step "Backend Setup"
log_info "Installing Ruby dependencies..."
bundle install || { log_error "Failed to install Ruby dependencies"; exit 1; }

# Database setup with error handling
log_info "Setting up database..."
if ! rails db:version &>/dev/null; then
    log_info "Creating database and running migrations..."
    rails db:setup || { log_error "Failed to setup database"; exit 1; }
    
    # Attempt to seed database
    log_info "Seeding database..."
    if ! rails db:seed; then
        log_warn "Seeding may have failed due to duplicates. If you see 'Email has already been taken' errors,"
        log_warn "consider running: rails db:reset && rails db:seed"
        log_warn "WARNING: This will ERASE all existing data!"
    fi
else
    log_info "Database already exists, running migrations..."
    rails db:migrate || { log_error "Failed to run database migrations"; exit 1; }
fi

# 8. Frontend setup
log_step "Frontend Setup"
log_info "Installing frontend dependencies..."
pnpm install || { log_error "Failed to install frontend dependencies"; exit 1; }
chmod +x bin/rails bin/vite

# 9. Launch
log_step "Launch"
log_info "✅ Setup complete! Starting Chatwoot..."
log_info "Once the server starts, you can access Chatwoot at: ${BLUE}http://localhost:3000${NC}"
log_info "Press Ctrl+C to stop the server when needed"
echo -e "\n${GREEN}Starting services with Foreman...${NC}\n"
foreman start -f Procfile.dev 