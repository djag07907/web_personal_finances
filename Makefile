.PHONY: letsrock dev clean

letsrock:
	@echo "🚀 Building Pecunia for production..."
	fvm flutter build web --release --pwa-strategy=none --no-source-maps
	@echo "✅ Production build complete in build/web/"

dev:
	@echo "🔧 Starting Pecunia in dev mode..."
	fvm flutter run -d chrome --web-renderer html

clean:
	@echo "🧹 Cleaning build artifacts..."
	fvm flutter clean
	fvm flutter pub get
	@echo "✅ Clean complete."
