<div align="center">

<img src="https://img.shields.io/badge/Gemma%204%20Good-Hackathon-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Hackathon Badge"/>
<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
<img src="https://img.shields.io/badge/Firebase-Powered-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
<img src="https://img.shields.io/badge/AI-Google%20Gemma-34A853?style=for-the-badge&logo=google&logoColor=white" alt="Gemma AI"/>
<img src="https://img.shields.io/badge/License-MIT-red?style=for-the-badge" alt="License"/>

<br/><br/>

# 🏥 GemmaCare
### *Next-Gen AI Healthcare Assistant*

> **Empowering lives through intelligent, personalized, and accessible healthcare — powered by Google Gemma.**

<br/>

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue?logo=flutter)](https://flutter.dev)
[![Powered by Gemma](https://img.shields.io/badge/Powered%20by-Google%20Gemma-green?logo=google)](https://ai.google.dev/gemma)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=android)](/)

</div>

---

## 📖 About GemmaCare

**GemmaCare** is a smart, AI-driven healthcare platform built for the **Gemma 4 Good Hackathon**. It leverages the advanced reasoning capabilities of Google's **Gemma** models to provide personalized medical guidance, life-saving emergency assistance, and intelligent dietary management — all within a single, beautifully designed mobile application.

Healthcare is not a luxury — it's a right. GemmaCare makes expert-level medical intelligence accessible to **everyone**, regardless of their location, language, or economic background.

---

## 🌟 Key Features

### 🚑 1. Emergency QR System *(Life-Saving Access)*

> *In critical situations, every second counts.*

GemmaCare's Emergency QR System acts as a **digital medical ID** that first responders can access instantly.

| Feature | Description |
|---|---|
| 🔑 **Unique QR Code** | Every user gets a personal encrypted QR code |
| 🏥 **Instant Info** | Displays blood group, allergies, chronic conditions & emergency contacts |
| 🔒 **Privacy-First** | Only essential emergency data is exposed — no full profile leak |
| ⚡ **Zero Friction** | No app needed to scan — works with any standard QR reader |

---

### 🥗 2. AI-Driven Medical Diet Planner *(Precision Nutrition)*

> *Generic diet charts don't work for everyone.*

GemmaCare creates a hyper-personalized **Precision Nutrition Plan** using Gemma's contextual reasoning.

- 🧠 **Gemma analyzes** BMI, current health status, and full medical history
- 🍽️ **Generates daily meal plans** tailored to conditions (e.g., Low-Sodium for Hypertension, High-Protein for Recovery)
- 🌍 **Regional food alternatives** — suggests locally available substitutes
- 📈 **Dynamic updates** — meal plans evolve with the patient's health progress

---

### 💊 3. Smart Medicine Suggestion & Analysis

> *Understand your medications like never before.*

Powered by Gemma's advanced NLP, GemmaCare brings clinical-level clarity to medication management.

- 📋 **Input symptoms** or upload a prescription image (OCR-powered)
- 💡 **Explains each medicine** — purpose, mechanism, and what to expect
- ⚠️ **Side-effect alerts** — flags potential adverse reactions proactively
- ⏰ **Reminder scheduling** — never miss a dose again
- 🛡️ **Mandatory medical disclaimer** on every response for user safety

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology |
|---|---|
| 🤖 **AI Model** | Google Gemma (via `flutter_gemma` + `google_generative_ai`) |
| 📱 **Frontend** | Flutter 3.x (Dart) |
| 🔥 **Backend & Auth** | Firebase (Authentication + Cloud Firestore) |
| 🗄️ **Local Database** | SQLite (via `sqflite`) |
| 📸 **Vision / OCR** | Google ML Kit (Text Recognition + Image Labeling) |
| 📊 **Charts** | FL Chart |
| 🔗 **QR Generation** | `qr_flutter` |
| 💾 **Local Storage** | Shared Preferences |
| 🌐 **Networking** | Dio + HTTP |
| 🩺 **Health Data** | Health Package (HealthKit / Google Fit) |

</div>

---

## 🧠 How We Use Gemma

We don't just use Gemma as a chatbot. We use it as a **clinical reasoning engine**:

```
┌─────────────────────────────────────────────────────────┐
│                    GEMMA CORE ENGINE                     │
├─────────────────┬───────────────────┬───────────────────┤
│  Contextual     │   Multilingual    │  Data             │
│  Reasoning      │   Support         │  Summarization    │
│                 │                   │                   │
│ Links dietary   │ Healthcare in     │ Converts complex  │
│ needs with      │ local languages   │ medical jargon    │
│ medical         │ for accessibility │ into simple,      │
│ conditions      │                   │ actionable steps  │
└─────────────────┴───────────────────┴───────────────────┘
```

### Gemma Integration Highlights:
- **🔗 Contextual Reasoning** — Links dietary requirements with specific medical conditions and medications
- **🌐 Multilingual Support** — Makes healthcare accessible in regional/local languages
- **📄 Data Summarization** — Converts complex medical jargon into simple, patient-friendly guidance
- **🧬 On-Device Inference** — Gemma runs locally via `flutter_gemma` for **privacy-first**, offline AI

---

## 🏗️ Project Architecture

```
gemmacare/
├── lib/
│   ├── core/              # App-wide constants, themes, utilities
│   ├── models/            # Data models (User, MedRecord, DietPlan...)
│   ├── screens/
│   │   ├── auth/          # Login, Signup flows
│   │   ├── home/          # Dashboard & Home Tab
│   │   └── features/      # QR, Diet, Medicine, Food Suggestion screens
│   └── services/
│       ├── api_service.dart    # Gemma AI API integration
│       └── db_manager.dart     # Local SQLite management
├── android/               # Android-specific configs
├── assets/images/         # App assets
├── firebase.json          # Firebase configuration
└── pubspec.yaml           # Dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.11.3`
- Dart SDK `^3.x`
- Android Studio / VS Code
- A Firebase project configured
- Google Gemma model weights (for on-device inference)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/gemmacare.git
cd gemmacare

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase
# Add your google-services.json to android/app/
# Run: flutterfire configure

# 4. Run the app
flutter run
```

---

## 📸 Screenshots

> *Coming Soon — App demo screenshots and screen recordings.*

---

## 🔐 Privacy & Security

GemmaCare is built with a **privacy-first** philosophy:

- 🔒 On-device Gemma inference — sensitive health data never leaves the device
- 🛡️ Firebase Security Rules — strict read/write access control
- 🔑 QR codes expose only emergency-critical data, never the full profile
- 📵 No unnecessary data collection or third-party analytics

---

## ⚠️ Medical Disclaimer

> GemmaCare is an **AI-assisted wellness tool** and is **NOT a substitute for professional medical advice, diagnosis, or treatment**. Always consult a qualified healthcare provider for medical decisions. In case of an emergency, call your local emergency services immediately.

---

## 👨‍💻 Team

Built with ❤️ for the **Gemma 4 Good Hackathon** by a passionate team dedicated to making healthcare accessible for everyone.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**⭐ Star this repo if GemmaCare inspired you!**

*Made with Flutter • Powered by Google Gemma • Built for Good*

</div>
