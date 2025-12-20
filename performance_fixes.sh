#!/bin/bash

# Performance Quick Fixes Script
# Run with: chmod +x performance_fixes.sh && ./performance_fixes.sh

echo "🚀 Applying Flutter Web Performance Fixes..."
echo ""

# 1. Build with HTML renderer
echo "✅ Building with HTML renderer..."
fvm flutter clean
fvm flutter pub get
fvm flutter build web --web-renderer html --release

echo ""
echo "📊 Build complete! Check build/web for output"
echo ""

# 2. Run in profile mode to test
echo "🔍 Run this command to test performance:"
echo "fvm flutter run -d chrome --profile --web-renderer html"
echo ""

# 3. Check for performance issues
echo "🐛 Checking for const violations..."
fvm flutter analyze | grep "prefer_const" | head -20
echo ""

echo "✨ Quick fixes applied!"
echo ""
echo "Next steps:"
echo "1. Test the app: fvm flutter run -d chrome --web-renderer html"
echo "2. Open Chrome DevTools > Performance tab"
echo "3. Record an interaction and check INP metric"
echo "4. Review PERFORMANCE_OPTIMIZATION.md for more fixes"
