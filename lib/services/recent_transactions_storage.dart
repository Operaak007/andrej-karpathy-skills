import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists recent transaction details locally so they can be shown
/// on the send money screen for quick access to frequent recipients.
class RecentTransactionsStorage {
  static const String _key = 'recent_transactions';
  static const int _maxTransactions = 10;

  /// Saves a transaction locally. Removes duplicates by receiver_id and keeps newest first.
  static Future<void> saveTransaction(Map<String, dynamic> transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await _loadAll(prefs);

    // Remove duplicate by receiver_id if exists
    final receiverId = transaction['receiver_id']?.toString() ?? '';
    transactions.removeWhere((t) => t['receiver_id']?.toString() == receiverId);

    // Add timestamp if not present
    transaction['timestamp'] = DateTime.now().toIso8601String();

    // Insert at the beginning (newest first)
    transactions.insert(0, transaction);

    // Keep only the most recent transactions
    final trimmed = transactions.take(_maxTransactions).toList();

    await prefs.setString(_key, jsonEncode(trimmed));
  }

  /// Returns all saved transactions, newest first.
  static Future<List<Map<String, dynamic>>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadAll(prefs);
  }

  /// Clears all saved transactions.
  static Future<void> clearTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Deletes a transaction by receiver_id from local storage.
  static Future<void> deleteTransaction(String receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await _loadAll(prefs);
    transactions.removeWhere((t) => t['receiver_id']?.toString() == receiverId);
    await prefs.setString(_key, jsonEncode(transactions));
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
