# Deploying Pecunia to Vercel with Hostinger Subdomain

This guide covers deploying **Pecunia (web_personal_finances)** to **Vercel** with a custom subdomain managed on **Hostinger** (following the architecture used in `vaeltryx`).

---

## 🏗️ Architecture Overview

```
[ User Browser ]
       │
       ▼
[ Hostinger DNS ]
  (CNAME: subdomain.yourdomain.com ➔ cname.vercel-dns.com)
       │
       ▼
[ Vercel Edge Network ]
  ├── vercel.json (SPA rewrites: /* ➔ /index.html)
  └── Static bundle (build/web: canvaskit, main.dart.js, assets)
       │
       ▼
[ Client-side Execution ]
  ├── Zero-Knowledge AES-GCM Client Decryption
  └── Firebase Services (Auth, Firestore, App Check)
```

---

## 🚀 One-Command Deployment

You can compile and deploy directly using either of the following commands:

```bash
make letsrock
```

or

```bash
./deploy.sh
```

### What This Command Does:

1. **Compiles Flutter Web**: Runs `fvm flutter build web --release --pwa-strategy=none --no-source-maps`.
2. **Injects SPA Rewrites**: Copies `vercel.json` into `build/web/vercel.json` so direct routes (`/terms`, `/privacy`, `/incomes`, etc.) don't trigger 404 errors on refresh.
3. **Preserves Project Association**: Copies `.vercel/project.json` into `build/web/.vercel/project.json` so Vercel updates the existing project rather than creating a new `web` project.
4. **Deploys to Vercel**: Runs `npx vercel build/web --prod --yes`.

---

## 📋 First-Time Setup Instructions

### Step 1: Link Vercel Project

If you have not yet linked this repository to a Vercel project:

1. In the project root, run:
   ```bash
   npx vercel link
   ```
2. Follow the interactive prompts:
   - **Set up and deploy?**: Yes
   - **Which scope?**: Select your personal or team account
   - **Link to existing project?**: Select No if creating a new one (e.g. name it `pecunia` or `web-personal-finances`), or Yes if you created it beforehand in the Vercel Dashboard.
3. This creates the `.vercel/project.json` file automatically.

---

### Step 2: Configure Subdomain in Hostinger DNS

1. Log in to your **Hostinger hPanel**.
2. Navigate to **Domains** and select your domain (e.g. `yourdomain.com`).
3. Click on **DNS / Nameservers** in the left sidebar.
4. Under **Manage DNS records**, add a new record:
   - **Type**: `CNAME`
   - **Name**: Your desired subdomain prefix (e.g. `finances`, `pecunia`, or `app`)
   - **Target / Points to**: `cname.vercel-dns.com.`
   - **TTL**: `300` (or default 14400)
5. Click **Add Record**.

---

### Step 3: Add Custom Domain in Vercel

1. Go to your [Vercel Dashboard](https://vercel.com/dashboard).
2. Open the **Pecunia** project.
3. Navigate to **Settings** > **Domains**.
4. Enter your full subdomain (e.g. `finances.yourdomain.com`) and click **Add**.
5. Vercel will automatically detect the CNAME record from Hostinger and issue a free SSL/TLS certificate (usually takes 1–5 minutes).

---

### Step 4: Authorize Domain in Firebase Authentication

Firebase Auth blocks sign-ins (Google Auth, email confirmation redirects) originating from unauthorized domains.

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your project.
3. Go to **Authentication** > **Settings** (tab) > **Authorized domains**.
4. Click **Add domain** and add:
   - Your custom subdomain: `finances.yourdomain.com`
   - Your Vercel production domain: `<your-project>.vercel.app`
5. Click **Done**.

---

### Step 5: Authorize Domain in App Check / reCAPTCHA v3 (If Active)

If you have Firebase App Check enabled with reCAPTCHA v3:

1. Open the [Google Cloud Console](https://console.cloud.google.com/) or [Google reCAPTCHA Admin](https://www.google.com/recaptcha/admin).
2. Find your reCAPTCHA v3 site key used for Pecunia.
3. Add `finances.yourdomain.com` and `<your-project>.vercel.app` to the allowed domains list.
4. Save changes.

---

## 🔄 Daily Workflow / Pushing Updates

Whenever you make code changes in `lib/` or update translations:

```bash
make letsrock
```

Your production site on the Hostinger subdomain will be updated live in under 40 seconds.
