import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:feedback_github/feedback_github.dart';

/// Replace these with your real values before running.
/// Never commit real tokens — use --dart-define or a .env loader.
const _kToken = String.fromEnvironment('GH_TOKEN', defaultValue: 'YOUR_TOKEN');
const _kOwner = String.fromEnvironment('GH_OWNER', defaultValue: 'your-org');
const _kRepo = String.fromEnvironment('GH_REPO', defaultValue: 'your-repo');

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GithubFeedback(
      config: FeedbackConfig(
        // enabled: kDebugMode — set to false to hide the button in production.
        enabled: kDebugMode,
        backend: GitHubFeedbackBackend(
          token: _kToken,
          repoOwner: _kOwner,
          repoName: _kRepo,
          branch: 'feedback',
        ),
        // Optionally override categories with enum values:
        // categories: [FeedbackCategory.bug, FeedbackCategory.enhancement],
      ),
      child: MaterialApp(
        title: 'feedback_github — Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('feedback_github'),
        centerTitle: true,
      ),
      // ── Drop FeedbackButton anywhere in your Scaffold ──────────────────
      floatingActionButton: const FeedbackButton(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_chat_read_outlined,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              Text(
                'Feedback Demo',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the "Feedback" button below.\n'
                'Draw on the screenshot, pick a category,\n'
                'and submit — a GitHub Issue will be created.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _InfoCard(
                icon: Icons.token_outlined,
                title: 'Token',
                value: _kToken == 'YOUR_TOKEN'
                    ? 'Not configured (placeholder)'
                    : '••••••••${_kToken.substring(_kToken.length - 4)}',
              ),
              const SizedBox(height: 8),
              _InfoCard(
                icon: Icons.folder_outlined,
                title: 'Repo',
                value: '$_kOwner / $_kRepo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
