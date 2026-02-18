#!/bin/bash
# Development server starter for WordPress ecosystem

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Check if repo exists
check_repo() {
    local repo=$1
    if [ ! -d "repos/$repo" ]; then
        echo_error "$repo repository not found"
        echo "💡 Run: ./skills/setup/scripts/repos.sh clone"
        exit 1
    fi
}

# Check if port is available
check_port() {
    local port=$1
    local service=$2
    if lsof -ti:$port > /dev/null 2>&1; then
        echo_warning "Port $port is already in use"
        local pid=$(lsof -ti:$port)
        echo "Process: $(ps -p $pid -o comm= 2>/dev/null || echo 'unknown')"
        echo "Kill with: kill $pid"
        return 1
    fi
    return 0
}

# Start individual services
start_calypso() {
    echo_info "Starting Calypso development server..."
    check_repo "calypso"
    
    cd repos/calypso
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version. Ensure nvm is installed."
    }
    
    current_node=$(node --version 2>/dev/null | sed 's/v//')
    if [[ ! "$current_node" == "22"* ]]; then
        echo_warning "Expected Node 22, found $current_node"
    fi
    
    # Check dependencies
    if [ ! -d "node_modules" ] || [ ! -f "node_modules/.yarn-integrity" ]; then
        echo_warning "Dependencies not installed. Running yarn install..."
        yarn install
    fi
    
    # Check port
    if ! check_port 3000 "Calypso"; then
        echo_error "Cannot start Calypso - port 3000 in use"
        return 1
    fi
    
    echo_success "Starting Calypso..."
    echo "🌐 URLs:"
    echo "  • Legacy Interface: http://calypso.localhost:3000"
    echo "  • New Dashboard: http://my.localhost:3000"
    echo ""
    echo "💡 Add to /etc/hosts if needed:"
    echo "  127.0.0.1 calypso.localhost"
    echo "  127.0.0.1 my.localhost"
    echo ""
    
    # Start server
    yarn start:debug
}

start_gutenberg() {
    echo_info "Starting Gutenberg development server..."
    check_repo "gutenberg"
    
    cd repos/gutenberg
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version. Ensure nvm is installed."
    }
    
    current_node=$(node --version 2>/dev/null | sed 's/v//')
    if [[ ! "$current_node" == "20"* ]]; then
        echo_warning "Expected Node 20, found $current_node"
    fi
    
    # Check if WordPress Core is running (wp-env conflict)
    if lsof -ti:8889 > /dev/null 2>&1; then
        echo_warning "WordPress Core is running on port 8889"
        echo "Gutenberg wp-env may conflict. Consider using Storybook instead:"
        echo "  npm run storybook"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Check dependencies and build
    if [ ! -d "node_modules" ]; then
        echo_warning "Dependencies not installed. Running npm ci..."
        npm ci
    fi
    
    if [ ! -d "build" ] || [ -z "$(ls -A build 2>/dev/null)" ]; then
        echo_warning "Build assets not found. Building..."
        npm run build
    fi
    
    # Check port
    if ! check_port 9999 "Gutenberg"; then
        echo_error "Cannot start Gutenberg - port 9999 in use"
        return 1
    fi
    
    echo_success "Starting Gutenberg development environment..."
    echo "🌐 URL: http://localhost:9999"
    echo ""
    
    # Start server
    npm run dev
}

start_gutenberg_storybook() {
    echo_info "Starting Gutenberg Storybook..."
    check_repo "gutenberg"
    
    cd repos/gutenberg
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version"
    }
    
    # Check dependencies
    if [ ! -d "node_modules" ]; then
        echo_warning "Dependencies not installed. Running npm ci..."
        npm ci
    fi
    
    # Check port
    if ! check_port 50240 "Storybook"; then
        echo_error "Cannot start Storybook - port 50240 in use"
        return 1
    fi
    
    echo_success "Starting Gutenberg Storybook..."
    echo "🌐 URL: http://localhost:50240"
    echo "📚 Component library and documentation"
    echo ""
    
    # Start Storybook
    npm run storybook
}

start_wordpress_core() {
    echo_info "Starting WordPress Core development server..."
    check_repo "wordpress-core"
    
    cd repos/wordpress-core
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version"
    }
    
    current_node=$(node --version 2>/dev/null | sed 's/v//')
    if [[ ! "$current_node" == "20"* ]]; then
        echo_warning "Expected Node 20, found $current_node"
    fi
    
    # Check Docker
    if ! docker ps > /dev/null 2>&1; then
        echo_error "Docker is not running. Please start Docker Desktop."
        return 1
    fi
    
    # Check dependencies
    if [ ! -d "node_modules" ]; then
        echo_warning "Dependencies not installed. Running npm ci..."
        npm ci
    fi
    
    # Check build
    if [ ! -d "build" ] || [ -z "$(ls -A build 2>/dev/null)" ]; then
        echo_warning "Build assets not found. Building..."
        npm run build
    fi
    
    # Check port
    if ! check_port 8889 "WordPress Core"; then
        echo_error "Cannot start WordPress Core - port 8889 in use"
        return 1
    fi
    
    # Check Jetpack integration
    if [ -d "../jetpack" ] && [ ! -f "src/wp-content/mu-plugins/jetpack-monorepo-fix.php" ]; then
        echo_warning "Jetpack mu-plugin not found. Creating..."
        mkdir -p src/wp-content/mu-plugins/
        cat > src/wp-content/mu-plugins/jetpack-monorepo-fix.php << 'EOF'
<?php
/**
 * Jetpack Monorepo Development Fix
 */
add_filter( 'plugins_url', function( $url, $path, $plugin ) {
    if ( strpos( $plugin, 'jetpack' ) !== false ) {
        $url = str_replace( '/plugins/jetpack/projects/plugins/', '/plugins/', $url );
    }
    return $url;
}, 10, 3 );
EOF
        echo_success "Jetpack integration configured"
    fi
    
    echo_success "Starting WordPress Core..."
    echo "🌐 URLs:"
    echo "  • Frontend: http://localhost:8889"
    echo "  • Admin: http://localhost:8889/wp-admin/"
    echo "  • Username: admin"
    echo "  • Password: password"
    echo ""
    
    # Start wp-env
    npm run dev
}

start_jetpack() {
    echo_info "Starting Jetpack development watcher..."
    check_repo "jetpack"
    
    # Check if WordPress Core is running
    if ! lsof -ti:8889 > /dev/null 2>&1; then
        echo_error "WordPress Core is not running"
        echo "💡 Start WordPress Core first:"
        echo "  $0 core"
        echo ""
        echo "Then run Jetpack watcher in a separate terminal:"
        echo "  $0 jetpack"
        return 1
    fi
    
    cd repos/jetpack
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version"
    }
    
    current_node=$(node --version 2>/dev/null | sed 's/v//')
    if [[ ! "$current_node" == "22"* ]]; then
        echo_warning "Expected Node 22, found $current_node"
    fi
    
    # Check dependencies
    if [ ! -d "node_modules" ]; then
        echo_warning "JS dependencies not installed. Running pnpm install..."
        pnpm install
    fi
    
    if [ ! -d "vendor" ]; then
        echo_warning "PHP dependencies not installed. Running composer install..."
        if command -v composer > /dev/null; then
            composer install
        else
            echo_error "Composer not found. Install composer for PHP dependencies."
        fi
    fi
    
    # Check if built
    if [ ! -d "projects/plugins/jetpack/_inc/build" ]; then
        echo_warning "Jetpack not built. Building..."
        pnpm jetpack build plugins/jetpack --deps
    fi
    
    echo_success "Starting Jetpack watcher..."
    echo "🌐 Access via WordPress Core: http://localhost:8889/wp-admin/"
    echo "🔌 Jetpack will be available as a plugin"
    echo ""
    
    # Start watcher
    pnpm jetpack watch plugins/jetpack
}

start_ciab() {
    echo_info "Starting CIAB development server..."
    check_repo "ciab"
    
    cd repos/ciab
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version"
    }
    
    current_node=$(node --version 2>/dev/null | sed 's/v//')
    if [[ ! "$current_node" == "22"* ]]; then
        echo_warning "Expected Node 22, found $current_node"
    fi
    
    # Check Docker
    if ! docker ps > /dev/null 2>&1; then
        echo_error "Docker is not running. Please start Docker Desktop."
        return 1
    fi
    
    # Check dependencies
    if [ ! -d "node_modules" ]; then
        echo_warning "JS dependencies not installed. Running pnpm install..."
        pnpm install
    fi
    
    if [ ! -d "vendor" ]; then
        echo_warning "PHP dependencies not installed. Running composer install..."
        if command -v composer > /dev/null; then
            composer install
        else
            echo_warning "Composer not found. Some features may not work."
        fi
    fi
    
    # Check port
    if ! check_port 9001 "CIAB"; then
        echo_error "Cannot start CIAB - port 9001 in use"
        return 1
    fi
    
    echo_success "Starting CIAB..."
    echo "🌐 URL: http://localhost:9001/wp-admin/"
    echo "🏪 Commerce in a Box admin interface"
    echo "🔒 Requires: Automattic access"
    echo ""
    
    # Start server
    pnpm dev
}

start_telex() {
    echo_info "Starting Telex development server..."
    check_repo "telex"
    
    cd repos/telex
    
    # Check Node version
    source ~/.nvm/nvm.sh 2>/dev/null && nvm use 2>/dev/null || {
        echo_warning "Could not switch Node version"
    }
    
    # Check Docker for MinIO
    if ! docker ps > /dev/null 2>&1; then
        echo_error "Docker is not running. MinIO requires Docker."
        return 1
    fi
    
    # Check if MinIO is running
    if ! docker ps | grep -q telex-minio; then
        echo_warning "MinIO is not running. Starting MinIO..."
        if pnpm run minio:start; then
            echo_success "MinIO started"
            sleep 3  # Give MinIO time to start
        else
            echo_error "Failed to start MinIO"
            return 1
        fi
    fi
    
    # Check dependencies
    if [ ! -d "node_modules" ]; then
        echo_warning "Dependencies not installed. Running pnpm install..."
        pnpm install
    fi
    
    # Check environment variables
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo_warning "ANTHROPIC_API_KEY not set. AI features may not work."
    fi
    
    # Check port (may conflict with Calypso on localhost)
    if lsof -ti:3000 > /dev/null 2>&1; then
        local process=$(lsof -ti:3000)
        echo_warning "Port 3000 in use by PID $process"
        echo "This may be Calypso. Telex and Calypso can run together"
        echo "(different hosts: localhost vs calypso.localhost)"
    fi
    
    echo_success "Starting Telex..."
    echo "🌐 URLs:"
    echo "  • Telex: http://localhost:3000"
    echo "  • MinIO Admin: http://localhost:9001"
    echo "🤖 AI block authoring tool"
    echo "🔒 Requires: Automattic access + API keys"
    echo ""
    
    # Start server
    pnpm run dev
}

start_all() {
    echo_info "Starting multiple development servers..."
    echo_warning "This will start servers in background. Use 'jobs' to see them."
    echo ""
    
    # Start WordPress Core first (foundation)
    echo "1️⃣  Starting WordPress Core..."
    (cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm run dev) &
    CORE_PID=$!
    sleep 5
    
    # Start Calypso
    echo "2️⃣  Starting Calypso..."
    (cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn start:debug) &
    CALYPSO_PID=$!
    sleep 3
    
    # Start Gutenberg Storybook
    echo "3️⃣  Starting Gutenberg Storybook..."
    (cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm run storybook) &
    STORYBOOK_PID=$!
    sleep 3
    
    # Start Jetpack watcher
    if [ -d "repos/jetpack" ]; then
        echo "4️⃣  Starting Jetpack watcher..."
        (cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm jetpack watch plugins/jetpack) &
        JETPACK_PID=$!
    fi
    
    echo ""
    echo_success "Development servers starting..."
    echo "🌐 URLs (wait 30-60 seconds for full startup):"
    echo "  • WordPress Core: http://localhost:8889"
    echo "  • Calypso Legacy: http://calypso.localhost:3000"
    echo "  • Calypso Dashboard: http://my.localhost:3000" 
    echo "  • Storybook: http://localhost:50240"
    echo ""
    echo "💡 Monitor with: jobs"
    echo "💡 Stop all with: kill %1 %2 %3 %4"
    echo "💡 Or use: killall node"
    
    # Wait for user input
    echo ""
    echo "Press Ctrl+C to stop all servers"
    wait
}

# Show usage
show_usage() {
    echo "WordPress Ecosystem Development Server Manager"
    echo ""
    echo "Usage: $0 <service> [options]"
    echo ""
    echo "Services:"
    echo "  calypso      Start Calypso (React dashboard)"
    echo "  gutenberg    Start Gutenberg development environment"  
    echo "  storybook    Start Gutenberg Storybook (components)"
    echo "  core         Start WordPress Core (wp-env)"
    echo "  jetpack      Start Jetpack development watcher"
    echo "  ciab         Start CIAB admin interface"
    echo "  telex        Start Telex AI block authoring"
    echo "  all          Start multiple servers"
    echo ""
    echo "Examples:"
    echo "  $0 core                 # Start WordPress Core"
    echo "  $0 calypso             # Start Calypso dashboard"
    echo "  $0 storybook           # Start component library"
    echo "  $0 all                 # Start multiple servers"
    echo ""
    echo "Prerequisites:"
    echo "• Run setup first: ./skills/setup/scripts/setup.sh"
    echo "• Check status: ./skills/setup/scripts/status.sh"
}

# Main command routing
case "$1" in
    "calypso")
        start_calypso
        ;;
    "gutenberg")
        start_gutenberg
        ;;
    "storybook")
        start_gutenberg_storybook
        ;;
    "core")
        start_wordpress_core
        ;;
    "jetpack")
        start_jetpack
        ;;
    "ciab")
        start_ciab
        ;;
    "telex")
        start_telex
        ;;
    "all")
        start_all
        ;;
    *)
        show_usage
        ;;
esac