/// Match assessment specialties without broad qualifiers that differ between
/// NurseAI recommendations and directory labels.
bool matchesRecommendedSpecialty(String recommended, String specialty) {
  Set<String> words(String value) => RegExp(r'[a-z0-9]+')
      .allMatches(value.toLowerCase())
      .map((match) => match.group(0)!)
      .where((word) => word != 'general' && word != 'internal')
      .toSet();

  final query = words(recommended);
  // A qualifier on its own must not match every doctor.
  return query.isNotEmpty && words(specialty).containsAll(query);
}
