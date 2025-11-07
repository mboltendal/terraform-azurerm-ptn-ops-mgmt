# Contributing to Azure Operations Management Pattern Module

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## 🚧 Development Status

This module is currently under active development. We welcome contributions that align with the project's goals and design principles.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

## Code of Conduct

This project follows standard open-source community guidelines. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Terraform version** and provider versions
- **Module version** or commit hash
- **Relevant logs** (with sensitive information redacted)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear use case** and problem statement
- **Proposed solution** with examples
- **Alternatives considered**
- **Impact** on existing functionality

### Pull Requests

We welcome pull requests! Here's how to contribute code:

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** as needed
5. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.13
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (authenticated)
- An Azure subscription for testing
- Git

### Local Development

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-azurerm-ptn-ops-mgmt.git
   cd terraform-azurerm-ptn-ops-mgmt
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create a test configuration:
   ```bash
   cp examples/default.tfvars my-test.tfvars
   # Edit my-test.tfvars with your test values
   ```

4. Plan your changes:
   ```bash
   terraform plan -var-file=my-test.tfvars -var=subscription_id="YOUR_SUBSCRIPTION_ID"
   ```

## Coding Standards

### Terraform Style

- Follow [HashiCorp's Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Run `terraform fmt` before committing
- Use meaningful resource and variable names
- Add descriptions to all variables and outputs

### Variable Naming Conventions

Variables should follow this pattern:
```
<resource_type>_<specific_component>_<attribute>
```

Examples:
- `network_subnet_management_address_prefix`
- `storage_account_replication_type`
- `key_vault_sku_name`

### Code Organization

- **One resource type per file** when possible
- **Group related resources** (e.g., all networking in `networking.tf`)
- **Use modules** from Azure Verified Modules (AVM) where available
- **Document complex logic** with inline comments

### Documentation

- Update `README.md` for user-facing changes
- Update `spec.md` for architectural decisions
- Add inline comments for complex logic
- Include examples for new features

## Pull Request Process

1. **Update documentation** relevant to your changes
2. **Add/update examples** in the `examples/` directory if needed
3. **Ensure your code passes** `terraform fmt` and `terraform validate`
4. **Test your changes** in a real Azure environment
5. **Update the README** if you're adding new variables or outputs
6. **Reference any related issues** in your PR description

### PR Title Format

Use clear, descriptive titles:
- `feat: add support for custom DNS servers`
- `fix: correct NSG rule priority conflict`
- `docs: update contributing guidelines`
- `refactor: simplify network security group logic`

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested with `terraform plan`
- [ ] Tested with `terraform apply`
- [ ] Tested destroy/cleanup
- [ ] Tested in dev environment
- [ ] No breaking changes to existing deployments

## Related Issues
Fixes #(issue number)
```

## Testing

### Manual Testing

Before submitting a PR, test your changes:

```bash
# Initialize
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan -var-file=examples/default.tfvars -var=subscription_id="SUBSCRIPTION_ID"

# Apply (use a test subscription!)
terraform apply -var-file=examples/default.tfvars -var=subscription_id="SUBSCRIPTION_ID"

# Verify functionality
# ... perform manual verification ...

# Clean up
terraform destroy -var-file=examples/default.tfvars -var=subscription_id="SUBSCRIPTION_ID"
```

### Testing Checklist

- [ ] Code is properly formatted (`terraform fmt`)
- [ ] Configuration validates (`terraform validate`)
- [ ] Plan succeeds without errors
- [ ] Apply succeeds and creates expected resources
- [ ] Resources are properly tagged
- [ ] Outputs return expected values
- [ ] Destroy cleans up all resources
- [ ] No sensitive data exposed in outputs or logs

## Design Principles

When contributing, please follow these design principles:

1. **Security First** - Private endpoints by default, no public access to secrets/storage
2. **Managed Identities Only** - No stored credentials
3. **Stateless Design** - Resources should be easily recreatable
4. **Leverage AVM** - Use Azure Verified Modules where available
5. **Clear Naming** - Use consistent naming conventions
6. **Tagging** - All resources should be properly tagged

## Questions?

If you have questions about contributing, please:
- Check existing issues and discussions
- Open a new issue with the `question` label
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for contributing to making Azure operations management better! 🚀
