import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/patient_record.dart';

class RecordViewer extends StatefulWidget {
  const RecordViewer({super.key, required this.record});
  final PatientRecord record;
  @override
  State<RecordViewer> createState() => _RecordViewerState();
}

class _RecordViewerState extends State<RecordViewer> {
  // Signed storage URLs do not need the API bearer token.
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      followRedirects: false,
    ),
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _dio.close(force: true);
    super.dispose();
  }

  Future<void> _download() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (!widget.record.expiresAt.isAfter(DateTime.now())) {
        throw StateError('Expired link');
      }
      final response = await _dio.get<List<int>>(
        widget.record.downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      final filename = widget.record.filename.replaceAll(
        RegExp(r'[/\\\x00-\x1f]'),
        '_',
      );
      if (!mounted) return;
      final saver = FileSaver.instance;
      final result = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux
          ? await saver.saveFile(
              name: filename,
              bytes: bytes,
              includeExtension: false,
              mimeType: MimeType.custom,
              customMimeType: widget.record.contentType,
            )
          : await saver.saveAs(
              name: filename,
              bytes: bytes,
              includeExtension: false,
              mimeType: MimeType.custom,
              customMimeType: widget.record.contentType,
            );
      if (!mounted) return;
      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record saved.')));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not download. Close this window and refresh records to try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * .8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.record.filename,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: widget.record.isImage
                  ? InteractiveViewer(
                      minScale: .5,
                      maxScale: 5,
                      child: Center(
                        child: Image.network(
                          widget.record.downloadUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          errorBuilder: (_, _, _) => const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Could not load image. Close this window and refresh records to try again.',
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Preview is available for images. Download this file to view it.',
                        ),
                      ),
                    ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _saving ? null : _download,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_saving ? 'Downloading…' : 'Download'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
