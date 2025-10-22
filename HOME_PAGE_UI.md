# Home Page UI Documentation

## Overview

The Home page serves as the main navigation hub of the ChallengeGoals app, featuring a clean layout with navigation buttons, a central avatar display, and quick access to key features.

## Layout Structure

```
┌─────────────────────────────────────┐
│ [Profile]    [Friends]   [Costume]  │ ← Top Navigation
│              (160x50)     [Premium] │
│                                     │
│            [Avatar Image]           │ ← 400x400dp PNG
│             (400x400)               │
│                                     │
│         [My Goals Button]           │ ← Bottom Action
│         (Full width x 70)           │
└─────────────────────────────────────┘
```

## Widget Components

### Top Navigation Buttons

#### Profile Button (Top-Left)
- **Size**: 70x70dp square
- **Icon**: `Icons.person_outline`
- **Color**: Blue (Colors.blue.shade600)
- **Action**: Navigate to ProfilePage
- **Layout**: Icon on top, label below

#### Friends Button (Top-Center)
- **Size**: 160x50dp rectangle
- **Style**: Gradient button (green.shade500 to green.shade700)
- **Icon**: `Icons.people_outline` with white circular background
- **Action**: Navigate to FriendsHomePage with sample friend "Alex"
- **Route**: `/friends/Alex?avatarUrl=assets/images/avatar.png`
- **Layout**: Horizontal - icon + text

#### Costume Button (Top-Right, Upper)
- **Size**: 70x70dp square
- **Icon**: `Icons.style_outlined`
- **Color**: Purple (Colors.purple.shade600)
- **Action**: Show "Coming Soon" dialog
- **Layout**: Icon on top, label below

#### Premium Button (Top-Right, Lower)
- **Size**: 70x70dp square
- **Icon**: `Icons.workspace_premium_outlined`
- **Color**: Orange (Colors.orange.shade600)
- **Action**: Show "Coming Soon" dialog
- **Layout**: Icon on top, label below

### Avatar Display (Center)
- **Size**: 400x400dp
- **Position**: Positioned at top: 60dp from navigation area
- **Source**: `Image.asset('assets/images/avatar.png')`
- **Fallback**: Clean message container with instructions
- **Fit**: BoxFit.contain for proper scaling

### Goals Button (Bottom)
- **Size**: Full width x 70dp height
- **Style**: Gradient button (blue.shade600 to purple.shade600)
- **Position**: 40dp from bottom edge
- **Icon**: `Icons.flag_outlined` with white circular background
- **Action**: Show "Coming Soon" dialog
- **Layout**: Horizontal - icon + "Goals" text + arrow

## File Structure

```
lib/features/home/
├── controller/
│   └── home_controller.dart    # State management for home page
└── view/
    └── home_page.dart         # Main home page UI implementation
```

## Key Methods

### `_buildTopNavigation(BuildContext context)`
Creates the top navigation row with Profile, Friends, and Costume/Premium buttons.

### `_buildSquareButton({...})`
Reusable method for creating 70x70dp square buttons with icon and label.

### `_buildFriendsButton(BuildContext context)`
Creates the medium-width gradient Friends button.

### `_buildGoalButton(BuildContext context)`
Creates the full-width gradient Goals button at the bottom.

### `_buildFallbackAvatar()`
Creates fallback UI when avatar.png is not found - shows instructions.

## Positioning Logic

- **Transparent Navigation**: No white background, blends with main screen
- **Spacer Distribution**: Uses Spacer widgets for proper button spacing
- **Stack Layout**: Main content uses Stack for precise avatar positioning
- **Responsive Design**: Adapts to different screen sizes while maintaining proportions

## State Management

Uses Riverpod with `HomeController` for:
- Initialization on page load
- Future feature state management
- Error handling for avatar loading

## Color Scheme

- **Profile**: Blue theme (blue.shade600)
- **Friends**: Green gradient (green.shade500 to green.shade700)
- **Costume**: Purple theme (purple.shade600)
- **Premium**: Orange theme (orange.shade600)
- **Goals**: Blue-Purple gradient (blue.shade600 to purple.shade600)
- **Background**: Light grey (Colors.grey.shade50)

## Future Enhancements

The UI is prepared for:
- **Dynamic avatar switching**
- **Costume overlay system**
- **Animation effects**
- **Feature activation** (removing "Coming Soon" dialogs)
- **User level display**
- **Progress indicators**

## Testing

To test the Home page:
1. Login to the app
2. Navigate to Home page (automatic after login)
3. Test all button interactions
4. Add avatar.png to test image loading
5. Verify responsive layout on different screen sizes