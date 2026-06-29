import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:feedback_github/feedback_github.dart';

/// Replace these with your real values before running.
/// Never commit real tokens — use --dart-define or a .env loader.
const _kToken = "";
const _kOwner = "alxayeed";
const _kRepo = "feedback_github";
const _kBranch = "feedback";

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
          branch: _kBranch,
        ),
        // Configure global button styling
        icon: const Icon(Icons.bug_report, color: Colors.yellow),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.yellow,
      ),
      child: MaterialApp(
        title: 'feedback_github — Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
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
      appBar: AppBar(title: const Text('feedback_github'), centerTitle: true),
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
                'Tap the floating "Feedback" button on the screen.\n'
                'You can drag the button to reposition it.\n'
                'Draw on the screenshot, pick a category,\n'
                'and submit — a GitHub Issue will be created.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.navigate_next),
                label: const Text('Go to Custom Feedback Page'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CustomFeedbackPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _InfoCard(
                icon: Icons.token_outlined,
                title: 'Token',
                value:
                    _kToken.isEmpty
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

class CustomFeedbackPage extends StatelessWidget {
  const CustomFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Feedback Page')),
      floatingActionButton: const FeedbackButton(
        variant: FeedbackButtonVariant.big,
        icon: Icon(Icons.support_agent),
        label: Text('Get Support'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.support_agent, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Custom Feedback Screen',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'On this screen, the default purple/yellow draggable feedback button is hidden. '
                'Instead, you only see the explicit green "Get Support" button in the scaffold\'s FloatingActionButton slot.\n\n'
                'Go back to the Home page, and the draggable button will reappear.',
                textAlign: TextAlign.center,
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
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
