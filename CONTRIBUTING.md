# Contributing to MediEvil Advisor 🏰⚔️

Thank you for your interest in contributing to MediEvil Advisor! This Flutter app is a **proof of concept** for the original MediEvil Advisor backend project. This document provides guidelines for contributing to this Flutter client-side implementation.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Git

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/medievil_advisor.git`
3. Navigate to the project: `cd medievil_advisor`
4. Install dependencies: `flutter pub get`
5. Run tests: `flutter test`

## 📝 Code Style

### Dart/Flutter Guidelines
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Architecture Guidelines
- Follow Clean Architecture principles
- Use BLoC pattern for state management
- Keep UI components stateless when possible
- Use dependency injection with `get_it`

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/presentation/main_interaction_bloc_test.dart
```

### Writing Tests
- Write tests for all new features
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies

## 🔧 Development Workflow

### Creating a Feature
1. Create a new branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Add tests for new functionality
4. Run tests: `flutter test`
5. Check code quality: `flutter analyze`
6. Commit your changes with a descriptive message
7. Push to your fork
8. Create a Pull Request

### Commit Message Format
```
type(scope): description

Examples:
feat(bloc): add new state for audio playback
fix(ui): resolve text overflow issue
docs(readme): update installation instructions
test(service): add unit tests for audio file service
```

## 🐛 Bug Reports

When reporting bugs, please include:
- Device information (OS, version)
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Logs (if applicable)

## 💡 Feature Requests

When requesting features, please include:
- Clear description of the feature
- Use case and motivation
- Proposed implementation approach
- Acceptance criteria

## 📋 Pull Request Checklist

Before submitting a PR, ensure:
- [ ] Code compiles without errors
- [ ] All tests pass
- [ ] No linting errors (`flutter analyze`)
- [ ] Documentation is updated
- [ ] Feature works on both iOS and Android
- [ ] Code follows project architecture
- [ ] Commit messages are descriptive

## 🏗️ Project Structure

This Flutter app demonstrates the client-side implementation of the MediEvil Advisor concept:

```
lib/
├── core/                 # Core functionality
│   ├── di/             # Dependency injection
│   └── services/       # Platform services
├── features/           # Feature modules
│   └── interaction/    # Main interaction feature
│       ├── data/       # Data layer (API integration)
│       ├── domain/     # Business logic
│       └── presentation/ # UI layer
└── main.dart          # App entry point
```

**Note**: This repository focuses on the Flutter client-side implementation. The backend AI processing is handled by the original MediEvil Advisor backend project at [https://github.com/canberkozcelik/medievil-advisor](https://github.com/canberkozcelik/medievil-advisor).

## 🎯 Development Priorities

1. **Functionality**: Ensure Flutter app features work correctly with backend API
2. **Testing**: Maintain high test coverage for client-side logic
3. **Performance**: Optimize for smooth user experience
4. **Accessibility**: Make the app accessible to all users
5. **Documentation**: Keep documentation up to date
6. **API Integration**: Ensure proper communication with MediEvil Advisor backend

## 🤝 Code Review

- Be respectful and constructive in reviews
- Focus on code quality and functionality
- Suggest improvements when possible
- Test changes locally before approving

## 📄 License

By contributing to MediEvil Advisor, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to MediEvil Advisor! 🏰⚔️ 