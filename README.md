# 🎮 Multiplayer Tic Tac Toe - Flutter + Firebase

A modern, stylish, real-time **Tic Tac Toe game** built with **Flutter** and **Firebase**, featuring:

* 🔥 Multiplayer support
* ✅ Firebase Authentication (Google Sign-In)
* ☁️ Firestore real-time database
* 🎨 Responsive UI with gradient themes
* 🔁 Turn-based play with alternate starters
* 🏆 Score tracking
* 🎉 Win/Draw messages below the board

---

## 🚀 Features

* **Real-time online multiplayer**
* **Google Sign-In** authentication
* **Create or Join Rooms** using unique Room IDs
* **Animated turn/win/draw status**
* **Automatic board reset** after each game
* **Cool UI with purple-black gradient theme**
* **Alternative turn starters** (first you, then the opponent)
* **Clipboard copy support for Room ID**

---

## 📱 Screenshots

| Login                           | Home                          | Game                          |
| ------------------------------- | ----------------------------- | ----------------------------- |
| ![login](screenshots/login.png) | ![home](screenshots/home.png) | ![game](screenshots/game.png) |

---

## 🧠 Tech Stack

| Layer      | Technology               |
| ---------- | ------------------------ |
| Frontend   | Flutter                  |
| Auth       | Firebase Authentication  |
| Database   | Firebase Firestore       |
| State Mgmt | setState / StreamBuilder |
| UI/UX      | Gradient + Custom Theme  |

---

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/flutter-multiplayer-tic-tac-toe.git
cd flutter-multiplayer-tic-tac-toe
```

### 2. Firebase Setup

#### Step-by-Step:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add an Android app (e.g., `com.example.tictactoe`)
4. Download `google-services.json` and place it in `android/app/`
5. Enable:

   * Authentication > Sign-in method > Google
   * Firestore Database

#### Firestore Structure (example):

```
rooms (collection)
  roomId (document)
    board: [ "", "", "", "", "", "", "", "", "" ]
    player1: "Player A"
    player2: "Player B"
    scores: { X: 0, O: 0 }
    turn: "X"
    lastStarter: "X"
```

---

### 3. Install Dependencies

```bash
flutter pub get
```

---

### 4. Run the App

```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
├── auth/
│   └── login_screen.dart
├── screens/
│   ├── home_screen.dart
│   └── game_screen.dart
├── theme.dart
└── main.dart
```

---

## ✨ Highlights

* No pop-ups! Win/lose/draw messages display **below the board** and fade out naturally.
* User turn starts **alternating** each game.
* Smooth animations, responsive layouts, and Firestore sync.
* Supports **multiple game rooms** and **infinite users**.

---

## 🛡️ Requirements

* Flutter 3.10+
* Firebase Project
* Android Emulator or Physical Device

---

## ✅ To Do / Suggestions

* Add player avatars
* Chat during the game
* Sound effects and animations
* Leaderboard with Firestore
* Confetti celebration 🎉

---

## 🧑‍💻 Author

Made with ❤️ by \[n0rmh3ll]
[GitHub](https://github.com/n0rmh3ll)

---

## 📃 License

MIT License — free to use and modify.

