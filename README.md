To create a new Laravel application using a bash script, you'll first need to ensure that Composer (the PHP dependency manager) and Laravel are installed on your system. The script will handle the installation of Composer and Laravel if they aren't already installed, and then it will create a new Laravel project.

Here’s a complete bash script for creating a new Laravel application:

```bash
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

# Check if an app name was provided as an argument
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
```

### Steps to Use the Script:

1. **Save the Script**:
   Save the script to a file, for example, `create_laravel_app.sh`.

2. **Make the Script Executable**:
   Make the script executable by running:
   ```sh
   chmod +x create_laravel_app.sh
   ```

3. **Run the Script**:
   Run the script with the desired application name as an argument:
   ```sh
   ./create_laravel_app.sh my_new_app
   ```

### Explanation of the Script:

1. **Function to Check if a Command Exists**:
   This function checks if a command (like Composer or Laravel) is available in the system.

2. **Ensure Composer is Installed**:
   The script checks if Composer is installed. If not, it installs Composer.

3. **Ensure Laravel Installer is Installed**:
   The script checks if the Laravel installer is installed. If not, it installs the Laravel installer globally using Composer and ensures that Composer’s global bin directory is in the PATH.

4. **Check for Application Name Argument**:
   The script checks if an application name was provided as an argument. If not, it displays usage instructions and exits.

5. **Create New Laravel Application**:
   The script uses the Laravel installer to create a new Laravel application with the specified name.

6. **Set Directory Permissions**:
   The script sets the necessary directory permissions for the `storage` and `bootstrap/cache` directories.

This script automates the process of creating a new Laravel application, ensuring that all necessary tools are installed and configured correctly.
