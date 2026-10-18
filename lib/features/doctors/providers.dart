import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/repositories/doctors_repository_impl.dart';
import 'domain/repositories/doctors_repository.dart';

final doctorsRepositoryProvider = Provider<DoctorsRepository>(
  (ref) => DoctorsRepositoryImpl(dio: ref.watch(dioProvider)),
);
