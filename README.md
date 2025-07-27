# MediEvil Advisor 🏰⚔️

A Flutter proof of concept for the original **MediEvil Advisor** backend project - a medieval-themed evil intrusive thoughts assistant that provides mischievous alternatives to your responsible goals and tasks.

## 🎯 About

This Flutter application is a **proof of concept** for the original **MediEvil Advisor** backend project - a Firebase Cloud Functions backend for AI-powered task processing using Google's Genkit framework with a medieval advisor persona.

The original backend project ([https://github.com/canberkozcelik/medievil-advisor](https://github.com/canberkozcelik/medievil-advisor)) provides:
- **AI-powered task processing** using Google's Gemini AI model
- **Medieval advisor persona** with British accent TTS
- **Firebase Cloud Functions** for serverless API
- **Firestore database** for session management
- **Google Cloud TTS** for audio response generation

The Flutter app demonstrates the client-side implementation, featuring:
- Voice-controlled interaction with the medieval advisor
- Real-time speech-to-text and text-to-speech
- Integration with the backend API for AI-powered responses
- Medieval-themed UI with state-driven design

Think of it as having a cheeky medieval advisor who always suggests the fun, slightly evil option!

## ✨ Features

- **🎤 Voice Recognition**: Speak your responsible thoughts and goals
- **🏰 Medieval Responses**: Get mischievous medieval-themed alternatives
- **🎵 Audio Playback**: Hear the advisor's response with text-to-speech
- **📱 Cross-Platform**: Works on both iOS and Android
- **🎨 Modern UI**: Clean, intuitive interface with state-driven design

## 🏗️ Architecture

Built with modern Flutter development principles:

- **BLoC Pattern**: Clean state management
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **Dependency Injection**: Using `get_it` for service management
- **Platform Services**: Abstracted platform-specific functionality
- **Comprehensive Testing**: Unit tests for BLoC and services

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for platform-specific development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medievil_advisor
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Backend Endpoint (Required)**
   
   You must provide your own backend endpoint. Edit `lib/core/config/api_config.dart`:
   
   ```dart
   // Replace with your own backend URL
   static const String baseUrl = 'https://your-backend-url.com';
   ```
   
   **Backend Requirements:**
   - **POST** `/taskAPI` - Accepts `{"task": "user input"}` and returns `{"result": "response", "audioSessionId": "uuid", "audioUrl": "/audio/uuid"}`
   - **GET** `/audio/{sessionId}` - Returns MP3 audio for the session

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎮 How to Use

1. **Launch the app** - You'll see the main interaction screen
2. **Tap "Record"** - Grant microphone permission when prompted
3. **Speak your goal** - Tell the app your responsible thought or goal
4. **Tap "Stop"** - When you're done speaking
5. **Listen to the response** - The medieval advisor will provide a mischievous alternative!

**Note**: This app requires a backend server to be running for full functionality. You must configure your own backend endpoint in `lib/core/config/api_config.dart`. The backend handles the AI-powered response generation and provides audio responses.

## 🧪 Testing

Run the comprehensive test suite:

```bash
flutter test
```

The project includes:
- **BLoC Tests**: State management and business logic
- **Service Tests**: Audio file operations and platform services
- **Integration Tests**: End-to-end functionality

## 📱 Platform Support

- **iOS**: Requires microphone and speech recognition permissions
- **Android**: Requires microphone and speech recognition permissions
- **Simulator/Emulator**: Tested on both iOS Simulator and Android Emulator

## 🔧 Technical Stack

### **Frontend (This Repository)**
- **Flutter**: Cross-platform UI framework
- **BLoC**: State management
- **Speech-to-Text**: Voice recognition
- **Just Audio**: Audio playback
- **Get It**: Dependency injection
- **Mockito**: Testing and mocking

### **Backend (Original Project)**
- **Firebase Cloud Functions**: Serverless backend with TypeScript
- **Google Gemini AI**: State-of-the-art AI model for task processing
- **Google Cloud TTS**: British accent text-to-speech
- **Firestore**: NoSQL database for session management
- **Genkit Framework**: Google's AI development framework

## 🏛️ Project Structure

```
lib/
├── core/
│   ├── di/           # Dependency injection
│   └── services/     # Platform services
├── features/
│   └── interaction/
│       ├── data/     # Data layer
│       ├── domain/   # Business logic
│       └── presentation/ # UI layer
└── main.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎭 The Concept

This Flutter app is a **proof of concept** demonstrating the client-side implementation of the original MediEvil Advisor backend project. The concept is inspired by the idea that sometimes we need a little mischief in our lives. Instead of always being responsible, the app encourages you to embrace your inner medieval troublemaker - but in a fun, harmless way!

*"Why go to the gym when you could feast on sugared plums and honeyed ales?"* 🍯

## 🔗 Related Projects

- **Original Backend**: [MediEvil Advisor Backend](https://github.com/canberkozcelik/medievil-advisor) - Firebase Cloud Functions with Google Genkit
- **This Repository**: Flutter proof of concept for the client-side implementation

## 🔌 API Integration

This Flutter app integrates with the following backend endpoints:

- **POST** `/taskAPI` - Submit user tasks for AI processing
- **GET** `/audio/{sessionId}` - Retrieve audio responses from the backend

### Backend Configuration

The app uses a configurable backend endpoint defined in `lib/core/config/api_config.dart`. You must:

1. **Provide your own backend** - Edit the `baseUrl` in the config file
2. **Deploy your own backend** - Follow the original backend project for reference
3. **Implement the required API endpoints** - See backend requirements below

### Backend Requirements

Your backend must implement these endpoints:

**POST** `/taskAPI`
```json
// Request
{"task": "user input"}

// Response
{
  "result": "AI-generated response",
  "audioSessionId": "uuid-session-id",
  "audioUrl": "/audio/uuid-session-id"
}
```

**GET** `/audio/{sessionId}`
- Returns MP3 audio for the specified session
- Content-Type: `audio/mpeg`

### Reference Backend

The original backend project ([https://github.com/canberkozcelik/medievil-advisor](https://github.com/canberkozcelik/medievil-advisor)) provides:
- **65/65 passing tests** with 94.87% code coverage
- **AI-powered responses** using Google's Gemini AI model
- **British accent TTS** using Google Cloud Text-to-Speech
- **Session management** with Firestore database

You can use this as a reference to implement your own backend with the same API structure.

---

**Disclaimer**: This app is for entertainment purposes only. The medieval advisor's suggestions are meant to be humorous and should not be taken as actual life advice! 😄
