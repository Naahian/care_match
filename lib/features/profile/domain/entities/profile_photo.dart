import 'dart:typed_data';

class ProfilePhoto {
  ProfilePhoto({required Uint8List bytes, required this.filename})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  final Uint8List bytes;
  final String filename;
  static const maxBytes = 5 * 1024 * 1024;
}
