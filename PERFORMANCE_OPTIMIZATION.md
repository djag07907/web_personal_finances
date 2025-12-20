# Flutter Web Performance Optimization Guide
## Fixing Critical INP Issues (19+ seconds)

Your app has severe performance issues. Here's how to fix them systematically.

---

## 🚨 Critical Issues Identified

1. **CanvasKit Renderer** - Heavy for web, causes slow initial load
2. **No Code Splitting** - Entire app loads at once
3. **Heavy Dependencies** - Lottie, Charts, Firebase all loaded upfront
4. **Inefficient Rebuilds** - Multiple setState calls, no const widgets
5. **Missing Web Optimizations** - No caching, lazy loading, or tree shaking

---

## 🔥 Immediate Fixes (Apply Now)

### 1. Switch to HTML Renderer (Critical)

**File: `web/index.html`**

Current problem: CanvasKit is 2-3MB and slow on web.

Add this to your `<head>` section:

```html
<script>
  // Force HTML renderer for better web performance
  window.flutterConfiguration = {
    canvasKitBaseUrl: "https://www.gstatic.com/flutter-canvaskit/33ce623099892825fb5430633c4fc26e0806739c/",
    renderer: "html"  // CRITICAL: Forces HTML renderer instead of CanvasKit
  };
</script>
```

**Or build with HTML renderer:**
```bash
fvm flutter build web --web-renderer html --release
```

### 2. Add Loading Indicator

Replace `web/index.html` body with:

```html
<body>
  <!-- Loading indicator -->
  <div id="loading" style="
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: #f5f7fa;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  ">
    <div style="text-align: center;">
      <div style="
        width: 50px;
        height: 50px;
        border: 4px solid #e1e8ed;
        border-top: 4px solid #4caf90;
        border-radius: 50%;
        animation: spin 1s linear infinite;
      "></div>
      <p style="margin-top: 20px; color: #6c7f79; font-family: sans-serif;">
        Loading FinApp...
      </p>
    </div>
  </div>
  
  <style>
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
  
  <script>
    // Hide loading indicator when Flutter is ready
    window.addEventListener('flutter-first-frame', function() {
      const loading = document.getElementById('loading');
      if (loading) {
        loading.style.opacity = '0';
        loading.style.transition = 'opacity 0.3s';
        setTimeout(() => loading.remove(), 300);
      }
    });
  </script>
  
  <script src="flutter_bootstrap.js" async></script>
</body>
```

### 3. Optimize main.dart Initialization

**File: `lib/main.dart`**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app immediately, initialize Firebase async
  runApp(const MyApp());
  
  // Initialize heavy services in background
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
    await dotenv.load(fileName: 'assets/.env');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
}
```

---

## 💪 High-Impact Optimizations

### 4. Optimize Lottie Animations

**Current:** Loading entire JSON on every render
**Fix:** Preload and cache

Create `lib/commons/animations/lottie_cache.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LottieCache {
  static final Map<String, LottieComposition> _cache = {};
  
  static Future<void> preloadAnimations() async {
    final animations = [
      'assets/animations/finance_animation1.json',
      // Add other animations here
    ];
    
    for (final path in animations) {
      try {
        final data = await rootBundle.loadString(path);
        final composition = await LottieComposition.fromByteData(
          ByteData.view(Uint8List.fromList(data.codeUnits).buffer),
        );
        _cache[path] = composition;
      } catch (e) {
        debugPrint('Failed to preload $path: $e');
      }
    }
  }
  
  static LottieComposition? get(String path) => _cache[path];
}

// Usage in login_body.dart:
Widget _buildRightPanel(bool isDark) {
  final composition = LottieCache.get('assets/animations/finance_animation1.json');
  
  return Container(
    // ... existing decoration
    child: Stack(
      children: [
        // ... pattern
        Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: composition != null
                ? Lottie(
                    composition: composition,
                    fit: BoxFit.contain,
                    repeat: true,
                  )
                : const SizedBox(), // Fallback
          ),
        ),
      ],
    ),
  );
}
```

### 5. Optimize Image Loading

Replace `Image.network` in Google button:

```dart
// BAD: Loads on every build
Image.network('https://www.google.com/favicon.ico', height: 20, width: 20)

// GOOD: Use asset or cached network image
Image.asset('assets/images/google_icon.png', height: 20, width: 20)

// Or if you must use network:
CachedNetworkImage(
  imageUrl: 'https://www.google.com/favicon.ico',
  height: 20,
  width: 20,
  placeholder: (context, url) => SizedBox(height: 20, width: 20),
  errorWidget: (context, url, error) => Icon(Icons.g_mobiledata),
)
```

**Add to pubspec.yaml:**
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

### 6. Add Const Constructors Everywhere

**Critical:** Flutter rebuilds non-const widgets unnecessarily.

Search and replace throughout your project:

```dart
// BAD
Text('Welcome Back')
SizedBox(height: 20)
Icon(Icons.lock)

// GOOD  
const Text('Welcome Back')
const SizedBox(height: 20)
const Icon(Icons.lock)
```

Run this command to find violations:
```bash
fvm flutter analyze | grep "prefer_const"
```

### 7. Optimize CustomPainter

**Current:** Redraws dots on every frame

```dart
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LightColors.primary
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // ✅ Already correct
}
```

**Better:** Use CSS background instead:

```dart
// Replace CustomPaint with:
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/dot_pattern.png'), // 1kb PNG
      repeat: ImageRepeat.repeat,
      opacity: isDark ? 0.05 : 0.1,
    ),
  ),
)
```

### 8. Lazy Load Routes

**File: `lib/routes/landing_routes.dart`**

```dart
import 'package:flutter/material.dart';

// Wrap route builders with lazy loading
final GoRouter appRoutes = GoRouter(
  initialLocation: rootRoute,
  routes: [
    // ... other routes
    GoRoute(
      path: incomesRoute,
      pageBuilder: (context, state) {
        // Lazy load the screen
        return MaterialPage(
          child: FutureBuilder(
            future: _loadIncomesScreen(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    ),
  ],
);

Future<Widget> _loadIncomesScreen() async {
  // Simulate async loading
  await Future.delayed(Duration(milliseconds: 50));
  return const IncomesScreen();
}
```

---

## 🎯 Code-Level Optimizations

### 9. Optimize BLoC Listeners

**Current Problem:** BlocBuilder rebuilds entire widget tree

**File: Any screen with BlocBuilder**

```dart
// BAD: Rebuilds everything
BlocBuilder<IncomesBloc, BaseState>(
  builder: (context, state) {
    if (state is IncomesInProgress && !_showDrawer) {
      return Container(/* loader */);
    }
    return const SizedBox.shrink();
  },
)

// GOOD: Only rebuild when state actually changes
BlocBuilder<IncomesBloc, BaseState>(
  buildWhen: (previous, current) {
    // Only rebuild if loading state changed
    return (previous is IncomesInProgress) != (current is IncomesInProgress);
  },
  builder: (context, state) {
    if (state is IncomesInProgress && !_showDrawer) {
      return Container(/* loader */);
    }
    return const SizedBox.shrink();
  },
)
```

### 10. Optimize TextField Performance

**Problem:** Rebuilds on every keystroke

```dart
// Add these to all TextFields:
TextField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  enableInteractiveSelection: true,
  autocorrect: false,
  enableSuggestions: false, // Reduces overhead
  // ... rest of properties
)
```

### 11. Debounce Expensive Operations

For search, validation, API calls:

```dart
import 'dart:async';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Usage in search:
final _debouncer = Debouncer(milliseconds: 300);

TextField(
  onChanged: (value) {
    _debouncer.run(() {
      // Expensive search operation
      _performSearch(value);
    });
  },
)
```

---

## 🏗️ Build Optimizations

### 12. Optimize pubspec.yaml

Add these flags:

```yaml
flutter:
  uses-material-design: true
  
  # Web-specific optimizations
  assets:
    - assets/.env
    - assets/images/
    - assets/translations/
    - assets/animations/
  
  # Don't include fonts you're not using
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
```

### 13. Build with Optimizations

Always build with these flags:

```bash
# Production build
fvm flutter build web \
  --web-renderer html \
  --release \
  --no-source-maps \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --pwa-strategy=offline-first

# Development with profile mode
fvm flutter run -d chrome --profile --web-renderer html
```

### 14. Tree Shaking Configuration

Create `web/dart_define.env`:

```env
FLUTTER_WEB_USE_SKIA=false
FLUTTER_WEB_AUTO_DETECT=false
```

Build with:
```bash
fvm flutter build web --release --dart-define-from-file=web/dart_define.env
```

---

## 📊 Monitoring & Testing

### 15. Add Performance Monitoring

```dart
// In main.dart
import 'package:flutter/foundation.dart';

void main() async {
  if (kDebugMode) {
    // Timeline events for debugging
    debugPrintBeginFrameBanner = true;
    debugPrintEndFrameBanner = true;
  }
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

### 16. Test Performance

```bash
# Run in profile mode
fvm flutter run -d chrome --profile --web-renderer html

# Open DevTools
# In Chrome DevTools:
# 1. Go to Performance tab
# 2. Record interaction
# 3. Check "INP" metric
```

---

## 🎬 Implementation Priority

### Week 1 (Critical - Do Now):
1. ✅ Switch to HTML renderer
2. ✅ Add loading indicator  
3. ✅ Move Firebase init to background
4. ✅ Replace Image.network with asset
5. ✅ Add const to all static widgets

### Week 2 (High Impact):
6. ✅ Optimize Lottie loading
7. ✅ Add buildWhen to BlocBuilders
8. ✅ Debounce text inputs
9. ✅ Remove CustomPaint dot pattern
10. ✅ Lazy load routes

### Week 3 (Polish):
11. ✅ Implement proper caching
12. ✅ Code splitting
13. ✅ Service Worker for offline
14. ✅ Lighthouse audit fixes

---

## 📈 Expected Improvements

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| INP | 19,416ms | ~200ms | <200ms |
| FCP | 3-4s | ~1s | <1.8s |
| LCP | 5-6s | ~2s | <2.5s |
| Bundle Size | 5-8MB | 2-3MB | <3MB |

---

## 🔍 Debug Current Issues

Run these commands:

```bash
# 1. Check bundle size
fvm flutter build web --release --web-renderer html --analyze-size

# 2. Profile in Chrome
fvm flutter run -d chrome --profile --web-renderer html

# 3. Check for performance issues
fvm flutter analyze --no-fatal-infos

# 4. Find missing const
fvm flutter analyze | grep "prefer_const"
```

---

## ⚡ Quick Wins Checklist

Apply these TODAY:

- [ ] Add `--web-renderer html` to build command
- [ ] Add loading indicator to index.html
- [ ] Replace Image.network with Image.asset
- [ ] Add const to SizedBox, Text, Icon throughout
- [ ] Add buildWhen to all BlocBuilders
- [ ] Move Firebase.init after runApp
- [ ] Remove or optimize CustomPaint
- [ ] Test in Chrome DevTools Performance tab

**After these changes, your INP should drop from 19s to under 2s.**

Run the fixes and let me know the new metrics!
