# BurnRate

A Flutter mobile app that gives developers a single dashboard to monitor spending across LLM APIs and cloud platforms — no backend, no account, all credentials stored locally on your device.

---

## Supported Services

| Service | What it tracks |
|---|---|
| Anthropic Claude | API usage & token spend |
| OpenAI (GPT) | API usage & billing |
| Google Gemini | API token usage & estimated cost |
| Amazon Web Services | Cost Explorer month-to-date spend |
| Oracle Cloud (OCI) | Usage API month-to-date costs |

---

## Features

- **Unified dashboard** — all your services in one place, no tab-switching between consoles
- **Budget alerts** — push notifications when spend crosses a threshold you set
- **Period comparison** — see current vs previous month side by side
- **Spend charts** — daily breakdown per service
- **Background refresh** — hourly sync in the background, even when the app is closed
- **Local-only** — credentials never leave your device; stored in iOS Keychain / Android Keystore

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter (iOS + Android) |
| State management | Riverpod |
| Navigation | go_router |
| Secure storage | flutter_secure_storage |
| HTTP | Dio |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Background tasks | WorkManager |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`

### Install & run

```bash
git clone https://github.com/appendix0/burnrate.git
cd burnrate
flutter pub get
flutter run
```

### First launch

On first launch you'll be guided through adding at least one service. For each service you'll need:

| Service | Required credentials |
|---|---|
| Anthropic | API key |
| OpenAI | API key |
| Gemini | API key (+ optional GCP project ID) |
| AWS | Access key ID, secret access key, region |
| OCI | Tenancy OCID, user OCID, fingerprint, private key PEM, region |

> **AWS:** The IAM user only needs the `ce:GetCostAndUsage` permission — no broader access required.

---

## Security

- All credentials are stored exclusively in `flutter_secure_storage` (iOS Keychain / Android Keystore)
- Credentials are never logged, printed, or written to SharedPreferences
- Android backup is disabled (`allowBackup=false`) to prevent credential leakage via cloud backup
- No network requests are made with your credentials other than to the respective service's official API

---

## Project Structure

```
lib/
├── core/               # Constants, utilities
├── data/
│   ├── models/         # Credential, UsageSummary, BudgetAlert, etc.
│   ├── repositories/   # Credential, Usage, Alert repos
│   └── sources/remote/ # Per-service API clients
├── domain/             # Interfaces & business logic services
├── presentation/       # Screens, widgets, Riverpod providers, theme
└── background/         # WorkManager task registration & refresh logic
```

---

## License

MIT
