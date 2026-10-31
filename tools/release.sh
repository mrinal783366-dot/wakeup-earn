#!/usr/bin/env bash
# Publish a new WakeUp & Earn release.
#
#   bash tools/release.sh 1.0.2
#
# Does, in order:
#   1. Bump pubspec.yaml (build number auto-increments).
#   2. Bump the download site's version constants.
#   3. Build the arm64 release APK.
#   4. Copy it into site/web/downloads/.
#   5. Regenerate site/web/version.json (this is what forces the in-app update).
#   6. Rebuild the Flutter download site into site/build/web.
#
# Then deploy manually:
#   npm i -g vercel
#   cd site/build/web
#   vercel deploy --prod --yes --name wakeup-earn
#
# The app reads https://wakeup-earn.vercel.app/version.json at startup and
# shows a non-dismissible update dialog whenever the published version is
# greater than its own.

set -euo pipefail

VER="${1:-}"
if [[ -z "$VER" ]]; then
  echo "usage: bash tools/release.sh <version>   e.g. 1.0.2" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SITE_URL="https://wakeup-earn.vercel.app"
APK_NAME="wakeup-earn-v${VER}.apk"

# --- build number: take the current one and add 1 ---------------------------
CURRENT="$(grep -m1 '^version:' pubspec.yaml | sed 's/^version:[[:space:]]*//')"
BASE="${CURRENT%%+*}"
BUILD="${CURRENT##*+}"
[[ "$BUILD" == "$CURRENT" ]] && BUILD=1
BUILD=$((BUILD + 1))
echo "version: $CURRENT -> $VER+$BUILD"

# --- 1. app version ---------------------------------------------------------
sed -i "s/^version: .*/version: ${VER}+${BUILD}/" pubspec.yaml

# --- 2. site constants ------------------------------------------------------
sed -i "s/^const String kAppVersion = '.*';/const String kAppVersion = '${VER}';/" site/lib/main.dart
sed -i "s|^const String kApkFile = '.*';|const String kApkFile = 'downloads/${APK_NAME}';|" site/lib/main.dart

# --- 3. APK -----------------------------------------------------------------
echo "building APK…"
flutter build apk --release --target-platform android-arm64
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
[[ -f "$APK_SRC" ]] || APK_SRC="$(ls build/app/outputs/flutter-apk/*.apk | head -1)"

# --- 4. stage it ------------------------------------------------------------
mkdir -p site/web/downloads
rm -f site/web/downloads/*.apk
cp "$APK_SRC" "site/web/downloads/${APK_NAME}"
SIZE="$(du -h "site/web/downloads/${APK_NAME}" | cut -f1)"
echo "staged $APK_NAME ($SIZE)"

# --- 5. update manifest -----------------------------------------------------
cat > site/web/version.json <<JSON
{
  "version": "${VER}",
  "build": ${BUILD},
  "force": true,
  "url": "${SITE_URL}/downloads/${APK_NAME}",
  "notes": "নতুন ভার্সন ${VER} — আপডেট করে নাও।"
}
JSON
echo "wrote site/web/version.json"

# --- 6. site ----------------------------------------------------------------
echo "building site…"
(cd site && flutter build web --release)

# --- 7. refresh the deploy/ git working tree --------------------------------
# deploy/ is what Vercel serves: its ROOT is the built site, so index.html sits
# at the top level and Vercel needs no build command.
echo "syncing deploy/ …"
# NOTE: copy over the existing tree instead of deleting it — a bulk `rm -rf`
# on deploy/ trips bulk-deletion safety guards.
mkdir -p deploy/downloads deploy/site deploy/tools
cp -R site/build/web/. deploy/
cp -R site/lib site/pubspec.yaml site/web site/assets deploy/site/
cp tools/release.sh deploy/tools/
cp site/deploy_README.md deploy/README.md
# Debug symbols are dead weight; binaries are not duplicated under site/.
find deploy -name "*.symbols" -delete
find deploy/site/web/downloads -name "*.apk" -delete 2>/dev/null || true
# Keep only the current APK in the published download folder.
find deploy/downloads -name "*.apk" ! -name "${APK_NAME}" -delete
cp "site/web/downloads/${APK_NAME}" "deploy/downloads/${APK_NAME}"
du -sh deploy

cat <<NOTE

Staged. Now publish:

  cd deploy
  git add -A && git commit -m "Release ${VER}"
  git push origin main        # Vercel redeploys automatically

Force update goes live with the deploy — the app compares its version with
${SITE_URL}/version.json on every launch.
NOTE
