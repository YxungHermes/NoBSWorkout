# Changelog

All notable changes to the NoBSWorkout project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive .gitignore for iOS/Xcode development
- CHANGELOG.md for version tracking
- CONTRIBUTING.md with contribution guidelines
- Proper directory structure following iOS conventions

### Changed
- Reorganized repository structure for better maintainability
- Moved source files from `NoBSWorkout/NoBSWorkout/NoBSWorkout/` to `NoBSWorkout/`
- Relocated Info.plist to proper location in NoBSWorkout directory
- Restructured Core Data model file to proper .xcdatamodeld bundle format

### Removed
- 21 duplicate Swift files with mangled names from root directory
- Misplaced configuration files with incorrect naming

### Fixed
- Directory nesting issue (reduced from 3 levels to standard 1 level)
- Configuration file naming and placement

## [1.0.0] - 2025-11-18

### Added
- Complete iOS workout tracking application built with SwiftUI
- MVVM architecture with clean separation of concerns
- Core Data persistence with 4 entities:
  - ExerciseTemplate: Exercise definitions and templates
  - WorkoutSession: Individual workout sessions
  - SetEntry: Individual sets within workouts
  - PersonalRecord: PR tracking and history
- Home view with recent workout display and quick start
- Workout logging with real-time PR detection
- Exercise selector with search and muscle group filtering
- History view with workout history and detailed views
- Personal Records (PRs) view with progress tracking
- Rest timer with preset and custom durations
- 24 pre-seeded exercises covering major muscle groups
- Comprehensive documentation:
  - README.md with project overview
  - DESIGN.md with detailed system architecture
  - QUICKSTART.md for getting started
  - FILE_MANIFEST.md with complete file listing
  - SETUP_CHECKLIST.md for implementation tracking
  - APP_PREVIEW.md with feature showcase
- MIT License
- Support for:
  - Multiple workout splits (Push/Pull/Legs, Upper/Lower)
  - Weight and rep tracking
  - RPE (Rate of Perceived Exertion) tracking
  - Custom exercise creation
  - Favorite exercises
  - Haptic feedback
  - Timer notifications

### Technical Details
- **Language**: Swift 5.9+
- **Minimum iOS**: 15.0+
- **Architecture**: MVVM with Combine
- **Persistence**: Core Data
- **UI Framework**: SwiftUI
- **Features**:
  - Real-time PR detection using Epley formula
  - Automatic 1RM calculations
  - Volume tracking
  - Session duration tracking
  - Search and filtering capabilities
  - Clean, minimal UI design

---

## Version History

### Version 1.0.0 (Initial Release)
- First complete implementation of NoBSWorkout
- Full workout tracking functionality
- Core Data integration
- Comprehensive documentation
- Production-ready codebase

### Repository Reorganization (2025-11-18)
- Cleaned up repository structure
- Removed duplicate files
- Established proper iOS project conventions
- Added standard repository files
