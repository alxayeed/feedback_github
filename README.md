# feedback_github

[![pub package](https://img.shields.io/pub/v/feedback_github.svg)](https://pub.dev/packages/feedback_github)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/platform-flutter-02569B.svg?logo=flutter)](https://flutter.dev)

A Flutter package that lets users submit in-app feedback — with an annotated
screenshot — directly as a **GitHub Issue**.  
Built on [`feedback`](https://pub.dev/packages/feedback) (BetterFeedback) for
screenshot capture, with a clean backend-agnostic design so you can swap
GitHub for Firestore, Slack, email, or any custom destination.

---

## Features

- 📸 **Screenshot capture** — powered by `BetterFeedback`; users draw on the
  screen before submitting
- 🐛 **GitHub Issues** — screenshot uploaded to your repo, issue created with
  embedded image and the correct GitHub label applied automatically
- 🗂 **Enum-based categories** — no strings or emojis to supply; each
  `FeedbackCategory` value knows its own label, emoji, and GitHub label
- 🔌 **Backend-agnostic** — implement `FeedbackBackend` to send feedback
  anywhere
- 🪶 **Zero-cost when disabled** — `enabled: false` renders your app as-is
  with no overhead
- 🎨 **Material 3 UI** — dark/light-aware, fully themed bottom sheet

---

## Installation

Add via Git until the package is published to pub.dev:

```yaml
dependencies:
  feedback_github:
    git:
      url: https://github.com/alxayeed/feedback_github
      ref: 0.0.1
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

### 1. Wrap your app

```dart
import 'package:feedback_github/feedback_github.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    GithubFeedback(
      config: FeedbackConfig(
        enabled: kDebugMode, // hide in production
        backend: GitHubFeedbackBackend(
          token:     'ghp_yourPersonalAccessToken',
          repoOwner: 'your-org',
          repoName:  'your-repo',
          branch:    'feedback', // optional, default: 'main'
        ),
      ),
      child: const MyApp(),
    ),
  );
}
```

### 2. Add the button

Drop `FeedbackButton` into any `Scaffold`:

```dart
Scaffold(
  floatingActionButton: FeedbackButton(),
  body: ...,
)
```

That's it. Tapping the button opens the feedback sheet with screenshot capture.

---

## GitHub Token Setup

Create a **fine-grained Personal Access Token** with the following repository
permissions:

| Permission | Access |
|-----------|--------|
| **Contents** | Read & write |
| **Issues** | Read & write |

> ⚠️ **Never hard-code tokens in source code.** Use `--dart-define` or a
> secrets manager:
>
> ```bash
> flutter run --dart-define=GH_TOKEN=ghp_xxx
> ```
>
> ```dart
> const token = String.fromEnvironment('GH_TOKEN');
> ```

---

## Configuration

### `FeedbackConfig`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `backend` | `FeedbackBackend` | required | Where to send feedback |
| `enabled` | `bool` | `true` | Show/hide the feedback UI |
| `categories` | `List<FeedbackCategory>` | `FeedbackCategory.values` | Categories shown to the user |

### `GitHubFeedbackBackend`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `token` | `String` | required | GitHub Personal Access Token |
| `repoOwner` | `String` | required | Repository owner (user or org) |
| `repoName` | `String` | required | Repository name |
| `branch` | `String` | `'main'` | Branch for screenshot uploads |
| `screenshotDir` | `String` | `'feedback/screenshots'` | Directory for screenshot assets |

---

## `FeedbackCategory` — enum

No strings or emojis needed. Each enum value knows its own display label,
emoji, and the exact GitHub label to apply to the created issue.

| Value | Emoji | Display Label | GitHub Label |
|-------|-------|--------------|--------------|
| `FeedbackCategory.bug` | 🐛 | Bug Report | `bug` ✱ |
| `FeedbackCategory.enhancement` | ✨ | Enhancement | `enhancement` ✱ |
| `FeedbackCategory.question` | ❓ | Question | `question` ✱ |
| `FeedbackCategory.performance` | ⚡ | Performance | `performance` |
| `FeedbackCategory.uiUx` | 🎨 | UI / UX | `ui/ux` |
| `FeedbackCategory.documentation` | 📖 | Documentation | `documentation` ✱ |
| `FeedbackCategory.other` | 💬 | Other | `feedback` |

> ✱ Maps to GitHub's built-in default labels. Custom labels are created
> automatically on first use by the GitHub Issues API.

```dart
// Use all categories (default — no configuration needed)
FeedbackConfig(backend: ...) // categories defaults to FeedbackCategory.values

// Cherry-pick specific categories
FeedbackConfig(
  backend: ...,
  categories: [FeedbackCategory.bug, FeedbackCategory.enhancement],
)
```

---

## Custom Button

```dart
FeedbackButton(
  icon:  Icon(Icons.bug_report_outlined),
  label: Text('Report a bug'),
)
```

The button returns `SizedBox.shrink()` when `enabled: false` — safe to leave
in the widget tree in production.

---

## Custom Backends

Implement `FeedbackBackend` to send feedback anywhere:

```dart
class SlackFeedbackBackend implements FeedbackBackend {
  @override
  Future<void> submit({
    required FeedbackCategory category,
    required String text,
    Uint8List? screenshot,
  }) async {
    // Use category.displayLabel, category.emoji, category.githubLabel, etc.
    // Post to Slack webhook, Firestore, email, etc.
  }
}
```

Then pass it to `FeedbackConfig`:

```dart
FeedbackConfig(
  backend: SlackFeedbackBackend(),
)
```

---

## What a GitHub Issue looks like

When a user submits feedback, the package:

1. Uploads the screenshot PNG to `feedback/screenshots/<timestamp>.png`
2. Creates an issue labelled with the matching GitHub label:

```
Title:  [Bug Report] App crashes when tapping the settings icon

Category: Bug Report

Description:
Tapping the settings icon on the home screen causes an immediate crash.

Screenshot:
![Bug Report screenshot](<download_url>)
```

---

## Advanced: Accessing the Notifier

```dart
// Subscribe to state changes (use in build methods)
final notifier = FeedbackScope.of(context);

// Read without subscribing (use in callbacks)
final notifier = FeedbackScope.read(context);
```

---

## License

```
MIT License — © 2026 alxayeed
```
