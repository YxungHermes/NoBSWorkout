# Contributing to NoBSWorkout

Thank you for your interest in contributing to NoBSWorkout! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Making Changes](#making-changes)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and professional in all interactions.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NoBSWorkout.git
   cd NoBSWorkout
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.9 or later
- iOS 15.0+ deployment target

### Setting Up Xcode Project

1. Open Xcode
2. Create a new iOS App project:
   - Product Name: `NoBSWorkout`
   - Organization Identifier: `com.yourcompany` (or your preferred identifier)
   - Interface: SwiftUI
   - Language: Swift
   - Use Core Data: Yes
3. Add the source files from the `NoBSWorkout/` directory to your project
4. Replace the generated Core Data model with `NoBSWorkout/Models/NoBSWorkout.xcdatamodeld`
5. Replace Info.plist with `NoBSWorkout/Info.plist`
6. Build and run to verify setup

See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.

## Project Structure

```
NoBSWorkout/
├── App/                    # App entry point
│   └── NoBSWorkoutApp.swift
├── Models/                 # Data models and Core Data entities
│   ├── Extensions/         # Model extensions
│   └── NoBSWorkout.xcdatamodeld/
├── ViewModels/             # Business logic layer
├── Views/                  # UI layer (SwiftUI)
│   ├── Home/              # Home screen and components
│   ├── Workout/           # Workout logging screens
│   ├── History/           # Workout history screens
│   ├── PRs/               # Personal records screens
│   ├── Timer/             # Rest timer
│   └── Common/            # Shared UI components
├── Services/              # Business services
│   └── CoreData/          # Persistence layer
└── Utilities/             # Helper functions and extensions
    ├── Extensions/
    └── Helpers/
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use clear, descriptive names for variables, functions, and types
- Maximum line length: 120 characters
- Use 4 spaces for indentation (no tabs)

### Architecture

- Follow MVVM pattern strictly
- Keep ViewModels independent of SwiftUI Views
- Use `@ObservableObject` for ViewModels
- Keep Views focused on UI only
- Business logic belongs in ViewModels or Services

### Naming Conventions

**Files:**
- Views: `FeatureNameView.swift` (e.g., `HomeView.swift`)
- ViewModels: `FeatureNameViewModel.swift`
- Components: `ComponentName.swift`
- Extensions: `TypeName+Extension.swift`

**Code:**
- Classes/Structs: `PascalCase`
- Functions/Variables: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for static
- Enums: `PascalCase` with `camelCase` cases

### Core Data Guidelines

- All entities must have UUID `id` attribute
- Use optional attributes with appropriate defaults
- Define inverse relationships
- Document deletion rules
- Add extensions in separate files

### SwiftUI Best Practices

- Break large views into smaller components
- Extract reusable components to `Views/Common/Components/`
- Use `@State` for local view state
- Use `@ObservedObject` or `@StateObject` for ViewModels
- Use `@Environment` for Core Data context

### Comments and Documentation

- Add doc comments for public APIs
- Explain complex logic with inline comments
- Document assumptions and constraints
- Use `// MARK: -` to organize code sections

```swift
// MARK: - Properties
private let service: DataService

// MARK: - Initialization
init(service: DataService) {
    self.service = service
}

// MARK: - Public Methods
/// Fetches recent workouts from Core Data
func fetchRecentWorkouts() { ... }

// MARK: - Private Methods
private func processResults() { ... }
```

## Making Changes

### Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features (e.g., `feature/workout-templates`)
- `fix/` - Bug fixes (e.g., `fix/pr-calculation`)
- `refactor/` - Code refactoring (e.g., `refactor/viewmodel-cleanup`)
- `docs/` - Documentation updates (e.g., `docs/update-readme`)
- `test/` - Test additions (e.g., `test/add-viewmodel-tests`)

### Commit Messages

Write clear, descriptive commit messages:

```
Short summary (50 chars or less)

More detailed explanatory text if needed. Wrap at 72 characters.
Explain the problem this commit solves and why you chose this
solution.

- Bullet points are okay
- Use present tense ("Add feature" not "Added feature")
- Reference issues: "Fixes #123" or "Closes #456"
```

**Good examples:**
- `Add workout template selection feature`
- `Fix PR detection for exercises with no history`
- `Refactor HomeViewModel to use async/await`
- `Update README with installation instructions`

**Bad examples:**
- `Fixed stuff`
- `WIP`
- `asdfasdf`

### Testing Your Changes

1. **Build and Run**: Ensure the app builds without errors
2. **Manual Testing**: Test your changes on iOS Simulator
3. **Edge Cases**: Test boundary conditions and error cases
4. **Existing Features**: Verify you didn't break existing functionality
5. **Different Devices**: Test on different screen sizes if UI changes

### Code Review Checklist

Before submitting, verify:

- [ ] Code follows Swift style guidelines
- [ ] MVVM architecture is maintained
- [ ] No compiler warnings
- [ ] Code is well-documented
- [ ] No hardcoded values (use Constants.swift)
- [ ] UI is responsive and adaptive
- [ ] Core Data migrations handled (if schema changed)
- [ ] No force unwraps unless absolutely necessary
- [ ] Error handling is appropriate
- [ ] Performance is acceptable

## Submitting Pull Requests

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub:
   - Use a clear, descriptive title
   - Reference related issues: "Fixes #123"
   - Describe what changed and why
   - Add screenshots for UI changes
   - List testing performed

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Related Issues
   Fixes #123

   ## Changes Made
   - Added feature X
   - Fixed bug Y
   - Refactored Z

   ## Testing
   - [ ] Tested on iOS Simulator
   - [ ] Tested on physical device
   - [ ] Tested edge cases
   - [ ] No regressions found

   ## Screenshots
   (if applicable)
   ```

4. **Respond to feedback** promptly and professionally

5. **Keep PR updated**: Rebase or merge main if needed

## Reporting Issues

### Bug Reports

When reporting bugs, include:

1. **Clear title** describing the issue
2. **Description** of what happened vs. what you expected
3. **Steps to reproduce**:
   - Step 1
   - Step 2
   - Expected result
   - Actual result
4. **Environment**:
   - iOS version
   - Device model
   - App version
5. **Screenshots or videos** if applicable
6. **Crash logs** if the app crashed

### Issue Template

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Open app
2. Navigate to...
3. Tap on...
4. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- iOS: 16.0
- Device: iPhone 14 Pro
- App Version: 1.0

**Screenshots**
(attach images)

**Additional Context**
Any other relevant information
```

## Feature Requests

We welcome feature suggestions! When requesting features:

1. **Check existing issues** to avoid duplicates
2. **Describe the feature** clearly
3. **Explain the use case** - why is it needed?
4. **Propose a solution** if you have ideas
5. **Consider alternatives** - what else could solve this?

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature

**Use Case**
Why is this feature needed? What problem does it solve?

**Proposed Solution**
How could this feature work?

**Alternatives Considered**
What other approaches could work?

**Additional Context**
Mockups, examples, references
```

## Development Guidelines

### Performance

- Minimize Core Data fetches
- Use `@FetchRequest` appropriately
- Batch operations when possible
- Profile with Instruments for bottlenecks

### Accessibility

- Use proper SwiftUI accessibility modifiers
- Provide meaningful labels for VoiceOver
- Support Dynamic Type
- Ensure sufficient color contrast

### Localization

- Use `LocalizedStringKey` for user-facing strings
- Avoid hardcoded strings in Views
- Consider internationalization from the start

### Security

- Never commit sensitive data (API keys, tokens)
- Validate user input
- Use secure storage for sensitive data
- Follow iOS security best practices

## Questions?

If you have questions about contributing:

1. Check existing documentation (README, DESIGN, QUICKSTART)
2. Search existing issues and discussions
3. Open a discussion or issue for clarification

## License

By contributing to NoBSWorkout, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to NoBSWorkout! Your efforts help make this project better for everyone.
