#!/bin/bash
# Run this once from your terminal to initialize the git repo
# and make the first commit.
#
# Usage:
#   chmod +x setup_git.sh && ./setup_git.sh

set -e

PKG_DIR="/run/user/1000/doc/c28b54e4/Jatayat/flutter_github_feedback"

cd "$PKG_DIR"

echo "📦 Initializing git repo..."
git init

echo "🔧 Configuring default branch..."
git checkout -b main

echo "📋 Staging files..."
git add pubspec.yaml analysis_options.yaml .gitignore CHANGELOG.md README.md lib/ test/

echo "✅ Files staged (PLANNING.md is excluded via .gitignore):"
git status

echo ""
echo "💾 Making first commit..."
git commit -m "CHORE: scaffold flutter package"

echo ""
echo "🎉 Done! Commit 1 complete."
echo "📂 Now open this folder in Android Studio:"
echo "    $PKG_DIR"
echo ""
echo "Then set run target to: example/lib/main.dart (after Commit 2)"
