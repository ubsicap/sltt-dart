# Contributing to SLTT Dart

Thank you for your interest in contributing to the SLTT Dart project!

## Development Setup

1. **Clone and Setup**:
   ```bash
   git clone https://github.com/ubsicap/sltt-dart.git
   cd sltt-dart
   ./dev.sh setup
   ```

2. **Open in VS Code**:
   ```bash
   code sltt_dart.code-workspace
   ```

## Project Structure

```
sltt_dart/
├── packages/sltt_core/        # Core sync system (publishable package)
├── examples/sync_manager_demo/ # Interactive demo and tests
├── tools/                     # Development tools (future)
├── docs/                      # Documentation (future)
├── dev.sh                     # Development helper script
└── sltt_dart.code-workspace   # VS Code workspace
```

## Development Workflow

### Making Changes to Core Package

1. **Work in `packages/sltt_core/`**
2. **Generate code after model changes**:
   ```bash
   ./dev.sh gen
   ```
3. **Test your changes**:
   ```bash
   ./dev.sh test
   ./dev.sh demo
   ```

### Adding New Features

1. **Add core functionality** in `packages/sltt_core/lib/src/`
2. **Export public API** in `packages/sltt_core/lib/sltt_core.dart`
3. **Add tests/demos** in `examples/sync_manager_demo/`
4. **Update documentation** in package READMEs

### Running Tests

```bash
# Run all tests
./dev.sh test

# Or individual tests
cd examples/sync_manager_demo
dart run test_sync_manager.dart
dart run test_operation_field.dart
```

### Debugging

- **VS Code**: F5 → Choose launch configuration
- **Terminal**: Use `./dev.sh` commands with verbose output
- **Servers**: Use `./dev.sh servers` then `./dev.sh status`

## VS Code Features

### Launch Configurations
- **Demo: Interactive Sync System** - Run the main demo
- **Test: Sync Manager** - Run comprehensive tests
- **Server: Downsyncs/Outsyncs/Cloud** - Debug individual servers
- **All Servers** - Launch all servers simultaneously

### Tasks
- **Get Dependencies (All)** - Install all package dependencies
- **Generate Code (Core)** - Run build_runner for Isar schemas
- **Analyze (All)** - Check code quality
- **Start All Servers** - Background server startup
- **Run Demo** - Interactive terminal demo

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
3. **Test Thoroughly**: Run `./dev.sh test` and `./dev.sh analyze`
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
