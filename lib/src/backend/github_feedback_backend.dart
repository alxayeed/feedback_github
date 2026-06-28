import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/feedback_category.dart';
import 'feedback_backend.dart';

/// A [FeedbackBackend] that submits feedback to a GitHub repository.
///
/// For each submission it:
/// 1. Uploads the screenshot PNG to `<screenshotDir>/<timestamp>.png` in the
///    repo via the GitHub Contents API.
/// 2. Creates a GitHub Issue with the category, description, and an embedded
///    screenshot image (Markdown `![]()` syntax). The issue is automatically
///    labelled using [FeedbackCategory.githubLabel].
///
/// **Setup:**
/// - Create a fine-grained Personal Access Token with **Contents** (write) and
///   **Issues** (write) permissions on the target repo.
/// - Optionally create a `feedback` branch to keep issue assets separate.
///
/// ```dart
/// GitHubFeedbackBackend(
///   token:     'ghp_yourToken',
///   repoOwner: 'your-org',
///   repoName:  'your-repo',
///   branch:    'feedback',   // default: 'main'
/// )
/// ```
class GitHubFeedbackBackend implements FeedbackBackend {
  const GitHubFeedbackBackend({
    required this.token,
    required this.repoOwner,
    required this.repoName,
    this.branch = 'main',
    this.screenshotDir = 'feedback/screenshots',
  });

  /// GitHub Personal Access Token (fine-grained or classic).
  final String token;

  /// Owner of the target repository (user or organisation login).
  final String repoOwner;

  /// Name of the target repository.
  final String repoName;

  /// Branch to commit screenshot assets to. Defaults to `'main'`.
  final String branch;

  /// Directory inside the repo where screenshots are stored.
  /// Defaults to `'feedback/screenshots'`.
  final String screenshotDir;

  // ---------------------------------------------------------------------------
  // FeedbackBackend
  // ---------------------------------------------------------------------------

  @override
  Future<void> submit({
    required FeedbackCategory category,
    required String text,
    Uint8List? screenshot,
  }) async {
    String? screenshotUrl;

    if (screenshot != null) {
      screenshotUrl = await _uploadScreenshot(screenshot);
    }

    await _createIssue(
      category: category,
      text: text,
      screenshotUrl: screenshotUrl,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Uploads [bytes] as a PNG to the repo and returns its `download_url`.
  Future<String> _uploadScreenshot(Uint8List bytes) async {
    final filename = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
    final repoPath = '$screenshotDir/$filename';

    final uri = Uri.parse(
      'https://api.github.com/repos/$repoOwner/$repoName/contents/$repoPath',
    );

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'message': 'chore: add feedback screenshot $filename',
        'content': base64Encode(bytes),
        'branch': branch,
      }),
    );

    if (response.statusCode != 201) {
      throw GitHubFeedbackException(
        'Screenshot upload failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['content'] as Map<String, dynamic>)['download_url'] as String;
  }

  /// Creates a GitHub Issue with the feedback details.
  Future<void> _createIssue({
    required FeedbackCategory category,
    required String text,
    String? screenshotUrl,
  }) async {
    final uri = Uri.parse(
      'https://api.github.com/repos/$repoOwner/$repoName/issues',
    );

    final body = StringBuffer()
      ..writeln('**Category:** ${category.displayLabel}')
      ..writeln()
      ..writeln('**Description:**')
      ..writeln(text);

    if (screenshotUrl != null) {
      body
        ..writeln()
        ..writeln('**Screenshot:**')
        ..writeln('![${category.displayLabel} screenshot]($screenshotUrl)');
    }

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': '[${category.displayLabel}] ${_truncate(text, 60)}',
        'body': body.toString(),
        // githubLabel maps to GitHub's built-in labels where possible.
        'labels': [category.githubLabel],
      }),
    );

    if (response.statusCode != 201) {
      throw GitHubFeedbackException(
        'Issue creation failed '
        '(${response.statusCode}): ${response.body}',
      );
    }
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'Content-Type': 'application/json',
  };

  /// Truncates [text] to [max] characters, appending `…` if needed.
  String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}…';
  }
}

/// Thrown when a GitHub API call fails unexpectedly.
class GitHubFeedbackException implements Exception {
  const GitHubFeedbackException(this.message);

  final String message;

  @override
  String toString() => 'GitHubFeedbackException: $message';
}
