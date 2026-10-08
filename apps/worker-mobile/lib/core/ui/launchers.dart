import 'package:url_launcher/url_launcher.dart';

/// Opens navigation to a point. `geo:` lets Android offer Google Maps,
/// Yandex Navigator, etc.; falls back to Google Maps on the web.
Future<bool> openNavigation(double lat, double lng, String label) async {
  final geo = Uri.parse(
    'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label)})',
  );
  try {
    if (await launchUrl(geo, mode: LaunchMode.externalApplication)) return true;
  } on Object {
    // fall through
  }
  return launchUrl(
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$lat,$lng',
    }),
    mode: LaunchMode.externalApplication,
  );
}

Future<bool> callPhone(String phone) =>
    launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));
