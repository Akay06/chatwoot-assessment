# Chatwoot Local Development Setup Guide

This guide provides **step-by-step instructions** for setting up Chatwoot for local development. Follow these instructions carefully to get your development environment up and running.

## Quick Setup

For a quick automated setup, you can use our installation script:

```bash
chmod +x install_chatwoot.sh
./install_chatwoot.sh YOUR_GITHUB_USERNAME
```

## Manual Setup Instructions

### 1. Prerequisites

Ensure you are on **Ubuntu 24.04+ or WSL2**.

Install core dependencies:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  curl gnupg2 build-essential \
  libssl-dev libreadline-dev zlib1g-dev \
  libpq-dev libsqlite3-dev libffi-dev libyaml-dev \
  postgresql postgresql-contrib postgresql-16-pgvector \
  redis-server
```

### 2. Install and Configure Node.js & pnpm

Use **nvm** to manage Node versions:

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"

# Install Node.js v24 (LTS)
nvm install 24
nvm use 24

# Enable Corepack for pnpm
corepack enable pnpm

# Verify pnpm
pnpm -v
```

### 3. Install and Configure Ruby

Install **rbenv** and Ruby 3.4.4:

```bash
# Clone and set up rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install ruby-build plugin
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.4.4
rbenv install 3.4.4
rbenv global 3.4.4

# Install Bundler and Foreman
gem install bundler foreman

# Install Rails command-line tools
sudo apt install -y ruby-railties
```

### 4. Clone and Prepare the Repository

```bash
git clone https://github.com/YOUR_USERNAME/chatwoot-assessment.git
cd chatwoot-assessment

# Install dependencies
bundle install

# Reload environment
source ~/.bashrc
```

Copy environment variables and adjust:

```bash
cp .env.example .env
```

Open `.env` and update:

```env
SECRET_KEY_BASE=<run 'rails secret' and paste>
REDIS_URL=redis://localhost:6379
POSTGRES_HOST=localhost
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=postgres
SMTP_DOMAIN=localhost
```

### 5. Backend Setup

1. **Configure PostgreSQL**:
   ```bash
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
   ```

2. **Start Redis**:
   ```bash
   sudo service redis-server start
   ```

3. **Setup Database**:
   ```bash
   rails db:setup    # creates and migrates chatwoot_dev & chatwoot_test
   rails db:seed     # seeds sample data
   ```

   If you encounter "Email has already been taken" errors during seeding, modify `db/seeds.rb`:
   ```ruby
   # Replace
   user = User.new(name: 'John', email: 'john@acme.inc', password: 'Password1!', type: 'SuperAdmin')
   
   # With
   user = User.find_or_initialize_by(email: 'john@acme.inc')
   user.assign_attributes(name: 'John', password: 'Password1!', type: 'SuperAdmin')
   ```

### 6. Frontend Setup

Install JavaScript dependencies:

```bash
pnpm install
chmod +x bin/rails bin/vite
```

### 7. Running the Application

Start all processes using Foreman:

```bash
foreman start -f Procfile.dev
```

Access the application at: `http://localhost:3000`

### 8. Testing Core Functionality

1. Sign in with the seeded admin account:
   - Email: john@acme.inc
   - Password: Password1!

2. Test basic features:
   - Create a new inbox
   - Start a conversation
   - Send and receive messages
   - Test CSAT functionality
   - Verify webhook integrations

### 9. Troubleshooting Guide

#### PostgreSQL Issues
- **Connection Failed**: 
  ```bash
  sudo service postgresql start
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
  ```
- **Database Exists**: 
  ```bash
  rails db:reset db:seed
  ```

#### Redis Issues
- **Connection Refused**: 
  ```bash
  sudo service redis-server start
  redis-cli ping  # Should return PONG
  ```

#### Ruby/Rails Issues
- **Wrong Ruby Version**: 
  ```bash
  rbenv versions
  rbenv global 3.4.4
  ruby -v  # Should show 3.4.4
  ```
- **Bundle Install Fails**: 
  ```bash
  gem install bundler
  bundle install
  ```

#### Node.js/pnpm Issues
- **Wrong Node Version**: 
  ```bash
  nvm use 24
  node -v  # Should show v24.x.x
  ```
- **pnpm Not Found**: 
  ```bash
  corepack enable
  pnpm -v
  ```

#### Permission Issues
- **bin/ Scripts**: 
  ```bash
  chmod +x bin/*
  ```
- **tmp/ Directory**: 
  ```bash
  chmod -R 777 tmp/
  ```

For additional help, check:
- [Official Chatwoot Documentation](https://www.chatwoot.com/docs)
- [GitHub Issues](https://github.com/chatwoot/chatwoot/issues)
- [Chatwoot Discord Community](https://discord.gg/cJXdrwS) 