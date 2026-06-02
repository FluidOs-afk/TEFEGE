class ContentFilter {
  static const List<String> _badWords = [
    // Español
    'puta', 'puto', 'mierda', 'coño', 'cono', 'hostia', 'joder', 'follar',
    'cabron', 'cabrón', 'gilipollas', 'imbecil', 'idiota', 'estupido',
    'maricon', 'maricón', 'zorra', 'polla', 'capullo', 'subnormal',
    'bastardo', 'cojones', 'hijoputa', 'pendejo', 'chinga', 'verga',
    'culero', 'pinche', 'mamon', 'mamón', 'culo', 'gilipolla',
    // English
    'fuck', 'shit', 'bitch', 'asshole', 'bastard', 'cunt', 'dick',
    'pussy', 'nigger', 'nigga', 'faggot', 'whore', 'slut', 'retard',
    'motherfucker', 'bullshit', 'prick', 'twat', 'wanker',
  ];

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('4', 'a')
        .replaceAll('3', 'e')
        .replaceAll('1', 'i')
        .replaceAll('0', 'o')
        .replaceAll('@', 'a')
        .replaceAll('\$', 's')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool containsProfanity(String text) {
    final normalized = _normalize(text);
    for (final word in _badWords) {
      if (normalized.contains(word)) return true;
    }
    return false;
  }

  static String filterText(String text) {
    var result = text;
    for (final word in _badWords) {
      result = result.replaceAllMapped(
        RegExp(word, caseSensitive: false),
        (m) => '*' * m.group(0)!.length,
      );
    }
    return result;
  }
}
