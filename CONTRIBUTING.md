# Contributing to Challenge Goal App

Thank you for your interest in contributing to our project! This document provides guidelines and instructions for contributing.

## 🤝 Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment.

## 🎯 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title** and description
- **Steps to reproduce** the problem
- **Expected behavior** vs **actual behavior**
- **Screenshots** if applicable
- **Environment details** (OS, Flutter version, Node version)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear description** of the enhancement
- **Use case** - why this would be useful
- **Possible implementation** approach (optional)

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Write/update tests if applicable
5. Update documentation
6. Submit a pull request

## 🔀 Branch Naming Convention

Use descriptive branch names:

- `feature/goal-reminders` - New features
- `fix/login-bug` - Bug fixes
- `docs/api-documentation` - Documentation updates
- `refactor/auth-service` - Code refactoring
- `test/goal-controller` - Adding tests

## 📝 Commit Message Guidelines

Follow the Conventional Commits specification:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(goals): add reminder notification feature

Implement push notifications for goal reminders.
Users can now set custom reminder times for their goals.

Closes #123
```

```bash
fix(auth): resolve session timeout issue

Fixed bug where sessions were expiring too quickly.
Increased session duration to 24 hours.
```

```bash
docs(readme): update installation instructions

Added troubleshooting section for common setup issues.
Included screenshots for Android Studio configuration.
```

## 💻 Development Workflow

### Setting Up Development Environment

1. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Challenge-Goal-App.git
   cd Challenge-Goal-App
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/PetchSuriya/Challenge-Goal-App.git
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Install dependencies**
   ```bash
   # Backend
   cd Server && npm install && cd ..
   
   # Frontend
   flutter pub get
   ```

### Making Changes

1. **Keep changes focused** - One feature/fix per PR
2. **Write clear code** - Follow existing code style
3. **Add comments** - Explain complex logic
4. **Update tests** - Ensure tests pass
5. **Update docs** - Keep documentation current

### Testing Your Changes

**Backend:**
```bash
cd Server
npm test  # If tests exist
node index.js  # Manual testing
```

**Frontend:**
```bash
flutter test
flutter run  # Manual testing
```

### Committing Changes

```bash
git add .
git commit -m "feat(scope): descriptive message"
```

### Keeping Your Branch Updated

```bash
git fetch upstream
git rebase upstream/main
```

### Submitting Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub

3. **Fill out PR template** with:
   - Description of changes
   - Related issue numbers
   - Testing performed
   - Screenshots (if UI changes)

## 🎨 Code Style Guidelines

### Flutter/Dart

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `flutter format .`
- Maximum line length: 80 characters
- Use meaningful variable names

### Node.js/JavaScript

- Use ES6+ features
- 2 spaces for indentation
- Semicolons required
- Use `const` by default, `let` when reassignment needed
- Async/await preferred over callbacks

### File Organization

**Flutter:**
```
lib/
├── features/
│   └── feature_name/
│       ├── controller/
│       ├── model/
│       └── view/
```

**Node.js:**
```
Server/
├── routes/
├── controllers/
├── models/
└── middleware/
```

## 🧪 Testing Guidelines

### Writing Tests

- Write tests for new features
- Update tests when modifying existing features
- Aim for meaningful test coverage
- Test edge cases and error conditions

### Test Structure

```dart
// Flutter test example
void main() {
  group('GoalController', () {
    test('should create goal successfully', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## 📚 Documentation

### Code Comments

```dart
/// Creates a new goal for the user.
///
/// [title] is the goal's title (required)
/// [duration] specifies how long the goal lasts
/// Returns [Goal] object if successful
Future<Goal> createGoal(String title, {int? duration}) async {
  // Implementation
}
```

### README Updates

Update README.md when:
- Adding new features
- Changing installation steps
- Modifying configuration
- Updating dependencies

## 🔍 Code Review Process

1. **Automated Checks**
   - Linting passes
   - Tests pass
   - No merge conflicts

2. **Manual Review**
   - Code quality
   - Documentation completeness
   - Test coverage

3. **Approval Required**
   - At least one approving review
   - All comments addressed

## 🚀 Release Process

1. Version bump in `pubspec.yaml` and `package.json`
2. Update CHANGELOG.md
3. Create release branch
4. Tag release with version number
5. Merge to main
6. Create GitHub release

## 📞 Getting Help

- **Questions?** Open a GitHub Discussion
- **Bugs?** Create an Issue
- **Ideas?** Start a Discussion

## 👥 Team Members

- **PetchSuriya** - Project Lead
- **Contributors** - See [Contributors](https://github.com/PetchSuriya/Challenge-Goal-App/graphs/contributors)

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to Challenge Goal App! 🎉
