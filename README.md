# Data Engineering DevOps Automation

This project provides an automated infrastructure and data pipeline setup using Terraform, AWS, Python, and GitHub Actions. It is designed for data engineering and DevOps workflows, including infrastructure provisioning, sample data generation, and CI/CD automation.

## Features
- **Infrastructure as Code**: AWS resources (S3, Glue, IAM, etc.) provisioned via Terraform.
- **Sample Data Generation**: Python scripts to generate and test sample temperature data.
- **Automated Testing**: Pytest-based test suite for data generation scripts.
- **CI/CD Pipeline**: GitHub Actions workflows for security scanning, testing, validation, planning, and deployment.

## Project Structure
```
DevOopsDEAutomation/
├── .github/workflows/deploy.yml      # CI/CD pipeline definition
├── terraform/                        # Terraform IaC files
│   ├── main.tf
│   ├── variables.tf
│   ├── provider.tf
│   └── ...
├── scripts/                          # Python scripts (e.g., generate_sample_data.py)
├── tests/                            # Pytest test files
├── data/                             # Sample data files
├── requirements.txt                  # Python dependencies
└── README.md                         # Project documentation
```

## Getting Started

### Prerequisites
- Python 3.10+
- pip
- Terraform 1.5+
- AWS CLI (configured with valid credentials)
- (Optional) Chocolatey for Windows package management

### Setup
1. **Clone the repository**
   ```sh
   git clone https://github.com/velisen/data_engineering_devops_automation.git
   cd data_engineering_devops_automation
   ```
2. **Set up Python environment**
   ```sh
   python -m venv .venv
   .venv\Scripts\activate  # On Windows
   pip install -r requirements.txt
   ```
3. **Configure AWS credentials**
   ```sh
   aws configure
   ```
4. **Initialize Terraform**
   ```sh
   cd terraform
   terraform init
   terraform validate
   ```
5. **Apply Terraform (provision infrastructure)**
   ```sh
   terraform apply
   ```
6. **Generate sample data**
   ```sh
   python scripts/generate_sample_data.py
   ```
7. **Run tests**
   ```sh
   pytest tests/ -v
   ```

## CI/CD Pipeline
- Automated via GitHub Actions (`.github/workflows/deploy.yml`)
- Runs security scans, tests, Terraform validation, plan, and deploy steps on push/PR

## Notes
- S3 bucket names must not contain underscores or uppercase letters.
- Ensure AWS credentials have sufficient permissions for S3, Glue, and IAM.
- Update `variables.tf` and `main.tf` as needed for your project specifics.

