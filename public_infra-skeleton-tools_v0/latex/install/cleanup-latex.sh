#!/bin/bash

# Function to remove all LaTeX-related packages installed by the project-specific script
CleanupLatexPackages() {
    # Ensure the script is run with superuser privileges
    if [[ "$EUID" -ne 0 ]]; then
        echo "Please run as root or with sudo."
        exit 1
    fi

    # List of LaTeX-related packages that were installed
    packages=(
        texlive-latex-extra
        texlive-fonts-recommended
        texlive-fonts-extra
        texlive-science
        texlive-bibtex-extra
        texlive-formats-extra
        texlive-publishers
        texlive-xetex
        texlive-pictures
    )

    # Remove all LaTeX-related packages
    echo "Removing LaTeX packages..."
    sudo apt remove --purge -y "${packages[@]}"

    # Clean up any residual configuration files and dependencies
    echo "Cleaning up residual files and dependencies..."
    sudo apt autoremove -y
    sudo apt clean

    # Final message
    echo "LaTeX packages cleanup complete!"
}

# Call the cleanup function
CleanupLatexPackages
