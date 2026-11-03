#!/usr/bin/env bash
set -e

echo "🚀 Compiling Pecunia for production..."
fvm flutter build web --release --pwa-strategy=none --no-source-maps

echo "📦 Injecting Vercel configuration..."
cp vercel.json build/web/vercel.json

if [ -f ".vercel/project.json" ]; then
  mkdir -p build/web/.vercel
  cp .vercel/project.json build/web/.vercel/project.json
  echo "🔗 Linked Vercel project configuration copied."
else
  echo "ℹ️  Note: .vercel/project.json not found yet. Run 'npx vercel link' once from project root to link your Vercel project."
fi

echo "🌐 Deploying to Vercel Production..."
npx vercel build/web --prod --yes

echo "🤘 Pecunia deployment complete!"

