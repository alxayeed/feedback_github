import 'package:flutter/material.dart';

/// Entry point for the flutter_github_feedback example app.
///
/// At this stage the package barrel is empty — the real integration
/// (`GithubFeedback` wrapper + `FeedbackButton`) is wired up in the
/// CHORE: wire up barrel exports commit once all widgets exist.
void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_github_feedback — Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_github_feedback'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.feedback_outlined, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              Text(
                'Example App',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The feedback button will appear here once all '
                'package widgets are implemented.\n\n'
                'Follow the commit plan in PLANNING.md.',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _StatusTile(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Commit 1 — scaffold done',
              ),
              _StatusTile(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Commit 2 — example app done',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 3 — config models',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 4 — backend + GitHub impl',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 5 — state management',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 6 — feedback sheet UI',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 7 — feedback button widget',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 8 — GithubFeedback root widget',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 9 — wire up barrel + example',
              ),
              _StatusTile(
                icon: Icons.radio_button_unchecked,
                color: Colors.grey,
                label: 'Commit 10 — complete README',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
