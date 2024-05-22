#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure Composer is installed
if command_exists composer; then
    echo "Composer is already installed."
else
    echo "Installing Composer..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
    fi
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
    echo "Composer installed successfully."
fi

# Ensure Laravel installer is installed
if command_exists laravel; then
    echo "Laravel installer is already installed."
else
    echo "Installing Laravel installer..."
    composer global require laravel/installer
    # Add Composer's global bin directory to the PATH
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo "Laravel installer installed successfully."
fi

# Check if an app name was provided as an argument.
if [ -z "$1" ]; then
    echo "Usage: $0 <app-name>"
    exit 1
fi

APP_NAME=$1

# Create new Laravel application
echo "Creating new Laravel application named $APP_NAME..."
laravel new $APP_NAME

# Change to the new application directory
cd $APP_NAME

# Set directory permissions
echo "Setting directory permissions..."
chmod -R 755 storage
chmod -R 755 bootstrap/cache

echo "Laravel application $APP_NAME created successfully."
