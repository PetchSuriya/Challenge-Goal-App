# Changelog

All notable changes to Challenge Goal App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added in additional-improvements branch
- Comprehensive installation guide (INSTALLATION.md)
- Complete REST API documentation (API_DOCUMENTATION.md)
- Contributing guidelines and development workflow (CONTRIBUTING.md)
- Enhanced README with system architecture diagram
- Detailed feature descriptions and tech stack documentation

## [1.0.0] - 2025-11-11

### Added
- 🎯 **Goal Management System**
  - Create personal and group goals
  - Track daily progress
  - Set goal duration and categories
  - Complete goals and earn rewards
  - Delete unwanted goals

- 👥 **Social Features**
  - Friend system (add, accept, manage friends)
  - View friend profiles
  - Collaborate on mutual goals
  - See friend activity and progress

- 🎨 **Avatar & Customization**
  - Customizable avatars with multiple slots (head, body, hand, accessory)
  - Inventory system for collectible items
  - Earn items by completing goals
  - Equip and manage avatar appearance

- 🔐 **Authentication & Security**
  - User registration with email validation
  - Secure login with JWT tokens
  - Password encryption using bcrypt
  - Session management
  - Profile management with picture upload

- 📱 **User Interface**
  - Clean, intuitive home page
  - Dashboard with goal overview
  - Profile page with editable fields
  - Friends list and friend profiles
  - Goal creation and management screens

- 🗄️ **Backend Infrastructure**
  - Node.js/Express REST API
  - SQLite database for data persistence
  - CORS enabled for local development
  - Automatic database initialization and seeding
  - Session-based authentication

### Changed
- Improved friend profile display
- Enhanced mutual goal functionality
- Locked birthday field to read-only
- Updated costume system with better adjustments

### Fixed
- Profile data persistence issues
- Friend home page navigation
- Database merge conflicts
- Session management bugs

### Removed
- Playwright testing framework (replaced with Appium)
- Unnecessary testing dependencies

## [0.9.0] - 2025-11-10

### Added
- E2E Testing Suite with Appium
- Costume items and avatar equipment system
- Friends list functionality
- Birthday field in user profile

### Changed
- Profile editing workflow
- Friend interaction flow

### Fixed
- Various profile data bugs
- Friend list display issues

## [0.8.0] - 2025-11-09

### Added
- Initial friend system implementation
- Basic goal tracking
- Avatar display system

### Changed
- Improved authentication flow
- Updated UI components

## [0.7.0] - 2025-11-08

### Added
- User registration and login
- Basic profile management
- JWT authentication
- Database schema

### Changed
- Project structure reorganization
- API endpoint improvements

## [0.6.0] - 2025-11-07

### Added
- Initial Flutter project setup
- Basic navigation structure
- Riverpod state management
- HTTP client configuration

## [0.5.0] - 2025-11-06

### Added
- Node.js backend server
- Express routing
- SQLite database integration
- Basic API endpoints

## Development Phases

### Phase 1: Foundation (v0.1.0 - v0.5.0)
- Project initialization
- Tech stack selection
- Basic architecture setup

### Phase 2: Core Features (v0.6.0 - v0.8.0)
- Authentication system
- User management
- Database schema

### Phase 3: Feature Development (v0.9.0 - v1.0.0)
- Goal management
- Social features
- Avatar system
- Testing infrastructure

### Phase 4: Polish & Documentation (Current)
- Comprehensive documentation
- Installation guides
- API documentation
- Contributing guidelines

## Upcoming Features

### Version 1.1.0 (Planned)
- [ ] Push notifications for goal reminders
- [ ] Goal progress charts and statistics
- [ ] Leaderboard system
- [ ] Achievement badges
- [ ] Goal templates

### Version 1.2.0 (Planned)
- [ ] Social feed/timeline
- [ ] Goal comments and reactions
- [ ] Team challenges
- [ ] Reward shop
- [ ] Profile themes

### Version 2.0.0 (Future)
- [ ] Mobile app deployment (Play Store/App Store)
- [ ] Cloud database migration
- [ ] Real-time notifications
- [ ] Video/photo sharing in goals
- [ ] Advanced analytics
- [ ] Premium features

## Migration Notes

### v0.9.0 to v1.0.0
- Database schema changes: Added `goal_participants` table
- New API endpoints for mutual goals
- Avatar system requires inventory setup
- Session management updates

### v0.8.0 to v0.9.0
- Added Appium testing framework
- Birthday field added to user profile
- Costume system introduced

## Breaking Changes

### v1.0.0
- API endpoint structure standardized
- Authentication flow updated
- Friend request system changed from username to email

### v0.9.0
- Testing framework changed (Playwright → Appium)
- Profile schema updated

## Contributors

- **PetchSuriya** - Project Lead & Main Developer
- **Contributors** - See [GitHub Contributors](https://github.com/PetchSuriya/Challenge-Goal-App/graphs/contributors)

## Support

For questions or issues:
- Create an issue on [GitHub](https://github.com/PetchSuriya/Challenge-Goal-App/issues)
- Check [Installation Guide](INSTALLATION.md) for setup help
- Review [API Documentation](API_DOCUMENTATION.md) for endpoint details

---

**Legend:**
- 🎯 Goals & Tracking
- 👥 Social Features  
- 🎨 UI/Customization
- 🔐 Security
- 🗄️ Backend
- 🐛 Bug Fixes
- 📚 Documentation
