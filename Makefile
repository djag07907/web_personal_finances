.PHONY: build deploy letsrock dev clean

build:
	@echo "🚀 Compiling Pecunia for production..."
	fvm flutter build web --release --pwa-strategy=none --no-source-maps
	@echo "📦 Injecting Vercel configuration..."
	cp vercel.json build/web/vercel.json
	@if [ -f ".vercel/project.json" ]; then \
		mkdir -p build/web/.vercel && cp .vercel/project.json build/web/.vercel/project.json; \
		echo "🔗 Linked Vercel project configuration copied."; \
	else \
		echo "ℹ️  Note: .vercel/project.json not found yet. Run 'npx vercel link' once to link this repository to your Vercel project."; \
	fi
	@echo "✅ Production build ready in build/web/"

deploy: build
	@echo "🌐 Deploying Pecunia to Vercel Production..."
	npx vercel build/web --prod --yes
	@echo "🤘 Deployment complete!"

letsrock: deploy

dev:
	@echo "🔧 Starting Pecunia in dev mode..."
	fvm flutter run -d chrome

clean:
	@echo "🧹 Cleaning build artifacts..."
	fvm flutter clean
	fvm flutter pub get
	@echo "✅ Clean complete."
