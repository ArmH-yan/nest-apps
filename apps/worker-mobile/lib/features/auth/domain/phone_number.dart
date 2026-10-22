/// The phone as typed on the login screen → the stored form (same rules as the
/// API's `normalize_phone`, so mock and real logins agree).
///
/// Armenian numbers in any of their usual shapes become `+374XXXXXXXX`:
/// `+374 91 000 007`, `091 000 007`, `0 91   000007`, `37491000007`,
/// `00374 91 000 007`, `+374 091 000 007`. Spaces of any kind (including the
/// non-breaking ones messengers paste), dashes, dots, slashes and brackets are
/// ignored. Anything else is returned without separators; the server decides.
String normalizePhone(String raw) {
  final phone = raw.replaceAll(_separators, '');
  final local = _armenianLocal.firstMatch(phone);
  if (local != null) return '+374${local[1]}';
  final intl = _armenianIntl.firstMatch(phone);
  if (intl != null) return '+374${intl[1]}';
  return phone;
}

final _separators = RegExp(r'[\s   \-().\/]+');
final _armenianLocal = RegExp(r'^0([0-9]{8})$');
final _armenianIntl = RegExp(r'^(?:\+|00)?3740?([0-9]{8})$');
