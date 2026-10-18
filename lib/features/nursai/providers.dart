import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'data/repositories/nursai_repository_impl.dart';
import 'domain/repositories/nursai_repository.dart';

final nursaiRepositoryProvider = Provider<NursaiRepository>(
  (ref) => NursaiRepositoryImpl(dio: ref.watch(dioProvider)),
);
