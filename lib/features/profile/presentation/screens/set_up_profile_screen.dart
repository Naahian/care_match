import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/profile_photo.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../providers.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_edit_fields.dart';
import '../widgets/profile_personal_fields.dart';
import '../widgets/profile_photo_field.dart';

class SetUpProfileScreen extends ConsumerStatefulWidget {
  const SetUpProfileScreen({super.key, this.isEditProfile = true});

  final bool isEditProfile;

  @override
  ConsumerState<SetUpProfileScreen> createState() => _SetUpProfileScreenState();
}

class _SetUpProfileScreenState extends ConsumerState<SetUpProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  ProfilePhoto? _photo;
  bool _removePhoto = false;
  bool _isPickingPhoto = false;
  String? _photoError;
  int _photoRevision = 0;
  final _birth = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodGroup;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(profileControllerProvider, (_, next) {
      final profile = next.profile;
      if (profile == null) {
        _prefilled = false;
        _name.clear();
        _phone.clear();
        _photoRevision++;
        _photo = null;
        _removePhoto = false;
        _isPickingPhoto = false;
        _photoError = null;
        _setBirth(null);
        _gender = null;
        _bloodGroup = null;
      } else if (!_prefilled) {
        _prefilled = true;
        _name.text = profile.displayName ?? '';
        _phone.text = profile.phoneNumber ?? '';
        _setBirth(profile.dateOfBirth);
        _gender = profile.gender;
        _bloodGroup = profile.bloodGroup;
      }
    }, fireImmediately: true);
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(ref.read(profileControllerProvider.notifier).load());
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _photoRevision++;
    _birth.dispose();
    super.dispose();
  }

  void _setBirth(DateTime? date) {
    _dateOfBirth = date;
    _birth.text = date == null
        ? ''
        : '${date.year.toString().padLeft(4, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birth = _dateOfBirth;
    final selected = await showDatePicker(
      context: context,
      initialDate: birth == null || birth.isAfter(today) ? today : birth,
      firstDate: birth != null && birth.isBefore(DateTime(1900))
          ? birth
          : DateTime(1900),
      lastDate: today,
      helpText: 'Select date of birth',
    );
    if (!mounted || selected == null) return;
    setState(() => _setBirth(selected));
  }

  Future<void> _save() async {
    if (_isPickingPhoto) return;
    if (!_formKey.currentState!.validate()) return;
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .save(
          ProfileUpdate(
            displayName: _name.text,
            phoneNumber: _phone.text,
            photo: _photo,
            removePhoto: _removePhoto,
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            bloodGroup: _bloodGroup,
          ),
        );
    if (!mounted || !saved) return;
    if (widget.isEditProfile && context.canPop()) {
      context.pop(true);
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    final revision = ++_photoRevision;
    setState(() {
      _isPickingPhoto = true;
      _photoError = null;
    });
    try {
      final photo = await ref.read(profilePhotoPickerProvider).pickPhoto();
      if (!mounted || revision != _photoRevision) return;
      if (photo != null) {
        setState(() {
          _photo = photo;
          _removePhoto = false;
        });
      }
    } catch (error) {
      if (mounted && revision == _photoRevision) {
        setState(
          () => _photoError = error is ProfileException
              ? error.message
              : 'Could not select a photo. Please try again.',
        );
      }
    } finally {
      if (mounted && revision == _photoRevision) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    final enabled =
        state.profile != null &&
        !state.isLoading &&
        !state.isSaving &&
        !_isPickingPhoto;
    return PopScope(
      canPop: !state.isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditProfile ? 'Edit profile' : 'Set up your profile',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Keep your personal and contact details up to date.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.isLoading) const LinearProgressIndicator(),
                      if (state.errorMessage case final error?) ...[
                        Text(
                          error,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () => ref
                                    .read(profileControllerProvider.notifier)
                                    .load(refresh: true),
                          child: const Text('Retry loading profile'),
                        ),
                      ],
                      ProfileEditFields(
                        name: _name,
                        phone: _phone,
                        enabled: enabled,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProfilePhotoField(
                        bytes: _photo?.bytes,
                        photoUrl: state.profile?.photoUrl,
                        enabled: enabled,
                        isPicking: _isPickingPhoto,
                        isRemoved: _removePhoto,
                        error: _photoError,
                        onPick: _pickPhoto,
                        onRemove: () => setState(() {
                          _photo = null;
                          _removePhoto = !_removePhoto;
                          _photoError = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProfilePersonalFields(
                        birth: _birth,
                        dateOfBirth: _dateOfBirth,
                        gender: _gender,
                        bloodGroup: _bloodGroup,
                        enabled: enabled,
                        onPickBirth: _pickBirth,
                        onClearBirth: () => setState(() => _setBirth(null)),
                        onGenderChanged: (value) =>
                            setState(() => _gender = value),
                        onBloodGroupChanged: (value) =>
                            setState(() => _bloodGroup = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.saveError case final error?) ...[
                        Text(
                          error,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      FilledButton(
                        onPressed: enabled ? _save : null,
                        child: Text(
                          state.isSaving
                              ? 'Saving…'
                              : widget.isEditProfile
                              ? 'Save Edits'
                              : 'Save and continue',
                        ),
                      ),
                      if (!widget.isEditProfile)
                        TextButton(
                          onPressed: state.isSaving
                              ? null
                              : () => context.goNamed(AppRoutes.home),
                          child: const Text('Skip for now'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
