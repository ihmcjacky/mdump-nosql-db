#!/bin/bash

# MongoDB Database Export Script for Linux/macOS
# This script exports MongoDB database using mongodump with timestamp-based folder naming

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if mongodump is available
check_mongodump() {
    if ! command -v mongodump &> /dev/null; then
        print_error "mongodump command not found!"
        print_info "Please install MongoDB Database Tools:"
        print_info "  Ubuntu/Debian: sudo apt-get install mongodb-database-tools"
        print_info "  CentOS/RHEL: sudo yum install mongodb-database-tools"
        print_info "  macOS: brew install mongodb/brew/mongodb-database-tools"
        print_info "  Or download from: https://www.mongodb.com/try/download/database-tools"
        exit 1
    fi
}

# Function to get MongoDB credentials from environment variables
get_mongodb_credentials() {
    # Check for environment variables
    if [[ -z "$MONGODB_USERNAME" || -z "$MONGODB_PASSWORD" || -z "$MONGODB_HOST" || -z "$MONGODB_PORT" ]]; then
        print_warning "MongoDB credentials not found in environment variables."
        print_info "Please set the following environment variables:"
        print_info "  export MONGODB_USERNAME=your_username"
        print_info "  export MONGODB_PASSWORD=your_password"
        print_info "  export MONGODB_HOST=your_host (default: 192.168.1.10)"
        print_info "  export MONGODB_PORT=your_port (default: 27018)"
        print_info ""
        print_info "For security, you can add these to your ~/.bashrc or ~/.profile"
        print_info "Example:"
        print_info "  echo 'export MONGODB_USERNAME=db_username' >> ~/.bashrc"
        print_info "  echo 'export MONGODB_PASSWORD=db_passeword' >> ~/.bashrc"
        print_info "  echo 'export MONGODB_HOST=192.168.1.10' >> ~/.bashrc"
        print_info "  echo 'export MONGODB_PORT=27018' >> ~/.bashrc"
        print_info "  source ~/.bashrc"
        exit 1
    fi
}

# Function to create backup directory
create_backup_directory() {
    local timestamp=$(date +"%Y%m%d%H%M%S")
    local backup_dir="dbbackup-${timestamp}-qos-bigmenu"
    local target_dir=""

    # Try to create in current directory first
    if mkdir -p "$backup_dir" 2>/dev/null; then
        target_dir="$(pwd)/$backup_dir"
        print_success "Created backup directory: $target_dir"
    else
        # Fallback to Desktop
        print_warning "Cannot create directory in current location. Trying Desktop..."
        local desktop_dir="$HOME/Desktop"
        if [[ ! -d "$desktop_dir" ]]; then
            desktop_dir="$HOME"  # Fallback to home directory if Desktop doesn't exist
        fi

        target_dir="$desktop_dir/$backup_dir"
        if mkdir -p "$target_dir" 2>/dev/null; then
            print_success "Created backup directory: $target_dir"
        else
            print_error "Failed to create backup directory in both current location and Desktop/Home"
            exit 1
        fi
    fi

    echo "$target_dir"
}

# Function to perform MongoDB export
perform_export() {
    local backup_dir="$1"
    local mongodb_uri="mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOST}:${MONGODB_PORT}/?authSource=admin"

    print_info "Starting MongoDB export..."
    print_info "Target directory: $backup_dir"

    # Perform the mongodump
    if mongodump --uri="$mongodb_uri" --out="$backup_dir"; then
        print_success "MongoDB export completed successfully!"
        print_info "Backup saved to: $backup_dir"

        # Show directory contents
        print_info "Exported databases:"
        ls -la "$backup_dir"
    else
        print_error "MongoDB export failed!"
        exit 1
    fi
}

# Main execution
main() {
    print_info "MongoDB Database Export Script"
    print_info "=============================="

    # Check if mongodump is available
    check_mongodump

    # Get MongoDB credentials
    get_mongodb_credentials

    # Create backup directory
    backup_dir=$(create_backup_directory)

    # Perform export
    perform_export "$backup_dir"

    print_success "Export process completed!"
}

# Run main function
main "$@"