import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'data/records_repository_impl.dart';
import 'domain/patient_record.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>(
  (ref) => RecordsRepositoryImpl(ref.watch(dioProvider)),
);
