import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Release metadata — keep in sync with web/version.json and the app's
// pubspec.yaml. Bump all three when publishing a new build.
// ---------------------------------------------------------------------------
const String kAppName = 'WakeUp & Earn';
const String kAppVersion = '1.0.4';
const String kApkFile = 'downloads/wakeup-earn-v1.0.4.apk';
const String kApkSizeLabel = 'Android · APK';
const String kDeveloper = 'Dev. Swapnil Biswas';

const Color _ink = Color(0xFF2A141B);
const Color _muted = Color(0xFF8A6E76);
const Color _amber = Color(0xFFFFA531);
const Color _coral = Color(0xFFFF4D6D);
const Color _tagText = Color(0xFFB26A00);

void main() => runApp(const DownloadSite());

class DownloadSite extends StatelessWidget {
  const DownloadSite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF7F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _amber,
          brightness: Brightness.light,
        ),
      ),
      home: const DownloadPage(),
    );
  }
}

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  /// `kApkFile` is a site-relative path ("downloads/…apk"). `Uri.parse` on a
  /// relative path yields a URI with no scheme or host, which `launchUrl`
  /// silently refuses on web — resolving against `Uri.base` first is what
  /// makes the button work.
  Future<void> _download(BuildContext context) async {
    final uri = Uri.base.resolve(kApkFile);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download could not start. Open $uri manually.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 620;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7F3), Color(0xFFFFE6D9), Color(0xFFFFF3D6)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: narrow ? 120.0 : 148.0,
                      height: narrow ? 120.0 : 148.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    kAppName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ঘুম ভাঙাও, টাকা কামাও।\nGet paid to wake someone up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.5, color: _muted),
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _download(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: _coral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 22),
                      label: const Text(
                        'Download app',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Tag(label: 'v$kAppVersion'),
                      const SizedBox(width: 8),
                      _Tag(label: kApkSizeLabel),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1F2A141B)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Install note',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: _ink),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Android may ask for permission to install apps from '
                          'unknown sources. Allow it for your browser, then open '
                          'the downloaded file.',
                          style: TextStyle(
                              fontSize: 12.5, height: 1.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    kDeveloper,
                    style:
                        TextStyle(fontSize: 12, color: _muted.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x40FFA531)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _tagText,
        ),
      ),
    );
  }
}
