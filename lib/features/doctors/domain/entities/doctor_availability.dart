import 'doctor.dart';

/// Recurring doctor hours. Unzoned API times are local wall-clock times.
/// The API does not provide appointment duration, so slots default to 30 minutes.
class DoctorAvailability {
  DoctorAvailability({
    required List<String> daysAvailable,
    required List<DoctorTimeRange> timeAvailable,
    this.slotDuration = const Duration(minutes: 30),
  }) : _weekdays = daysAvailable
           .map((day) => _days[day.trim().toLowerCase()])
           .whereType<int>()
           .toSet(),
       _ranges = timeAvailable.map(_Hours.parse).whereType<_Hours>().toList() {
    if (slotDuration.inMinutes < 1 ||
        slotDuration.inMicroseconds % Duration.microsecondsPerMinute != 0) {
      throw ArgumentError.value(
        slotDuration,
        'slotDuration',
        'Use a positive whole-minute duration.',
      );
    }
  }

  static const _days = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
  };
  final Set<int> _weekdays;
  final List<_Hours> _ranges;
  final Duration slotDuration;

  bool get hasSchedule => _weekdays.isNotEmpty && _ranges.isNotEmpty;

  List<DateTime> slotsForDate(DateTime date, {required DateTime now}) {
    final day = DateTime(date.year, date.month, date.day);
    final slots = <DateTime>{};
    // Zoned times can fall on the previous/next local date after conversion.
    for (var offset = -1; offset <= 1; offset++) {
      final sourceDay = DateTime(day.year, day.month, day.day + offset);
      if (!_weekdays.contains(sourceDay.weekday)) continue;
      for (final range in _ranges) {
        var start = range.start.onDate(sourceDay);
        final end = range.end.onDate(sourceDay);
        // TimeOfDay and the booking API's draft have minute precision.
        if (start.second != 0 ||
            start.millisecond != 0 ||
            start.microsecond != 0) {
          start = start
              .subtract(
                Duration(
                  seconds: start.second,
                  milliseconds: start.millisecond,
                  microseconds: start.microsecond,
                ),
              )
              .add(const Duration(minutes: 1));
        }
        for (
          var slot = start;
          !slot.add(slotDuration).isAfter(end);
          slot = slot.add(slotDuration)
        ) {
          if (slot.year == day.year &&
              slot.month == day.month &&
              slot.day == day.day &&
              slot.isAfter(now)) {
            slots.add(slot);
          }
        }
      }
    }
    return List.unmodifiable(slots.toList()..sort());
  }
}

class _Hours {
  const _Hours(this.start, this.end);
  final _ClockTime start;
  final _ClockTime end;

  static _Hours? parse(DoctorTimeRange range) {
    final start = _ClockTime.parse(range.start);
    final end = _ClockTime.parse(range.end);
    if (start == null ||
        end == null ||
        start.offsetMinutes != end.offsetMinutes ||
        start.microseconds >= end.microseconds) {
      return null;
    }
    return _Hours(start, end);
  }
}

class _ClockTime {
  const _ClockTime(this.microseconds, this.offsetMinutes);
  final int microseconds;
  final int? offsetMinutes;

  static _ClockTime? parse(String value) {
    final match = RegExp(
      r'^(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,6}))?)?(Z|[+-]\d{2}:\d{2})?$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    final second = int.parse(match[3] ?? '0');
    if (hour > 23 || minute > 59 || second > 59) return null;
    final fraction = int.parse((match[4] ?? '').padRight(6, '0'));
    final zone = match[5];
    int? offset;
    if (zone != null) {
      offset = 0;
      if (zone.toUpperCase() != 'Z') {
        final hours = int.parse(zone.substring(1, 3));
        final minutes = int.parse(zone.substring(4, 6));
        if (hours > 23 || minutes > 59) return null;
        offset = (hours * 60 + minutes) * (zone.startsWith('-') ? -1 : 1);
      }
    }
    return _ClockTime(
      Duration(
        hours: hour,
        minutes: minute,
        seconds: second,
        microseconds: fraction,
      ).inMicroseconds,
      offset,
    );
  }

  DateTime onDate(DateTime date) {
    final offset = offsetMinutes;
    if (offset == null) {
      final time = Duration(microseconds: microseconds);
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.inHours,
        time.inMinutes % 60,
        time.inSeconds % 60,
        time.inMilliseconds % 1000,
        time.inMicroseconds % 1000,
      );
    }
    final midnight = DateTime.utc(date.year, date.month, date.day);
    final time = midnight.add(Duration(microseconds: microseconds));
    return time.subtract(Duration(minutes: offset)).toLocal();
  }
}
