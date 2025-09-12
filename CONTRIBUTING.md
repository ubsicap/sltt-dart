# Contributing to SLTT Dart

Thank you for your interest in contributing to the SLTT Dart project!

## Development Setup

1. **Clone and Setup**:
   ```bash
   git clone https://github.com/ubsicap/sltt-dart.git
   cd sltt-dart
   ```

2. **Open in VS Code**:
   ```bash
   code sltt_dart.code-workspace
   ```

## Project Structure

```
sltt_dart/
├── packages/sltt_core/        # Core sync system (publishable package)
├── packages/sync_manager/     # Isar-based client implementations
├── packages/aws_backend/      # AWS Lambda backend service
└── sltt_dart.code-workspace   # VS Code workspace
```

## Development Workflow


### Making Changes to Core Package

1. **Work in `packages/sltt_core/`**
2. **Generate code after model changes**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Test your changes**:
   ```bash
   source ./setup_test_env.sh && dart test packages/sltt_core
   ```

### Adding New Features

1. **Add core functionality** in `packages/sltt_core/lib/src/`
2. **Export public API** in `packages/sltt_core/lib/sltt_core.dart`
3. **Add tests/demos** in `packages/sync_manager/test/`
4. **Update documentation** in package READMEs

### Running Tests

```bash
# Run all tests (after sourcing environment)
source ./setup_test_env.sh && dart test

# Run an individual package test
source ./setup_test_env.sh && dart test packages/sync_manager test/sync_manager_test.dart -p vm --plain-name 'outdated changes are not synced'
```

### Debugging
  **Run Tasks**: Command Palette → Tasks: Run Task
- **VS Code**: F5 → Choose launch configuration

## VS Code Features

### Launch Configurations
- **Sync Manager Server Runner - Start All** - Run local storage servers
- **Attach: Debug AWS Backend (Dev)** - Debug individual servers

### Tasks
- **Get Dependencies (All)** - Install all package dependencies
- **Generate Code (Core)** - Run build_runner for Isar schemas
- **Analyze (All)** - Check code quality
- **Start All Servers** - Background server startup
- **Debug AWS Backend (Dev)** - run aws_backend dev server with debugging

## Code Style

- **Line Length**: 120 characters
- **Formatting**: Use `dart format` (automatic on save)
- **Analysis**: Follow `analysis_options.yaml` rules
- **Imports**: Use package imports (`package:sltt_core/sltt_core.dart`)

## Testing Guidelines

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test complete sync workflows
3. **Demo Scripts**: Provide interactive examples
4. **Server Tests**: Verify API endpoints work correctly

## Commit Guidelines

- **Format**: `type: description`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Examples**:
  ```
  feat: add cursor-based pagination to sync endpoints
  fix: resolve import path issues in mono-repo structure
  docs: update README with new development setup
  ```

## Pull Request Process

1. **Create Feature Branch**: `git checkout -b feature/your-feature-name`
2. **Make Changes**: Follow development workflow above
3. **Build Models**: Run `dart run build_runner build --delete-conflicting-outputs`
4. **Lint and Format**: Run `dart analyze` (and `dart fix --apply`) and `dart format`
3. **Test Thoroughly**: Use the sourceable setup script and run `dart test`.

Example:

```bash
# Source once to export LD_LIBRARY_PATH into your shell session
source ./setup_test_env.sh

# Run tests
dart test
```
4. **Format Code**: Ensure code is formatted with `dart format`
4. **Update Documentation**: Update READMEs if needed
5. **Submit PR**: Include description of changes and testing done

## Getting Help

- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Code Review**: All PRs require review before merging

## Package Publishing

The `sltt_core` package is designed to be publishable to pub.dev:

```bash
cd packages/sltt_core
dart pub publish --dry-run  # Test publishing
dart pub publish            # Actual publish (maintainers only)
```

```bash
cd packages/aws_backend
npm run deploy:dev  # Deploy to AWS Lambda (development)
dart test
```

Test local aws_backend
```bash
CLOUD_BASE_URL=http://localhost:8080 dart test
```
