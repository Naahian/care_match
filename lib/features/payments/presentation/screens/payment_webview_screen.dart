import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../doctors/presentation/widgets/doctor_profile.dart';
import '../controllers/payment_checkout_controller.dart';
import '../models/payment_checkout_session.dart';
import '../widgets/payment_status_content.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, this.session});
  final PaymentCheckoutSession? session;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  WebViewController? _webView;
  PaymentCheckoutController? _payment;
  int _progress = 0;
  Uri? _mainFrameUrl;
  String? _loadError;
  bool _returnReached = false;
  bool _allowLeave = false;
  bool _askingToLeave = false;
  bool _finished = false;

  bool get _supported =>
      !kIsWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    if (session != null) {
      _payment = PaymentCheckoutController(session);
      if (_supported) _initializeWebView();
    }
  }

  Future<void> _initializeWebView() async {
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _mainFrameUrl = Uri.tryParse(url);
            _checkReturnUrl(url);
          },
          onUrlChange: (change) => _checkReturnUrl(change.url),
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onNavigationRequest: (request) {
            final url = Uri.tryParse(request.url);
            final session = widget.session!;
            if (url == null) return NavigationDecision.prevent;
            if (request.isMainFrame && session.isReturnUrl(url)) {
              _verifyPayment();
              return NavigationDecision.prevent;
            }
            if (!session.allowsNavigation(url)) {
              if (request.isMainFrame && mounted) {
                setState(
                  () => _loadError =
                      'This payment page couldn’t be opened. Please check your payment method and try again.',
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(
                () => _loadError =
                    'We couldn’t load checkout. Check your connection and reload the page.',
              );
            }
          },
          onHttpError: (error) {
            if (mounted &&
                error.request?.uri == _mainFrameUrl &&
                _mainFrameUrl != null) {
              setState(
                () => _loadError =
                    'The payment provider couldn’t load this checkout. Please reload the page.',
              );
            }
          },
        ),
      );
      if (!mounted) return;
      setState(() => _webView = controller);
      await controller.loadRequest(widget.session!.checkoutUrl);
    } catch (_) {
      if (mounted) {
        setState(
          () => _loadError = 'Checkout couldn’t be opened. Please try again.',
        );
      }
    }
  }

  void _checkReturnUrl(String? value) {
    final url = value == null ? null : Uri.tryParse(value);
    if (url != null && widget.session!.isReturnUrl(url)) _verifyPayment();
  }

  Future<void> _reload() async {
    setState(() {
      _loadError = null;
      _progress = 0;
    });
    final controller = _webView;
    if (controller == null) {
      await _initializeWebView();
    } else {
      try {
        await controller.loadRequest(widget.session!.checkoutUrl);
      } catch (_) {
        if (mounted) {
          setState(
            () => _loadError =
                'Checkout couldn’t be loaded. Please check your connection.',
          );
        }
      }
    }
  }

  Future<void> _verifyPayment() async {
    final payment = _payment;
    if (!mounted || payment == null || payment.verifying || _finished) return;
    setState(() => _returnReached = true);
    await payment.verify();
    if (!mounted || _finished) return;
    final result = payment.verification;
    if (result?.status == PaymentStatus.succeeded) {
      _finished = true;
      context.pushReplacementNamed(
        AppRoutes.appointmentConfirmation,
        pathParameters: {
          'doctorId': doctorProfileId(
            widget.session!.appointmentDraft.doctor.summary.name,
          ),
        },
        extra: widget.session!.appointmentDraft,
      );
    } else if (result?.status == PaymentStatus.failed) {
      _finished = true;
      context.pushReplacementNamed(
        AppRoutes.paymentFailed,
        extra: PaymentFailure(
          message: result!.message ?? const PaymentFailure().message,
          session: widget.session,
        ),
      );
    }
  }

  Future<void> _leaveCheckout() async {
    if (_askingToLeave) return;
    _askingToLeave = true;
    final leave = widget.session == null || !_supported
        ? true
        : await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Leave checkout?'),
              content: const Text(
                'Leaving checkout does not cancel a payment that has already been submitted.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Leave checkout'),
                ),
              ],
            ),
          );
    _askingToLeave = false;
    if (leave != true || !mounted) return;
    setState(() => _allowLeave = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _payment?.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    final session = widget.session;
    if (session == null || !_supported) {
      return PaymentStatusContent(
        icon: Icons.account_balance_wallet_outlined,
        title: session == null
            ? 'Checkout is not ready yet'
            : 'Use a supported device',
        message: session == null
            ? 'Your payment provider’s checkout will appear here once a payment session is available.'
            : 'In-app checkout is available on Android, iOS, and macOS.',
        actionLabel: 'Back to Home',
        onAction: () => context.goNamed(AppRoutes.home),
      );
    }
    final payment = _payment!;
    if (_returnReached) {
      return ListenableBuilder(
        listenable: payment,
        builder: (context, _) => PaymentStatusContent(
          icon: Icons.hourglass_top_rounded,
          title: payment.verifying
              ? 'Confirming your payment'
              : 'Payment confirmation pending',
          message: payment.verifying
              ? 'Please wait while we check your payment status.'
              : payment.verification?.message ??
                    'Your payment is still processing. Check its status before trying to pay again.',
          actionLabel: 'Check payment status',
          onAction: _verifyPayment,
          busy: payment.verifying,
          secondaryAction: TextButton(
            onPressed: _leaveCheckout,
            child: const Text('Leave checkout'),
          ),
        ),
      );
    }
    if (_loadError != null) {
      return PaymentStatusContent(
        icon: Icons.wifi_off_rounded,
        title: 'Checkout couldn’t load',
        message: _loadError!,
        actionLabel: 'Reload checkout',
        onAction: _reload,
        isError: true,
        secondaryAction: TextButton(
          onPressed: _leaveCheckout,
          child: const Text('Leave checkout'),
        ),
      );
    }
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: AppSpacing.card,
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pay ${session.amount} with ${session.provider}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
            ),
          Expanded(
            child: _webView == null
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: _webView!),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowLeave,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _leaveCheckout();
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Secure checkout'),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Leave checkout',
          onPressed: _leaveCheckout,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: _body(context),
    ),
  );
}
