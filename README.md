# WakeUp & Earn — download site

Static site hosted on Vercel at **https://wakeup-earn.vercel.app**. Its only job
is to hand out the Android APK.

## Layout

| Path | What it is |
| --- | --- |
| `index.html`, `main.dart.js`, `canvaskit/` | Built Flutter web app (the page itself) |
| `downloads/*.apk` | The Android build users download |
| `version.json` | Update manifest read by the app on every launch |
| `site/` | Flutter source of the download site |
| `tools/release.sh` | Release script: bump → build APK → stage → rebuild site |

## How the in-app force update works

The app fetches `https://wakeup-earn.vercel.app/version.json` at startup and
compares it with its own `pubspec.yaml` version:

```json
{
  "version": "1.0.1",
  "build": 2,
  "force": true,
  "url": "https://wakeup-earn.vercel.app/downloads/wakeup-earn-v1.0.1.apk",
  "notes": "..."
}
```

A newer published version shows a non-dismissible dialog (`force: true`) with an
**আপডেট করো** button that opens `url`. Any failure — offline, malformed JSON,
unreachable host — is treated as "no update", so a broken manifest can never
lock a user out.

## Publishing a new version

```bash
bash tools/release.sh 1.0.2        # bumps versions, builds APK, rebuilds site
# then commit everything under this repo's root and push — Vercel redeploys
```

Keep three numbers in sync: app `pubspec.yaml`, `site/lib/main.dart`
(`kAppVersion` / `kApkFile`), and `version.json`. `tools/release.sh` does all
three.
