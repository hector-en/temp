# Scientific Report Template

This repository provides a comprehensive LaTeX-based template designed for generating well-structured, professional scientific reports. It can be adapted to various fields, ensuring consistency in formatting, citation, and documentation.

## Features

- **Structured LaTeX Templates**: Predefined sections such as abstract, introduction, methodology, results, and discussion are provided to help streamline the writing of scientific reports.
- **Customizable Document Class**: The repository includes a custom `labreport.cls` file to ensure that reports adhere to a specific format, with options for including tables, figures, and mathematical content.
- **Reference Management**: Integrated BibTeX support for managing citations, with a predefined bibliography format.
- **Automated Package Management**: Scripts to install and remove necessary LaTeX packages for compiling the reports.

## Project Structure

The project is organized into the following key directories:

- **`cls/`**: Contains the custom LaTeX class (`labreport.cls`) that defines the structure and formatting for the scientific reports.
- **`styles/`**: Holds additional style files for customizing the appearance of tables, figures, and references.
- **`figures/`**: Placeholder directory for images, graphs, and figures used in the reports.
- **`files/`**: Contains example content files like `abstract.tex`, `introduction.tex`, and `results.tex`, which demonstrate how to structure different sections of a scientific report.
- **`install/`**: Shell scripts for installing LaTeX dependencies (`install-latex.sh`), removing installed packages (`cleanup-latex.sh`), and project-specific setup scripts (`install-packages.sh`).

## Installation and Setup

To set up the LaTeX environment for compiling reports, follow these steps:

1. **Install LaTeX Packages**:
   Run the installation script to install all the necessary LaTeX packages:
   ```bash
   sudo ./install/install-latex.sh
   ```

2. **Cleanup LaTeX Packages**:
   If you want to remove all installed LaTeX packages, run the cleanup script:
   ```bash
   sudo ./install/cleanup-latex.sh
   ```

3. **Project-Specific Packages**:
   The project also comes with additional LaTeX packages tailored for specific scientific report requirements:
   ```bash
   sudo ./install/install-packages.sh
   ```

## How to Use

1. **Clone the Repository**:
   ```bash
   git clone git@github.com:username/repository-name.git
   ```

2. **Write Your Report**:
   Modify the `.tex` files in the `files/` directory to include your report content. Use the predefined structure for consistency:
   - `abstract.tex`
   - `introduction.tex`
   - `results.tex`
   - `discussion.tex`

3. **Compile the Report**:
   You can use a LaTeX editor like Gummi or VSCode with LaTeX Workshop extension. To compile manually:
   ```bash
   pdflatex your-report.tex
   ```

## Contribution Guidelines

- **Branching**: Create a new branch for each new feature or report adaptation.
- **Commits**: Write meaningful commit messages that explain your changes.
- **Pull Requests**: Ensure all LaTeX files compile successfully before submitting a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Developed by Hector Edu Nseng. This template is designed to be adaptable for various scientific disciplines and customizable to suit individual project needs.

