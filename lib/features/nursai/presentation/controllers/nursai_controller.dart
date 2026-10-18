import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/symptom_intake.dart';
import '../../domain/repositories/nursai_repository.dart';
import '../../providers.dart';
import 'nursai_state.dart';

final nursaiControllerProvider =
    NotifierProvider.autoDispose<NursaiController, NursaiState>(
      NursaiController.new,
    );

class NursaiController extends Notifier<NursaiState> {
  @override
  NursaiState build() => const NursaiState();

  Future<void> assess(SymptomIntake intake) async {
    if (state.isLoading) return;
    state = const NursaiState(isLoading: true);
    try {
      final result = await ref.read(nursaiRepositoryProvider).assess(intake);
      if (!ref.mounted) return;
      state = NursaiState(assessment: result);
    } catch (error) {
      if (!ref.mounted) return;
      state = NursaiState(
        errorMessage: error is NursaiException
            ? error.message
            : 'Could not assess your symptoms. Please try again.',
      );
    }
  }
}
