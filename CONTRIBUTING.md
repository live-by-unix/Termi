# Contributing to Termi

Thank you for your interest in contributing to Termi! This document provides guidelines and instructions for contributors.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

- Go 1.18 or higher
- Git
- Basic knowledge of Go and shell scripting

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/termi.git
   cd termi
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/live-by-unix/termi.git
   ```

4. Install dependencies:
   ```bash
   go mod download
   ```

5. Build the project:
   ```bash
   go build -o termi .
   ```

## Development Workflow

### Branching Strategy

- Create a new branch for each feature or bugfix
- Use descriptive branch names:
  - `feature/plugin-system-improvements`
  - `bugfix/shell-detection-issue`
  - `docs/update-readme`

### Making Changes

1. Make your changes on your feature branch
2. Test your changes thoroughly
3. Update documentation if needed
4. Commit your changes with clear messages

### Commit Messages

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(plugins): add plugin dependency management
fix(shell): resolve shell detection on macOS
docs(readme): update installation instructions
```

## Testing

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests for a specific package
go test ./internal/config
```

### Writing Tests

- Write tests for new features
- Maintain test coverage above 80%
- Use table-driven tests where appropriate
- Mock external dependencies

Example test:
```go
func TestConfigLoad(t *testing.T) {
    tests := []struct {
        name    string
        content string
        want    *Config
        wantErr bool
    }{
        {
            name:    "valid config",
            content: "/usr/bin/zsh",
            want:    &Config{ShellPath: "/usr/bin/zsh"},
            wantErr: false,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

## Code Style

### Formatting

- Use `gofmt` for code formatting
- Run `go fmt ./` before committing
- Follow standard Go conventions

### Linting

```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run linter
golangci-lint run
```

### Naming Conventions

- Packages: lowercase, single word
- Exported functions: PascalCase
- Internal functions: camelCase
- Constants: PascalCase for exported, camelCase for internal
- Interfaces: PascalCase, often ending in "er"

### Documentation

- Document exported functions, types, and constants
- Use godoc format
- Include examples for complex functions
- Keep comments concise and accurate

Example:
```go
// DetectAvailable finds all available shell interpreters on the system.
// It checks standard paths, platform-specific paths, and the PATH environment
// variable. Returns a slice of Shell structs or an error if detection fails.
func DetectAvailable() ([]Shell, error) {
    // Implementation
}
```

## Pull Request Process

### Before Submitting

1. Ensure your code follows the style guidelines
2. Add tests for new features
3. Update documentation
4. Run tests and ensure they pass
5. Rebase your branch on the latest upstream main

### Submitting a PR

1. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature
   ```

2. Create a pull request on GitHub
3. Fill in the PR template:
   - Description of changes
   - Related issues
   - Testing performed
   - Screenshots (if applicable)

4. Request review from maintainers

### PR Review Process

- Maintainers will review your PR
- Address feedback and make necessary changes
- Keep the PR focused and small if possible
- Respond to review comments promptly

## Project Structure

```
termi/
├── main.go              # Entry point
├── go.mod               # Go module definition
├── go.sum               # Dependency checksums
├── internal/            # Internal packages
│   ├── config/         # Configuration management
│   ├── plugins/        # Plugin system
│   ├── shell/          # Shell detection
│   └── terminal/       # Terminal launching
├── docs/               # Documentation
├── scripts/            # Installation and build scripts
├── examples/           # Example plugins
└── releases/           # Pre-built binaries
```

## Feature Guidelines

### Adding New Features

1. Discuss the feature in an issue first
2. Get approval from maintainers
3. Design the feature with extensibility in mind
4. Implement with tests
5. Update documentation

### Breaking Changes

- Avoid breaking changes if possible
- If unavoidable, document migration path
- Update version number appropriately
- Announce in release notes

## Bug Reports

### Reporting Bugs

Use the GitHub issue tracker and include:

- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, Go version, etc.)
- Relevant logs or screenshots

### Fixing Bugs

1. Claim an issue you want to work on
2. Reproduce the bug
3. Write a test that fails
4. Fix the bug
5. Ensure test passes
6. Submit PR with reference to issue

## Documentation

### Updating Documentation

- Keep README.md up to date
- Update docs/ for detailed changes
- Add examples for new features
- Maintain consistent formatting

### Documentation Style

- Use clear, concise language
- Include code examples
- Use proper markdown formatting
- Add diagrams where helpful

## Release Process

Releases are managed by maintainers:

1. Update version in main.go
2. Update CHANGELOG.md
3. Build release binaries
4. Generate checksums
5. Create GitHub release
6. Tag the commit

## Questions and Support

- Use GitHub Discussions for questions
- Use GitHub Issues for bug reports and feature requests
- Be patient with responses
- Help other community members when possible

## License

By contributing to Termi, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to Termi!
