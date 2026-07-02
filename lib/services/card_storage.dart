import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists generated virtual cards locally so they can be shown
/// on the cards list screen even when the server has no /card/list endpoint.
class CardStorage {
  static const String _key = 'generated_cards';

  /// Saves a card locally. Skips duplicates by card_number.
  static Future<void> saveCard(Map<String, dynamic> card) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await _loadAll(prefs);

    // Avoid duplicates
    final cardNumber = card['card_number']?.toString() ?? '';
    cards.removeWhere((c) => c['card_number']?.toString() == cardNumber);

    cards.insert(0, card); // newest first
    await prefs.setString(_key, jsonEncode(cards));
  }

  /// Returns all saved cards, newest first.
  static Future<List<Map<String, dynamic>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadAll(prefs);
  }

  /// Clears all saved cards.
  static Future<void> clearCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Deletes a card by its ID from local storage.
  static Future<void> deleteCard(int cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await _loadAll(prefs);
    cards.removeWhere((c) => c['id']?.toString() == cardId.toString());
    await prefs.setString(_key, jsonEncode(cards));
  }

  /// Updates the is_active status of a card in local storage.
  static Future<void> updateCardStatus(int cardId, bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await _loadAll(prefs);
    for (var i = 0; i < cards.length; i++) {
      if (cards[i]['id']?.toString() == cardId.toString()) {
        cards[i]['is_active'] = isActive;
        break;
      }
    }
    await prefs.setString(_key, jsonEncode(cards));
  }

  /// Updates the balance of a card in local storage.
  static Future<void> updateCardBalance(int cardId, int balance) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await _loadAll(prefs);
    for (var i = 0; i < cards.length; i++) {
      if (cards[i]['id']?.toString() == cardId.toString()) {
        cards[i]['balance'] = balance;
        break;
      }
    }
    await prefs.setString(_key, jsonEncode(cards));
  }

  static List<Map<String, dynamic>> _loadAll(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }
}
