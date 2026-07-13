#!/bin/bash
# -----------------------------------------------------------------------------
# Overview:
# This script processes project files, converts Jupyter notebooks to Python scripts if present,
# generates a summary for each file, and provides real-time feedback. It creates an output folder
# inside the project directory and then creates a symbolic link to the output directory in the specified output directory.
# -----------------------------------------------------------------------------

# Ensure necessary directories are created
setup_directories() {
    cleanup_on_error
    if [ -z "$1" ] || [ -z "$2" ]; then
        log_message "ERROR: Both project directory and output directory must be provided."
        exit 1
    fi

    PROJECT_DIR=$(realpath "$1")
    FINAL_OUTPUT_DIR=$(realpath "$2")

    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    PROJECT_BASE_DIR="$PROJECT_DIR/${TIMESTAMP}_code_analysis_output"
    PROJECT_OUTPUT_DIR="$PROJECT_BASE_DIR/reports"
    CONVERTED_OUTPUT_DIR="$PROJECT_BASE_DIR/converted_files"

    if [ ! -d "$PROJECT_BASE_DIR" ]; then
        mkdir -p "$PROJECT_BASE_DIR" "$PROJECT_OUTPUT_DIR" "$CONVERTED_OUTPUT_DIR" || {
            log_message "ERROR: Failed to create project-specific directories."
            exit 1
        }
    fi
}
# Function to initialize files and variables
initialize_files() {
    cleanup_on_error
    OUTPUT_FILE="$PROJECT_OUTPUT_DIR/code_full_summary.txt"
    ERROR_FILE="$PROJECT_OUTPUT_DIR/output.log"
    HIGHLEVEL_FILE="$PROJECT_OUTPUT_DIR/code_highlevel_summary.txt"
    PYCACHE_OUTPUT_FILE="$PROJECT_OUTPUT_DIR/code_pycache_summary.txt"

    touch "$OUTPUT_FILE" "$ERROR_FILE" "$HIGHLEVEL_FILE" "$PYCACHE_OUTPUT_FILE" || { log_message "ERROR: Failed to create output files."; exit 1; }
    TOC="Table of Contents (TOC):\n"
    TOC_INDEX=1
    PYCACHE_TOC="PYCACHE SOURCE FILES TOC:\n"
    PYCACHE_TOC_INDEX=1
    declare -A pyc_to_py_map

    CRITICAL_ERROR=0
}


# Helper function to log messages to both the screen and a log file
log_message() {
    local message="$1"
    echo "$message" | tee -a "$ERROR_FILE"
}

# Cleanup function in case of critical errors
cleanup_on_error() {
    if [ "$CRITICAL_ERROR" -eq 1 ]; then
        log_message "Critical error encountered. Exiting." >&2
        rm -f "$OUTPUT_FILE" "$ERROR_FILE" "$HIGHLEVEL_FILE" "$PYCACHE_OUTPUT_FILE"
        rm -f -R "$PROJECT_OUTPUT_DIR"
        exit 1
    fi
}

# Function to check connectivity to a given host
check_connectivity() {
    local host=$1
    echo "Checking connectivity to $host..."
    
    if ping -c 4 "$host" > /dev/null 2>&1; then
        echo "Successfully reached $host."
        return 0  # Success
    else
        echo "Failed to reach $host."
        return 1  # Failure
    fi
}

# Function to set Google DNS servers for more reliable connections
set_google_dns() {
    local google_dns1="8.8.8.8"
    local google_dns2="8.8.4.4"

    # Check if we have sudo privileges
    if ! sudo -v; then
        log_message "You must have sudo privileges to set DNS."
        return 1
    fi

    # Check if Google DNS servers are already set
    if grep -qE "$google_dns1|$google_dns2" /etc/resolv.conf; then
        echo "Google DNS servers are already set."
        return 0
    fi

    # Write Google DNS entries to resolv.conf
    echo "Setting Google DNS..."
    echo "nameserver $google_dns1" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver $google_dns2" | sudo tee -a /etc/resolv.conf > /dev/null

    log_message "Google DNS has been set successfully."
}

# Function to retry command up to 3 times with fallback to Google DNS on the 3rd try
retry_command_with_dns_fallback() {
    local retries=2
    local count=0
    local delay=5
    local host=$1  # Not used in this example, but could be used for connectivity check
    shift  # Shifts the command to be retried to the remaining arguments

    # First 2 attempts without DNS change
    while [ $count -lt $retries ]; do
        echo "Attempting command ($((count + 1))/$((retries + 1)))..."
        if "$@"; then
            echo "Command succeeded."
            return 0
        fi
        count=$((count + 1))
        echo "Retrying ($count/$((retries + 1))) after ${delay}s..."
        sleep $delay
    done

    # Switch to Google DNS for the final attempt
    log_message "Switching to Google DNS for the final attempt..."
    set_google_dns || { echo "Failed to set Google DNS."; return 1; }

    # Final attempt with Google DNS
    echo "Attempting the final command with Google DNS..."
    if "$@"; then
        echo "Command succeeded with Google DNS."
        return 0
    else
        log_message "Error: Command failed after retrying with Google DNS."
        return 1
    fi
}


# Function to check if a package is installed; if not, install it with retry logic and Google DNS fallback
ensure_package_installed() {
    local package="$1"
    if ! command -v "$package" &> /dev/null; then
        log_message "$package is not installed. Installing..."

        # Retry command 2x, then fallback to Google DNS on the 3rd attempt
        retry_command_with_dns_fallback "pypi.org" pip3 install --user "$package" > /dev/null 2>>"$ERROR_FILE" || {
            log_message "Error installing $package after retries."
            CRITICAL_ERROR=1
            return 1
        }
    else
        echo "$package is already installed."
    fi
}

# Function to install pyenv if it is not installed
install_pyenv() {
    log_message "Installing pyenv..."

    # Retry command 2x, then fallback to Google DNS on the 3rd attempt
    retry_command_with_dns_fallback "github.com" curl -L https://pyenv.run -o pyenv_installer.sh || { 
        log_message "Error downloading pyenv installation script. Please install it manually."; 
        CRITICAL_ERROR=1; 
        return 1; 
    }

    # Execute the installer script
    bash pyenv_installer.sh || {
        log_message "Error running pyenv installation script."; 
        CRITICAL_ERROR=1; 
        return 1;
    }

    # Remove the installer script after execution
    rm pyenv_installer.sh

    # Set up the required environment variables
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    if command -v pyenv &> /dev/null; then
        log_message "pyenv installed successfully."
        exit 1
    else
        log_message "Error installing pyenv after retries. Please install it manually."
        CRITICAL_ERROR=1
    fi
}

# Function to ensure pyenv is installed
ensure_pyenv_installed() {
    if ! command -v pyenv &> /dev/null; then
        echo "Error: pyenv is not installed. Please install it manually."
        CRITICAL_ERROR=1
        return 1
    else
        echo "pyenv is already installed."
    fi
}

# Function to check if a Python package is installed
ensure_python_package_installed() {
    local package_name="$1"

    # Check if the Python package is installed by attempting to import it in Python
    if ! python3 -c "import $package_name" &> /dev/null; then
        log_message "Python package '$package_name' is not installed. Installing..."
        # Try installing the Python package
        pip3 install "$package_name" || {
            log_message "Error: Failed to install Python package '$package_name'."
            CRITICAL_ERROR=1
            return 1
        }
    else
        log_message "Python package '$package_name' is already installed."
    fi
}

# Ensure necessary tools are installed
ensure_tools_installed() {
    cleanup_on_error

    # Check for pyenv
    ensure_pyenv_installed || cleanup_on_error

    # Ensure jupyter-nbconvert and uncompyle6 are installed using pip
    ensure_package_installed "jupyter-nbconvert" || cleanup_on_error
    ensure_package_installed "uncompyle6" || cleanup_on_error

    # Ensure python-pptx is installed for PowerPoint conversion
    ensure_python_package_installed "pptx" || cleanup_on_error

    # Ensure PyPDF2 is installed for PDF to text conversion
    cleanup_on_error
    #ensure_package_installed "PyPDF2" || cleanup_on_error
}

# Function to generate descriptions based on function names and comments
generate_description() {
    local name="$1"
    local file="$2"
    local line_number="$3"
    local description=""

    # Extract any comments or docstrings above the definition (up to 5 lines before)
    comments=$(awk "NR<$line_number" "$file" | tail -n 5 | grep -E '^[[:space:]]*#|"""' | sed 's/^/# /')

    case $name in
        deploy*) description+="Deploys cloud resources (e.g., VMs, containers, or functions) to a cloud provider like AWS, Azure, or GCP." ;;
        provision*) description+="Provisions cloud infrastructure, such as virtual machines, storage, or networking resources." ;;
        configure*) description+="Configures cloud services or infrastructure (e.g., load balancers, firewalls, IAM roles)." ;;
        scale*) description+="Scales cloud resources up or down (e.g., autoscaling VMs or containers)." ;;
        monitor*) description+="Monitors cloud resource usage, performance, and health (e.g., CloudWatch, Azure Monitor)." ;;
        start*|stop*) description+="Starts or stops cloud services or virtual machines." ;;
        backup*) description+="Creates backups of cloud resources or databases (e.g., snapshots or database dumps)." ;;
        restore*) description+="Restores resources or data from cloud backups or snapshots." ;;
        failover*) description+="Handles cloud service failover, ensuring high availability (e.g., multi-region failover)." ;;
        migrate*) description+="Migrates workloads or data across cloud environments (e.g., cloud-to-cloud migration)." ;;
        optimize*) description+="Optimizes cloud infrastructure for cost-efficiency or performance (e.g., rightsizing instances)." ;;
        shutdown*|terminate*) description+="Shuts down or terminates cloud resources, such as virtual machines or databases." ;;
        replicate*) description+="Replicates cloud data across multiple regions or zones for redundancy and availability." ;;
        orchestrate*) description+="Orchestrates cloud resources using automation tools (e.g., Kubernetes, Terraform)." ;;
        autoscale*) description+="Automatically scales cloud resources based on demand (e.g., scaling policies in AWS, GCP)." ;;
        loadbalance*) description+="Distributes traffic across cloud resources using load balancers (e.g., ALB, ELB)." ;;
        network*) description+="Configures cloud networking (e.g., virtual private clouds (VPCs), subnets, routing tables)." ;;
        firewall*) description+="Sets up or configures cloud firewalls for network security." ;;
        dns*) description+="Manages DNS entries for cloud services (e.g., Route 53, Cloud DNS)." ;;
        storage*) description+="Manages cloud storage resources (e.g., S3 buckets, Azure Blob Storage)." ;;
        bucket*) description+="Creates or manages cloud storage buckets (e.g., S3, Azure Blob containers)." ;;
        event*) description+="Handles cloud events and triggers (e.g., AWS Lambda triggers, Azure Event Grid)." ;;
        log*) description+="Manages cloud logging and auditing services (e.g., CloudWatch Logs, Azure Monitor Logs)." ;;
        cost*) description+="Monitors or optimizes cloud cost and usage (e.g., AWS Cost Explorer, GCP Cost Management)." ;;
        quota*) description+="Manages cloud resource quotas (e.g., checking or increasing resource limits)." ;;
        instance*) description+="Manages cloud compute instances (e.g., EC2, Google Compute Engine)." ;;
        encryption*) description+="Encrypts data stored in the cloud (e.g., using KMS, CloudHSM)." ;;
        key*) description+="Manages encryption keys for cloud services (e.g., AWS KMS, Azure Key Vault)." ;;
        healthcheck*) description+="Sets up health checks for cloud services to ensure availability." ;;
        patch*) description+="Applies security patches or updates to cloud resources (e.g., VMs, containers)." ;;
        region*) description+="Manages cloud resources across multiple regions (e.g., multi-region deployments)." ;;
        role*) description+="Configures IAM roles and permissions for cloud services (e.g., AWS IAM, Azure AD)." ;;
        container*) description+="Manages containers in the cloud (e.g., ECS, EKS, AKS, Google Kubernetes Engine)." ;;
        lambda*) description+="Deploys or manages serverless functions in the cloud (e.g., AWS Lambda, Azure Functions)." ;;
        serviceaccount*) description+="Manages cloud service accounts for accessing services (e.g., GCP Service Accounts)." ;;
        stream*) description+="Handles streaming data in the cloud (e.g., AWS Kinesis, Azure Event Hub)." ;;
        policy*) description+="Manages cloud resource policies (e.g., security policies, access control policies)." ;;
        build*) description+="Builds software or system components, typically as part of a CI/CD pipeline." ;;
        test*) description+="Runs automated tests, including unit, integration, or performance tests." ;;
        deploy*) description+="Deploys software, infrastructure, or changes to production environments as part of a CI/CD pipeline." ;;
        rollback*) description+="Rolls back a deployment to a previous version in case of errors or failures." ;;
        release*) description+="Manages software releases, likely tagging, versioning, or publishing releases." ;;
        monitor*) description+="Monitors the application or infrastructure health and performance using tools like Prometheus, Grafana, or Datadog." ;;
        alert*) description+="Sets up alerting mechanisms for monitoring failures, outages, or performance issues." ;;
        configure*) description+="Configures infrastructure or application settings (e.g., setting environment variables, configuring CI/CD pipelines)." ;;
        pipeline*) description+="Defines or manages CI/CD pipelines for automated testing, building, and deploying." ;;
        job*) description+="Manages scheduled or ad-hoc jobs in a CI/CD pipeline." ;;
        artifact*) description+="Handles build artifacts, such as compiling, storing, or distributing them." ;;
        environment*) description+="Manages development, staging, or production environments." ;;
        automate*) description+="Automates DevOps processes (e.g., continuous integration, continuous delivery, infrastructure deployment)." ;;
        destroy*) description+="Destroys or tears down infrastructure resources, usually as part of testing or decommissioning." ;;
        validate*) description+="Validates infrastructure or configuration before deploying to production." ;;
        version*) description+="Handles versioning of software, infrastructure, or configuration." ;;
        orchestrate*) description+="Orchestrates the deployment and scaling of infrastructure and applications (e.g., using Kubernetes)." ;;
        ansible*) description+="Automates infrastructure management using Ansible scripts." ;;
        chef*) description+="Configures infrastructure using Chef recipes for automation." ;;
        puppet*) description+="Manages configurations using Puppet manifests and modules." ;;
        terraform*) description+="Automates provisioning of infrastructure using Terraform as IaC." ;;
        buildspec*) description+="Defines build specifications for CI/CD pipelines, usually used in AWS CodeBuild." ;;
        webhook*) description+="Manages webhooks for CI/CD events and notifications." ;;
        api*) description+="Manages API integrations or API endpoints for DevOps automation." ;;
        trigger*) description+="Triggers automated actions in response to events, often used in CI/CD workflows." ;;
        commit*) description+="Manages code commits, likely pushing or pulling from a Git repository." ;;
        pullrequest*) description+="Handles pull requests for code reviews and merges." ;;
        s3sync*) description+="Syncs local files or artifacts to Amazon S3 storage." ;;
        ec2manage*) description+="Manages EC2 instances, starting, stopping, or provisioning them." ;;
        k8s*|kubectl*) description+="Manages Kubernetes clusters, pods, or deployments." ;;
        train*) description+="Trains a machine learning model on a dataset." ;;
        fit*) description+="Fits a model to the data, used to start the training process." ;;
        evaluate*) description+="Evaluates model performance using a test set and metrics such as accuracy, F1 score, etc." ;;
        predict*) description+="Uses a trained machine learning model to generate predictions on unseen data." ;;
        preprocess*) description+="Performs preprocessing on data, such as scaling, encoding, or cleaning." ;;
        feature*) description+="Handles feature engineering tasks, such as feature extraction or feature selection." ;;
        crossvalidate*) description+="Performs cross-validation to evaluate model generalization." ;;
        hyperparametertune*) description+="Tunes hyperparameters of the model using grid search, random search, or Bayesian optimization." ;;
        model*) description+="Manages machine learning models, saving, loading, or exporting them for deployment." ;;
        infer*) description+="Runs inference on new data using a trained model." ;;
        gridsearch*) description+="Performs grid search to find optimal hyperparameters for the model." ;;
        pipeline*) description+="Manages the machine learning pipeline, chaining together data processing, model training, and evaluation steps." ;;
        loadmodel*) description+="Loads a pre-trained model from storage." ;;
        savemodel*) description+="Saves the trained model to storage for future use." ;;
        exportmodel*) description+="Exports a trained model in a specific format (e.g., TensorFlow, ONNX) for deployment." ;;
        label*) description+="Handles labeling of datasets, likely for supervised learning tasks." ;;
        augmentdata*) description+="Applies data augmentation techniques to increase the diversity of the training dataset." ;;
        sample*) description+="Samples data from a dataset, likely for training or evaluation purposes." ;;
        biasdetect*) description+="Detects bias in a machine learning model or dataset." ;;
        weight*) description+="Handles weights of a neural network or machine learning model during training." ;;
        normalize*) description+="Normalizes data by scaling features to a common range." ;;
        tokenize*) description+="Splits text into tokens (words, sentences, etc.) for further processing in NLP." ;;
        lemmatize*) description+="Reduces words to their base or root form in a text (lemmatization)." ;;
        stem*) description+="Performs stemming, reducing words to their base form by removing suffixes." ;;
        pos*) description+="Performs part-of-speech tagging for words in a sentence." ;;
        ner*) description+="Performs named entity recognition to extract entities like people, locations, and organizations." ;;
        embed*|embeddings*) description+="Generates vector embeddings from text for use in NLP models." ;;
        vectorize*) description+="Converts text data into numerical vectors (e.g., TF-IDF, Word2Vec, GloVe)." ;;
        translate*) description+="Translates text from one language to another using NLP models." ;;
        sentiment*) description+="Performs sentiment analysis on text to determine positive, negative, or neutral sentiment." ;;
        summarize*) description+="Summarizes large text documents or bodies of text using NLP models." ;;
        classifytext*) description+="Classifies text into predefined categories (e.g., spam vs non-spam)." ;;
        extractkeyword*) description+="Extracts key phrases or keywords from text." ;;
        extractentity*) description+="Extracts named entities (e.g., person, location) from text using named entity recognition (NER)." ;;
        tag*) description+="Tags parts of speech in a sentence (e.g., noun, verb, adjective)." ;;
        detectlanguage*) description+="Detects the language of a given text." ;;
        generate*) description+="Generates text based on a language model (e.g., GPT, BERT)." ;;
        parse*) description+="Parses sentences into syntactic trees or structures." ;;
        cleantext*) description+="Cleans and preprocesses raw text by removing unwanted characters, punctuation, or stopwords." ;;
        load*) description+="Loads data from a source, likely for processing or analysis." ;;
        transform*) description+="Transforms data (e.g., data wrangling, normalization, scaling) as part of an ETL pipeline." ;;
        extract*) description+="Extracts data from a source, likely in an ETL (Extract, Transform, Load) process." ;;
        clean*|deduplicate*) description+="Cleans or deduplicates data to remove errors or inconsistencies." ;;
        ingest*) description+="Ingests data into a data pipeline or storage system." ;;
        pipeline*) description+="Manages data processing pipelines for transforming or moving data." ;;
        export*) description+="Exports processed data to external systems, APIs, or files." ;;
        aggregate*) description+="Aggregates data for analysis or reporting." ;;
        merge*) description+="Merges multiple datasets or tables based on key fields." ;;
        partition*) description+="Partitions data for distributed processing or storage." ;;
        filter*) description+="Filters data based on certain criteria." ;;
        validate*) description+="Validates data for consistency, correctness, and integrity." ;;
        deduplicate*) description+="Removes duplicate records from a dataset to improve data quality." ;;
        index*) description+="Indexes data to improve search and retrieval performance." ;;
        cache*) description+="Caches data for faster access during processing." ;;
        join*) description+="Joins datasets or tables based on a shared key or field." ;;
        schedule*) description+="Schedules data processing tasks for execution at specific intervals." ;;
        query*) description+="Executes a query on a database to retrieve, update, or manipulate data." ;;
        index*) description+="Creates or manages indexes in a database to improve query performance." ;;
        backup*) description+="Creates a backup of the database to ensure data durability and recovery." ;;
        restore*) description+="Restores a database from a backup in case of failure or data loss." ;;
        migrate*) description+="Migrates database schemas or data across different environments." ;;
        shard*) description+="Shards a database for horizontal scalability." ;;
        replicate*) description+="Replicates a database or data across multiple locations for fault tolerance." ;;
        schema*) description+="Defines or manages database schemas and structure." ;;
        transaction*) description+="Manages database transactions, ensuring atomicity and consistency." ;;
        optimize*) description+="Optimizes database queries and indexes for improved performance." ;;
        rollback*) description+="Rolls back a database to a previous state in case of failure." ;;
        user*) description+="Manages database users and their access rights." ;;
        grant*) description+="Grants permissions to users for accessing database resources." ;;
        revoke*) description+="Revokes permissions from users for accessing database resources." ;;
        lock*) description+="Locks database tables or rows to ensure transaction consistency." ;;
        unlock*) description+="Unlocks previously locked tables or rows in the database." ;;
        encrypt*) description+="Encrypts data for security purposes, ensuring confidentiality." ;;
        decrypt*) description+="Decrypts data that has been previously encrypted." ;;
        authenticate*) description+="Handles user authentication, validating credentials for access." ;;
        authorize*) description+="Handles user authorization, ensuring they have the appropriate access permissions." ;;
        audit*) description+="Performs an audit of system access, logs, or configurations for security compliance." ;;
        firewall*) description+="Manages firewall rules and policies for network security." ;;
        vpn*) description+="Configures or manages VPN connections for secure remote access." ;;
        hash*) description+="Generates a cryptographic hash of data for integrity checks or security purposes." ;;
        salt*) description+="Applies salting to passwords or other sensitive data before hashing." ;;
        sign*) description+="Signs data or messages using digital signatures for verification." ;;
        verify*) description+="Verifies the integrity, authenticity, or security of data." ;;
        accesscontrol*) description+="Manages access control policies to ensure data security and privacy." ;;
        token*) description+="Generates or validates security tokens for authentication or authorization." ;;
        session*) description+="Manages user sessions, ensuring secure access." ;;
        keymanagement*) description+="Manages encryption keys for securing data, likely using KMS or HSM." ;;
        certificate*) description+="Handles SSL/TLS certificates for securing communications." ;;
        vulnerabilityscan*) description+="Performs a vulnerability scan of systems or applications." ;;
        penetrationtest*) description+="Performs a penetration test to identify and exploit vulnerabilities." ;;
        threatdetection*) description+="Detects potential security threats or malicious activities in the system." ;;
        connectdevice*) description+="Establishes a connection to an IoT device." ;;
        disconnectdevice*) description+="Disconnects from an IoT device, likely to save power or network resources." ;;
        readsensor*) description+="Reads data from an IoT sensor (e.g., temperature, humidity, or motion sensors)." ;;
        writesensor*) description+="Writes configuration or data to an IoT sensor." ;;
        controlswitch*) description+="Controls an IoT switch (e.g., turning devices on or off remotely)." ;;
        transmitdata*) description+="Transmits data from an IoT device to a cloud service or database." ;;
        receivedata*) description+="Receives data from an IoT device for processing or storage." ;;
        monitordevice*) description+="Monitors the health or status of an IoT device, likely for alerts." ;;
        updatedevice*) description+="Updates the firmware or software on an IoT device." ;;
        provisiondevice*) description+="Provisions an IoT device for use in the network, registering it with cloud services." ;;
        calibratesensor*) description+="Calibrates an IoT sensor for accurate data measurement." ;;
        controlactuator*) description+="Controls an IoT actuator to perform physical actions (e.g., controlling motors, lights)." ;;
        registerdevice*) description+="Registers an IoT device with a cloud service or IoT platform." ;;
        deregisterdevice*) description+="Deregisters an IoT device, removing it from a cloud platform." ;;
        encryptdata*) description+="Encrypts data collected from an IoT device for secure transmission." ;;
        decryptdata*) description+="Decrypts data received from an IoT device for processing." ;;
        logsensor*) description+="Logs data from IoT sensors for analysis or troubleshooting." ;;
        syncdevice*) description+="Syncs data between an IoT device and the cloud." ;;
        sendcommand*) description+="Sends commands to an IoT device, possibly to control its behavior." ;;
    esac

    # Append comments to the description if available
    if [ -n "$comments" ]; then
        description+="\nAdditional comments: $comments"
    fi

    # Output the generated description
    echo "$description"
}

# Summarize project files and Python files
summarize_files() {
    cleanup_on_error
    local file="$1"
    local relative_file_path="${file#$PROJECT_DIR/}" # Get relative path from project directory
    
    # Add the file name (not full path) to the TOC with a numbered list
    filename=$(basename "$file")   # Get only the file name
    TOC+="$TOC_INDEX. $relative_file_path\n"
    ((TOC_INDEX++))

    # Add the file name (not full path) to the TOC with a numbered list
    echo -e "#########################################\n=== START OF ANALYSIS FOR $file ===\n#########################################" >> "$OUTPUT_FILE"
    echo -e "#########################################\n=== START OF ANALYSIS FOR $file ===\n#########################################" >> "$HIGHLEVEL_FILE"

    if [[ "$file" == *.py ]]; then
        # Overview for both the detailed and high-level summaries
        echo "Overview for $file:" >> "$OUTPUT_FILE"
        echo "Overview for $file:" >> "$HIGHLEVEL_FILE"
        class_count=$(grep -o 'class ' "$file" | wc -l)
        function_count=$(grep -o 'def ' "$file" | wc -l)
        functions=$(grep -E 'class |def ' "$file" | awk '{print $2}' | head -n 3 | paste -sd ",")
        echo "This script defines $class_count class(es) and $function_count function(s), implementing logic for $functions." >> "$OUTPUT_FILE"
        echo "This script defines $class_count class(es) and $function_count function(s), implementing logic for $functions." >> "$HIGHLEVEL_FILE"
        echo "---" >> "$OUTPUT_FILE"
        echo "---" >> "$HIGHLEVEL_FILE"

        # Generate the summary for imports, classes, and functions for both detailed and high-level summaries
        generate_summary "$file"

    else
        # Overview for non-Python files
        echo "Overview for $file:" >> "$OUTPUT_FILE"
        echo "Overview for $file:" >> "$HIGHLEVEL_FILE"
        file_size=$(stat --format="%s" "$file" 2>>"$ERROR_FILE")
        file_type=$(file -b "$file" 2>>"$ERROR_FILE")
        echo "This file is a $file_type with a size of $file_size bytes." >> "$OUTPUT_FILE"
        echo "This file is a $file_type with a size of $file_size bytes." >> "$HIGHLEVEL_FILE"
        echo "---" >> "$OUTPUT_FILE"
        echo "---" >> "$HIGHLEVEL_FILE"
        
        # Generate detailed summary for non-Python files (without full content in high-level summary)
        echo "Full content for $file:" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

get_python_version_from_pyc() {
    cleanup_on_error
    local pyc_file="$1"
    local version_info

    # Extract the Python version from the .pyc file name (e.g., cpython-37 means Python 3.7)
    version_info=$(echo "$pyc_file" | sed -n 's/.*cpython-\([0-9]\{2\}\).*/\1/p')

    if [ -z "$version_info" ]; then
        echo "Unknown"
    else
        # Convert 37 to 3.7, 38 to 3.8, etc.
        python_version="${version_info:0:1}.${version_info:1:1}"
        
        # Use pyenv shell to switch to the correct Python version temporarily without creating .python-version
        pyenv shell "$python_version"
        
        echo "$python_version"
    fi
}


# Function to install or switch to required Python versions using pyenv
install_pyenv_versions() {
    local versions=("$@")

    for version in "${versions[@]}"; do
        if pyenv versions --bare | grep -q "$version"; then
            echo "Python version $version is already installed with pyenv."
            
            # Attempt to switch to the Python version using pyenv
            if pyenv local "$version" || pyenv global "$version"; then
                echo "Successfully switched to Python version $version."
            else
                echo "Error: Failed to switch to Python version $version. Trying to install it..."
                retry_command_with_dns_fallback "github.com" pyenv install "$version" || {
                    echo "Error: Failed to install Python version $version after retries."
                    CRITICAL_ERROR=1
                    return 1
                }

                # Verify installation success and switch
                if pyenv versions --bare | grep -q "$version"; then
                    echo "Python version $version installed successfully."
                    pyenv local "$version" || pyenv global "$version"
                else
                    echo "Error: Python version $version installation failed. Check logs for details."
                    CRITICAL_ERROR=1
                    return 1
                fi
            fi
        else
            echo "Python version $version not found. Installing with pyenv..."
            retry_command_with_dns_fallback "github.com" pyenv install "$version" || {
                echo "Error: Failed to install Python version $version after retries."
                CRITICAL_ERROR=1
                return 1
            }

            # Verify installation success and switch
            if pyenv versions --bare | grep -q "$version"; then
                echo "Python version $version installed successfully."
                pyenv local "$version" || pyenv global "$version"
            else
                echo "Error: Python version $version installation failed. Check logs for details."
                CRITICAL_ERROR=1
                return 1
            fi
        fi
    done
}


decompile_pyc_files() {
    log_message "Decompiling .pyc files..."

    # Store the current Python version
    current_python_version=$(pyenv version-name)

    # Collect all .pyc files in __pycache__
    pyc_files=$(find "$PROJECT_DIR" -type f -name "*.pyc" -path "*/__pycache__/*")

    # Prepare the output file (clear or create it)
    > "$PYCACHE_OUTPUT_FILE"  # Create or clear the file

    for pyc_file in $pyc_files; do
        # Get the absolute path of the pyc file
        absolute_pyc_file=$(realpath "$pyc_file")

        # Determine the Python version from the .pyc file
        python_version=$(get_python_version_from_pyc "$pyc_file")

        # Skip if the Python version is unknown
        if [ "$python_version" == "Unknown" ]; then
            log_message "Unknown Python version for $absolute_pyc_file. Skipping..."
            continue
        fi

        log_message "Switching to Python version $python_version for decompiling $absolute_pyc_file"

        # Switch to required Python version
        if ! pyenv versions --bare | grep -q "$python_version"; then
            log_message "Python version $python_version is not installed. Installing..."
            install_pyenv_versions "$python_version"
        fi
        pyenv shell "$python_version"

        # Add a separator before each decompiled output for clarity
        echo -e "\n\n# Decompiled content of $absolute_pyc_file\n" >> "$PYCACHE_OUTPUT_FILE"

        # Decompile the .pyc file and capture output
        uncompyle6_output=$(uncompyle6 "$absolute_pyc_file" 2>&1)

        if [[ $? -eq 0 ]]; then
            log_message "Successfully decompiled $absolute_pyc_file"
            # Write decompiled output to the output file
            echo "$uncompyle6_output" >> "$PYCACHE_OUTPUT_FILE"
        else
            log_message "Error decompiling $absolute_pyc_file: $uncompyle6_output"
        fi
    done

    # Switch back to the original Python version
    pyenv shell "$current_python_version"
}


# Function to generate TOC for regular Python files based on the given entry format, with duplicate removal
generate_toc_for_regular_files() {
    log_message "Generating TOC for regular Python files from OUTPUT_FILE..."

    TOC="Table of Contents (TOC):\n"
    TOC_INDEX=1
    declare -A seen_files  # Associative array to keep track of seen files

    # Extract the name of the project folder (last component of the PROJECT_DIR path)
    project_folder=$(basename "$PROJECT_DIR")

    # Read through the OUTPUT_FILE to extract .py file paths based on the specified format
    while IFS= read -r line; do
        # Match lines that start with "=== START OF ANALYSIS FOR <absolute_path_to_py_file> ==="
        if [[ "$line" =~ ^===\ START\ OF\ ANALYSIS\ FOR\ (.*)\ ===$ ]]; then
            absolute_py_file="${BASH_REMATCH[1]}"
            # Convert the absolute path to a relative path based on the project folder
            relative_py_file="${absolute_py_file#*$project_folder/}"

            # Check if the file has already been seen; if not, add to TOC
            if [[ -z "${seen_files[$relative_py_file]}" ]]; then
                TOC+="$TOC_INDEX. $relative_py_file\n"
                ((TOC_INDEX++))
                seen_files["$relative_py_file"]=1  # Mark this file as seen
            fi
        fi
    done < "$OUTPUT_FILE"

    # Append the TOC for regular files to the output file
    echo -e "$TOC\n===================================\n" > "$OUTPUT_FILE.tmp"
    cat "$OUTPUT_FILE" >> "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

    log_message "TOC generation for regular files complete."
}

# Function to generate TOC for decompiled .pyc files and their associated .py files, with duplicate removal
generate_toc_for_pyc_files() {
    log_message "Generating TOC for decompiled .pyc files from PYCACHE_OUTPUT_FILE..."

    declare -A seen_pyc_files  # Associative array to keep track of seen .pyc files
    PYCACHE_TOC="PYCACHE FILES TOC:\n"
    current_pyc_file=""
    py_files=()  # List to hold associated .py files
    
    # Extract the name of the project folder (last component of the PROJECT_DIR path)
    project_folder=$(basename "$PROJECT_DIR")

    # Read through the PYCACHE_OUTPUT_FILE and store each .pyc block
    while IFS= read -r line; do
        # Check for "okay decompiling" marker for .pyc file
        if [[ "$line" =~ \#\ okay\ decompiling\ (.*\.pyc) ]]; then
            # Save the current .pyc file and its py_files block
            if [[ -n "$current_pyc_file" ]]; then
                if [[ -z "${seen_pyc_files[$current_pyc_file]}" ]]; then
                    PYCACHE_TOC+="$current_pyc_file\n"
                    for py_file in "${py_files[@]}"; do
                        PYCACHE_TOC+="   |-- $py_file\n"
                    done
                    PYCACHE_TOC+="\n"  # Add space between blocks
                    seen_pyc_files["$current_pyc_file"]=1  # Mark this .pyc file as seen
                fi
            fi
            # Start a new .pyc block
            current_pyc_file="${BASH_REMATCH[1]}"
            py_files=()  # Reset the list of associated .py files
        # Check for the embedded Python file name
        elif [[ "$line" =~ Embedded\ file\ name:\ (.*\.py)$ ]]; then
            absolute_py_file="${BASH_REMATCH[1]}"
            relative_py_file="${absolute_py_file#*$project_folder/}"
            py_files+=("$relative_py_file")  # Add to the list of associated .py files
        fi
    done < "$PYCACHE_OUTPUT_FILE"

    # Save the final .pyc block if any
    if [[ -n "$current_pyc_file" && -z "${seen_pyc_files[$current_pyc_file]}" ]]; then
        PYCACHE_TOC+="$current_pyc_file\n"
        for py_file in "${py_files[@]}"; do
            PYCACHE_TOC+="   |-- $py_file\n"
        done
        seen_pyc_files["$current_pyc_file"]=1  # Mark this .pyc file as seen
    fi

    # Write the final TOC to the pycache output file, overwriting previous content
    cat "$PYCACHE_OUTPUT_FILE" >> "$PYCACHE_OUTPUT_FILE.tmp"
    echo -e "$PYCACHE_TOC\n===================================\n" > "$PYCACHE_OUTPUT_FILE"
    cat "$PYCACHE_OUTPUT_FILE.tmp" >> "$PYCACHE_OUTPUT_FILE" && rm "$PYCACHE_OUTPUT_FILE.tmp"


    log_message "TOC generation for .pyc files complete."
}

# Main TOC generation function that calls both parts
generate_toc() {
    log_message "Generating full TOC..."
    generate_toc_for_regular_files
    generate_toc_for_pyc_files
    log_message "Full TOC generation complete."
}

# Ensure the output directory exists before writing to it
ensure_output_directory_exists() {
    if [ ! -d "$PROJECT_OUTPUT_DIR" ]; then
        log_message "Creating output directory: $PROJECT_OUTPUT_DIR"
        mkdir -p "$PROJECT_OUTPUT_DIR" || {
            log_message "Failed to create output directory: $PROJECT_OUTPUT_DIR" >&2
            CRITICAL_ERROR=1
            exit 1
        }
    fi
}

# Summarize Python files
generate_summary() {
    cleanup_on_error
    local file="$1"
    echo "Summary for $file:" >> "$OUTPUT_FILE"
    echo "Summary for $file:" >> "$HIGHLEVEL_FILE"

    # Extract class, function, and import definitions
    class_definitions=$(grep -E '^class ' "$file")
    function_definitions=$(grep -nE '^def ' "$file")
    import_statements=$(grep -E '^import |^from ' "$file")

    # Provide a brief summary of each component
    echo "This script includes the following components:" >> "$OUTPUT_FILE"
    echo "This script includes the following components:" >> "$HIGHLEVEL_FILE"

    # Summarize imports
    if [ -n "$import_statements" ]; then
        echo "- Imports: $(echo "$import_statements" | awk '{print $2}' | paste -sd ", ")" >> "$OUTPUT_FILE"
        echo "- Imports: $(echo "$import_statements" | awk '{print $2}' | paste -sd ", ")" >> "$HIGHLEVEL_FILE"
    fi

    # Summarize classes
    if [ -n "$class_definitions" ]; then
        echo "- Classes:" >> "$OUTPUT_FILE"
        while IFS= read -r class_line; do
            class_name=$(echo "$class_line" | awk '{print $2}' | sed 's/(.*//')
            class_description=$(generate_description "$class_name" "$file" "$(echo "$class_line" | awk '{print NR}')")
            echo "  - Class '$class_name': $class_description" >> "$OUTPUT_FILE"
            echo "  - Class '$class_name': $class_description" >> "$HIGHLEVEL_FILE"
        done <<< "$class_definitions"
    fi

    # Summarize functions
    if [ -n "$function_definitions" ]; then
        echo "- Functions:" >> "$OUTPUT_FILE"
        while IFS= read -r func_line; do
            func_name=$(echo "$func_line" | awk '{print $2}' | sed 's/(.*//')
            line_number=$(echo "$func_line" | cut -d':' -f1)
            func_description=$(generate_description "$func_name" "$file" "$line_number")
            echo "  - Function '$func_name': $func_description" >> "$OUTPUT_FILE"
            echo "  - Function '$func_name': $func_description" >> "$HIGHLEVEL_FILE"
        done <<< "$function_definitions"
    fi

    echo "---" >> "$OUTPUT_FILE"
    
    # Full content of the file (detailed analysis)
    echo "Full content for $file:" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Create the Python code for PDF to text conversion as a multi-line string.
read -r -d '' pdf_to_txt_python_script <<EOF || true
import sys
from PyPDF2 import PdfReader

def convert_pdf_to_txt(input_pdf, output_txt):
    try:
        reader = PdfReader(input_pdf)
        with open(output_txt, 'w') as f:
            for page_num, page in enumerate(reader.pages, start=1):
                text = page.extract_text()
                f.write(f'Page {page_num}:\n')
                f.write(text or "")
                f.write('\\n\\n')
        print(f'Successfully converted {input_pdf} to {output_txt}')
    except Exception as e:
        print(f'Error converting {input_pdf}: {e}', file=sys.stderr)

if __name__ == "__main__":
    input_pdf = sys.argv[1]
    output_txt = sys.argv[2]
    convert_pdf_to_txt(input_pdf, output_txt)
EOF

# Create the Python code for PowerPoint to text conversion as a multi-line string.
read -r -d '' pptx_to_txt_python_script <<EOF || true
import sys
from pptx import Presentation

def convert_pptx_to_txt(input_pptx, output_txt):
    try:
        presentation = Presentation(input_pptx)
        with open(output_txt, 'w') as f:
            for slide_num, slide in enumerate(presentation.slides, start=1):
                f.write(f'Slide {slide_num}:\n')
                for shape in slide.shapes:
                    if hasattr(shape, "text"):
                        f.write(shape.text + '\\n')
                f.write('\\n\\n')
        print(f'Successfully converted {input_pptx} to {output_txt}')
    except Exception as e:
        print(f'Error converting {input_pptx}: {e}', file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    input_pptx = sys.argv[1]
    output_txt = sys.argv[2]
    convert_pptx_to_txt(input_pptx, output_txt)
EOF

# Function to process .pdf files by converting them to text using PyPDF2
process_pdf_file() {
    local input_pdf="$1"
    local output_txt="${CONVERTED_OUTPUT_DIR}/$(basename "${input_pdf%.pdf}.txt")"

    log_message "Converting \"$input_pdf\" to .txt..."

    # Run the Python script to convert the PDF to text
    python3 - <<PYTHONSCRIPT "$input_pdf" "$output_txt"
$pdf_to_txt_python_script
PYTHONSCRIPT

    # Add a header with the source file information to the top of the converted .txt file
    {
        echo "Converted from $input_pdf"
        echo ""
        cat "$output_txt"
    } > "${output_txt}.tmp" && mv "${output_txt}.tmp" "$output_txt"
}

# Function to process .pptx files by executing the Python code directly.
process_pptx_file() {
    local input_pptx="$1"
    local output_txt="${CONVERTED_OUTPUT_DIR}/$(basename "${input_pptx%.pptx}.txt")"

    log_message "Converting \"$input_pptx\" to .txt..."

    # Run the Python script to convert the .pptx to .txt
    python3 - <<PYTHONSCRIPT "$input_pptx" "$output_txt"
$pptx_to_txt_python_script
PYTHONSCRIPT

    # Add a header with the source file information to the top of the converted .txt file
    {
        echo "Converted from $input_pptx"
        echo ""
        cat "$output_txt"
    } > "${output_txt}.tmp" && mv "${output_txt}.tmp" "$output_txt"
}

# Function to process .ipynb files by converting them to .py using nbconvert
process_ipynb_file() {
    local input_ipynb="$1"
    local output_py="${CONVERTED_OUTPUT_DIR}/$(basename "${input_ipynb%.ipynb}.py")"

    log_message "Converting \"$input_ipynb\" to .py..."

    # Run the jupyter nbconvert command to convert .ipynb to .py
    jupyter nbconvert --to script "$input_ipynb" --output "${output_py%.py}" 2>>"$ERROR_FILE" || {
        log_message "Error converting notebook file: $input_ipynb"
        CRITICAL_ERROR=1
        return 1
    }

    # Add a header with the source file information to the top of the converted .py file
    {
        echo "# Converted from $input_ipynb"
        echo "#"
        cat "$output_py"
    } > "${output_py}.tmp" && mv "${output_py}.tmp" "$output_py"
}

# Function to convert all .pdf files to text files (.txt)
convert_pdf_to_txt() {
    cleanup_on_error
    pushd "$PROJECT_DIR" > /dev/null || { log_message "ERROR: Failed to switch to project directory."; cleanup_on_error; exit 1; }

    # Find all .pdf files in the project directory
    pdf_files=$(find "$PROJECT_DIR" -type f -name "*.pdf")

    if [ -n "$pdf_files" ]; then
        log_message "Converting .pdf files to .txt..."
        while IFS= read -r file; do
            log_message "Converting \"$file\" to .txt..."
            process_pdf_file "$file" || {
                log_message "Error converting PDF file: $file"
                CRITICAL_ERROR=1
            }
        done <<< "$pdf_files"
    else
        log_message "No .pdf files found for conversion." >> "$OUTPUT_FILE"
    fi

    popd > /dev/null || { log_message "ERROR: Failed to switch back to the original directory."; cleanup_on_error; exit 1; }
}

# Function to convert PowerPoint files to text files
convert_pptx_to_txt() {
    cleanup_on_error
    pushd "$PROJECT_DIR" > /dev/null || { log_message "ERROR: Failed to switch to project directory."; cleanup_on_error; exit 1; }

    pptx_files=$(find "$PROJECT_DIR" -type f -name "*.pptx")

    if [ -n "$pptx_files" ]; then
        log_message "Converting .pptx files to .txt..."
        while IFS= read -r file; do
            log_message "Converting \"$file\" to .txt..."
            process_pptx_file "$file" || {
                log_message "Error converting PowerPoint file: $file"
                CRITICAL_ERROR=1
            }
        done <<< "$pptx_files"
    else
        log_message "No .pptx files found for conversion." >> "$OUTPUT_FILE"
    fi

    popd > /dev/null || { log_message "ERROR: Failed to switch back to the original directory."; cleanup_on_error; exit 1; }
}

# Function to convert all .ipynb files to Python scripts (.py)
convert_ipynb_to_py() {
    cleanup_on_error
    pushd "$PROJECT_DIR" > /dev/null || { log_message "ERROR: Failed to switch to project directory."; cleanup_on_error; exit 1; }

    # Find all .ipynb files in the project directory
    ipynb_files=$(find "$PROJECT_DIR" -type f -name "*.ipynb")

    if [ -n "$ipynb_files" ]; then
        log_message "Converting .ipynb files to .py..."
        while IFS= read -r file; do
            process_ipynb_file "$file" || {
                log_message "Error converting Jupyter notebook: $file"
                CRITICAL_ERROR=1
            }
            wait 
        done <<< "$ipynb_files"
    else
        log_message "No .ipynb files found for conversion." >> "$OUTPUT_FILE"
    fi

    popd > /dev/null || { log_message "ERROR: Failed to switch back to the original directory."; cleanup_on_error; exit 1; }
}
# Function to process regular files
process_regular_files() {
    cleanup_on_error
    log_message "Processing regular files..."


    # Collect all regular files to process
    files_to_process=$(find "$PROJECT_DIR" "$CONVERTED_OUTPUT_DIR" -type f \( \
        ! -name "*.png" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.JPG" ! -name "*.eps" \
        ! -name "*.csv" ! -name "*.npy" ! -name "*.DS_Store" ! -name "*.model" ! -name "*.vocab"  \
        ! -name "*.data-*" ! -name "*.index" ! -name "*.mapping" \
        ! -name "*.pyc" ! -name "*.pyo" ! -name "__pycache__*" ! -name "*.ipynb" \
        ! -name "*.pdf" ! -name "*.pptx" ! -name "*.docx" ! -name "*.doc" \
        ! -name "*.exe" ! -name "*.dll" ! -name "*.bin" ! -name "*.msi" \
        ! -name "*.sys" ! -name "*.deb" ! -name "*.rpm" ! -name "*.so" ! -name "*.elf" \
        ! -name "*.o" ! -name "*.tar" ! -name "*.gz" ! -name "*.zip" ! -name "*.rar" \
        ! -name "*.7z" ! -name "*.iso" ! -name "*.dmg" ! -name "*.img" ! -name "*.vmdk" ! -name "*.qcow2" \
        ! -name "*.vhd" ! -name "*.vhdx" ! -name "*.vdi" ! -name "*.raw" ! -name "*.sparseimage" ! -name "*.credentials" \
	! -name "virtualenv*" ! -name "pip*" ! -name "*.bak" \
        ! -path "*__MACOSX/*" ! -path "*$PROJECT_OUTPUT_DIR*" ! -path "*state/azure-cli*" \
        ! -path "*.conda*" ! -path "*pip/*" ! -path "*.ipynb_checkpoints*" ! -path "*pip3/*" \
        ! -path "$PROJECT_DIR/**/output/*" ! -path "$PROJECT_DIR/**/input/*" \
        ! -path "*.tox*" ! -path "*.git*" ! -path "*.svn*" \
        ! -path "*.hg*" ! -path "*node_modules*" ! -path **/"VSCodium/*" \
        ! -path "*.idea*" ! -path "*.vscode*" ! -path "*.reports*" ! -path "*lib/python3.10*" \
        ! -path "*.mypy_cache*" ! -path "*.pytest_cache*" \
        ! -path "*.circleci*" ! -path "*.travis*" ! -path "*.github*" \
        ! -path "*.gitlab-ci*" ! -path "*share*" \
    \) | sort)


    while IFS= read -r file; do
        if [ -f "$file" ]; then
            log_message "Processing $file ..."
            summarize_files "$file" || {
                log_message "Error processing file: $file" >> "$ERROR_FILE"
                continue
            }
        else
            log_message "Skipping non-regular file: $file" >> "$ERROR_FILE"
        fi
    done <<< "$files_to_process"
}

# Function to process all files, convert .ipynb to .py, .pptx to .txt, and regular files
process_files() {
    cleanup_on_error

    log_message "Starting file processing..."

    # Convert .ipynb files to .py in the background
    convert_ipynb_to_py &

    # Convert .pptx files to .txt in the background
    convert_pptx_to_txt &

    # Convert .pdf files to .txt in the background
    convert_pdf_to_txt &    

    # Wait for conversions to complete
    wait

    # Process all regular files, including the converted .py and .txt files
    process_regular_files || exit 1
}


# Function to handle TOC and output file updates
update_output_files() {
    cleanup_on_error
    #echo -e "$TOC\n===================================\n" > "$OUTPUT_FILE.tmp"
    cat "$OUTPUT_FILE" >> "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

    echo -e "$TOC\n===================================\n" > "$HIGHLEVEL_FILE.tmp"
    cat "$HIGHLEVEL_FILE" >> "$HIGHLEVEL_FILE.tmp" && mv "$HIGHLEVEL_FILE.tmp" "$HIGHLEVEL_FILE"

    #echo -e "\n$PYCACHE_TOC\n===================================\n" >> "$PYCACHE_OUTPUT_FILE"
    cat "$PYCACHE_OUTPUT_FILE" >> "$PYCACHE_OUTPUT_FILE.tmp" && mv "$PYCACHE_OUTPUT_FILE.tmp" "$PYCACHE_OUTPUT_FILE"
}

# Function to handle final output move
move_output_to_final_dir() {
    cleanup_on_error
    mkdir -p "$FINAL_OUTPUT_DIR" || {
        >&2 log_message "ERROR: Failed to create final output directory."
        exit 1
    }

    mv "$PROJECT_BASE_DIR" "$FINAL_OUTPUT_DIR" || {
        >&2 log_message "ERROR: Failed to move the timestamped folder to $FINAL_OUTPUT_DIR."
        exit 1
    }

    TIMESTAMP=$(basename "$PROJECT_BASE_DIR" | cut -d'_' -f1)
    log_message "The output folder has been created at $FINAL_OUTPUT_DIR. Timestamp: $TIMESTAMP."
}

# Main function to handle everything
main() {
    CRITICAL_ERROR=${CRITICAL_ERROR:-0}
    log_message "Starting project processing..."
    # Initialize pyenv
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    setup_directories "$1" "$2"
    initialize_files

    # Ensure necessary tools are installed
    ensure_tools_installed || exit 1

    # Process all files (convert .ipynb to .py, .pptx to .txt, and regular files)
    process_files || exit 1

    # Decompile .pyc files using correct Python versions
    #decompile_pyc_files || exit 1

    # Generate TOC for pyc files and their decompiled content
    generate_toc

    # Move final output to destination
    update_output_files
    move_output_to_final_dir

    log_message "Project was processed successfully!"
}
# Call the main function
main "$@"


