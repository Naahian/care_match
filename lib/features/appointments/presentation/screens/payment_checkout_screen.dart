import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/payment_checkout.dart';

bool get supportsPaymentWebView =>
    !kIsWeb &&
    const {
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.url,
    required this.checkStatus,
  });
  final Uri url;
  final Future<PaymentCheckout?> Function() checkStatus;
  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  WebViewController? _web;
  Timer? _timer;
  bool _checking = false, _done = false;
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      final web = WebViewController();
      await web.setJavaScriptMode(JavaScriptMode.unrestricted);
      await web.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageFinished: (_) => unawaited(_check()),
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(
                () => _error =
                    'Could not load checkout. Check payment status before retrying.',
              );
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            return uri != null && uri.scheme == 'https'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );
      if (!mounted) return;
      setState(() => _web = web);
      // No Firebase bearer token is sent to the payment provider.
      await web.loadRequest(widget.url);
      if (!mounted) return;
      _timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => unawaited(_check()),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open checkout on this device.');
      }
    }
  }

  Future<void> _check() async {
    if (_checking || _done || !mounted) return;
    _checking = true;
    try {
      final payment = await widget.checkStatus();
      if (!mounted || _done) return;
      if (payment?.isTerminal == true) {
        _done = true;
        Navigator.of(context).pop(payment!.isPaid);
      } else {
        setState(
          () => _error = payment == null
              ? 'Could not verify payment yet. You can check again.'
              : null,
        );
      }
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Secure payment'),
      actions: [
        TextButton(onPressed: _check, child: const Text('Check status')),
      ],
    ),
    body: Column(
      children: [
        if (_progress < 100 && _error == null)
          LinearProgressIndicator(value: _progress / 100),
        if (_error != null)
          MaterialBanner(
            content: Text(_error!),
            actions: [
              TextButton(
                onPressed: () => _web?.reload(),
                child: const Text('Reload'),
              ),
            ],
          ),
        if (_web != null) Expanded(child: WebViewWidget(controller: _web!)),
      ],
    ),
  );
}
