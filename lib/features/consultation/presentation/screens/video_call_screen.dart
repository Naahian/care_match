import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/video_call_token.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../../providers.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  RtcEngine? _engine;
  VideoCallToken? _session;
  RtcConnection? _remoteConnection;
  int? _remoteUid;
  bool _isJoining = true;
  bool _isJoined = false;
  bool _isEnding = false;
  bool _isStarting = true;
  String? _errorMessage;
  late final RtcEngineEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _eventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (_, _) {
        if (mounted) setState(() => _isJoined = true);
      },
      onUserJoined: (connection, uid, _) {
        if (mounted) {
          setState(() {
            _remoteConnection = connection;
            _remoteUid = uid;
          });
        }
      },
      onUserOffline: (_, uid, _) {
        if (mounted && _remoteUid == uid) {
          setState(() {
            _remoteConnection = null;
            _remoteUid = null;
          });
        }
      },
      onPermissionError: (_) {
        if (mounted) {
          setState(
            () => _errorMessage =
                'Camera or microphone permission is required for video calls.',
          );
        }
      },
      onError: (_, _) {
        if (mounted) {
          setState(
            () => _errorMessage =
                'A video connection error occurred. Please try again.',
          );
        }
      },
    );
    unawaited(_startCall());
  }

  Future<void> _startCall() async {
    try {
      if (AppConstants.agoraAppId.trim().isEmpty) {
        throw const _VideoCallConfigurationException(
          'Add the Agora App ID to AppConstants.agoraAppId before joining.',
        );
      }
      if (!_supportsAgora) {
        throw const _VideoCallConfigurationException(
          'Video consultations are not supported on this platform.',
        );
      }

      final session = await ref
          .read(videoCallRepositoryProvider)
          .getToken(widget.appointmentId);
      if (!mounted) return;
      _session = session;

      final engine = createAgoraRtcEngine();
      _engine = engine;
      await engine.initialize(
        RtcEngineContext(
          appId: AppConstants.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
      if (!mounted) return;

      engine.registerEventHandler(_eventHandler);
      await engine.enableVideo();
      await engine.enableAudio();
      await engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.startPreview();
      if (!mounted) return;
      setState(() => _isJoining = false);

      await engine.joinChannel(
        token: session.token,
        channelId: session.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
    } on _VideoCallConfigurationException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } on VideoCallException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (error, stackTrace) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Could not start the video consultation. Please try again.',
        );
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'video consultation',
        ),
      );
      await _releaseEngine(reportErrors: true);
    } finally {
      _isStarting = false;
      if (!mounted) {
        await _releaseEngine(reportErrors: true);
      }
      if (mounted) setState(() => _isJoining = false);
    }
  }

  bool get _supportsAgora =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.windows => true,
        _ => false,
      };

  Future<void> _endCall() async {
    if (_isEnding) return;
    if (_isStarting) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isEnding = true);
    Object? cleanupError;
    try {
      await _releaseEngine();
    } catch (error, stackTrace) {
      cleanupError = error;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'video consultation',
          context: ErrorDescription('while ending the video call'),
        ),
      );
    }
    if (!mounted) return;
    if (cleanupError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The call ended with a cleanup error.')),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _releaseEngine({bool reportErrors = false}) async {
    final engine = _engine;
    _engine = null;
    if (engine == null) return;

    Object? cleanupError;
    StackTrace? cleanupStack;
    try {
      engine.unregisterEventHandler(_eventHandler);
      await engine.leaveChannel();
    } catch (error, stackTrace) {
      cleanupError = error;
      cleanupStack = stackTrace;
    } finally {
      try {
        await engine.release();
      } catch (error, stackTrace) {
        cleanupError ??= error;
        cleanupStack ??= stackTrace;
      }
    }
    if (cleanupError != null) {
      if (reportErrors) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: cleanupError,
            stack: cleanupStack,
            library: 'video consultation',
          ),
        );
      } else {
        Error.throwWithStackTrace(cleanupError, cleanupStack!);
      }
    }
  }

  @override
  void dispose() {
    if (!_isStarting) {
      unawaited(_releaseEngine(reportErrors: true));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final engine = _engine;
    final remoteUid = _remoteUid;
    print(widget.appointmentId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text('Video consultation · ${widget.appointmentId}'),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (engine != null && session != null && remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: remoteUid),
                  connection: _remoteConnection!,
                ),
              )
            else if (engine != null && session != null && !_isJoining)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            else
              Center(
                child: _errorMessage == null
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            if (_errorMessage == null && remoteUid == null && !_isJoining)
              Center(
                child: Card(
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Text(
                      _isJoined
                          ? 'Waiting for the other user to join…'
                          : 'Connecting to the consultation…',
                    ),
                  ),
                ),
              ),
            if (_errorMessage != null)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Text(_errorMessage!),
                  ),
                ),
              ),
            if (engine != null &&
                session != null &&
                remoteUid != null &&
                _remoteConnection != null)
              Positioned(
                right: AppSpacing.md,
                top: AppSpacing.md,
                width: 120,
                height: 180,
                child: ClipRRect(
                  borderRadius: AppRadius.card,
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Center(
                child: FilledButton.icon(
                  onPressed: _isEnding ? null : _endCall,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: _isEnding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.call_end_rounded),
                  label: Text(_isEnding ? 'Ending…' : 'End call'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCallConfigurationException implements Exception {
  const _VideoCallConfigurationException(this.message);

  final String message;
}
