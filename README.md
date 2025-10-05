# Speak Sure 🎤

**Master your interview skills with AI-powered mock interviews**

Speak Sure is a comprehensive Flutter application designed to help users practice and improve their interview skills through AI-powered mock interviews. The app provides personalized feedback, performance analytics, and detailed reports to help users excel in their career pursuits.

## ✨ Features

### 🏠 Landing Page
- Beautiful, animated landing page with form validation
- User registration with resume upload
- Responsive design for all devices
- Smooth animations and transitions

### 📊 Dashboard
- Performance analytics with interactive charts
- Recent interview history
- Quick stats and progress tracking
- Beautiful data visualization using FL Chart

### 🎯 Mock Interview System
- Dynamic question generation based on user profile
- Real-time timer and progress tracking
- Category-based questions (Technical, Behavioral, Situational)
- Difficulty levels and adaptive questioning

### 📈 Detailed Reports
- Comprehensive performance analysis
- Category-wise scoring breakdown
- Strengths and areas for improvement
- Personalized recommendations
- Interactive radar charts

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants and configuration
│   ├── theme/              # Custom theme and styling
│   └── utils/             # Utility functions and helpers
├── data/                   # Data layer
│   └── models/             # Data models and entities
├── presentation/           # Presentation layer
│   ├── pages/             # Screen widgets
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

## 🎨 Design System

### Color Palette
- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Accent**: Cyan (#06B6D4)
- **Success**: Emerald (#10B981)
- **Warning**: Amber (#F59E0B)
- **Error**: Red (#EF4444)

### Typography
- Modern, clean typography with proper hierarchy
- Responsive font sizes for different screen sizes
- Consistent spacing and line heights

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.5.3 or higher)
- Dart SDK
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/speaksure.git
   cd speaksure
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile
   flutter run
   ```

### Building for Production

**Web:**
```bash
flutter build web --release
```

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Platform Support

- ✅ **Web** - Full responsive design
- ✅ **Android** - Material Design 3
- ✅ **iOS** - Cupertino design elements
- ✅ **Desktop** - Windows, macOS, Linux

## 🛠️ Dependencies

### Core Dependencies
- `flutter_riverpod` - State management
- `go_router` - Navigation and routing
- `fl_chart` - Beautiful charts and graphs
- `file_picker` - File upload functionality

### UI & Animation
- `flutter_svg` - SVG support
- `lottie` - Advanced animations
- `animations` - Material motion

### Data & Storage
- `hive` - Local database
- `shared_preferences` - Simple key-value storage
- `dio` - HTTP client
- `http` - HTTP requests

## 🎯 Key Features Implementation

### Responsive Design
- Adaptive layouts for mobile, tablet, and desktop
- Responsive typography and spacing
- Touch-friendly interactions

### Animation System
- Smooth page transitions
- Loading animations
- Interactive micro-animations
- Animated backgrounds

### State Management
- Riverpod for reactive state management
- Provider pattern for dependency injection
- Clean separation of business logic

## 📊 Performance

- Optimized for 60fps animations
- Efficient memory usage
- Fast startup times
- Smooth scrolling and interactions

## 🔧 Development

### Code Structure
- Clean, maintainable code
- Comprehensive documentation
- Type-safe implementations
- Error handling and validation

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

## 🚀 Deployment

### Web Deployment
The app is optimized for web deployment with:
- Progressive Web App (PWA) support
- Offline functionality
- Fast loading times
- SEO optimization

### Mobile Deployment
- App store ready builds
- Platform-specific optimizations
- Native performance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design inspiration
- Open source community for various packages

---

**Built with ❤️ using Flutter**
