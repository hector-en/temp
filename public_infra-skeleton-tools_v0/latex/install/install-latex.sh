#!/bin/bash

# Function to install generic LaTeX environment
InstallLaTeX() {
    # Update package index
    sudo apt update

    # Install basic LaTeX environment with German and UK English support
    sudo apt install -y texlive-latex-recommended texlive-lang-english texlive-lang-german

    # Remove non-relevant LaTeX language packages
    echo "Removing non-relevant LaTeX language packages..."
    sudo apt-get purge -y texlive-lang-other

    # Install optional GUI editors for LaTeX (optional)
    sudo apt install -y gummi texworks

    # Install PDF viewer and utilities for handling X display
    sudo apt install -y xdg-utils evince

    # Install LaTeX build tools for LaTeX Workshop in VSCode
    sudo apt install -y latexmk biber

    echo "Generic LaTeX installation complete."
}

# Call the generic LaTeX installation function
InstallLaTeX
