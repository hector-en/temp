#!/bin/bash

# Function to install project-specific LaTeX packages
InstallProjectSpecificLaTeX() {
    # Ensure the script is run with superuser privileges
    if [[ "$EUID" -ne 0 ]]; then
      echo "Please run as root or with sudo."
      exit 1
    fi

    # Update package index
    echo "Updating package index..."
    sudo apt update -y

    # Install additional project-specific LaTeX packages
    echo "Installing specific LaTeX packages used in the project..."
    
    # Install LaTeX package groups that contain required individual packages
    sudo apt install -y texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra \
        texlive-science texlive-bibtex-extra texlive-formats-extra texlive-publishers texlive-xetex texlive-pictures


    # Check if installation was successful
    if [[ $? -eq 0 ]]; then
        echo "Project-specific LaTeX packages installation complete."
    else
        echo "Error: Some packages failed to install."
        exit 1
    fi
}

# Call the project-specific LaTeX installation function
InstallProjectSpecificLaTeX