// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../constants.dart';
import 'generate_card_screen.dart';
import 'package:shimmer/shimmer.dart';

class CardsListScreen extends StatefulWidget {
  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    context.read<WalletBloc>().add(LoadCards());
  }

  String _formatBalance(int balance) {
    return balance.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatCardNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return '';
    return digits
        .replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (Match m) => '${m[1]} ')
        .trim();
  }

  Color _brandColor(String brand) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return const Color(0xFF1A1F71);
      case 'MASTERCARD':
        return const Color(0xFFEB001B);
      case 'VERVE':
        return const Color(0xFF004B87);
      default:
        return AppColors.purple;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    } catch (_) {
      return raw;
    }
  }

  void _copy(BuildContext context, String value, String label) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.mint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadCards,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mint,
        foregroundColor: Colors.black,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GenerateCardScreen()),
          );
          if (!mounted) return;
          if (result == true) {
            _loadCards();
          } else {
            // Always refresh on return in case a card was generated
            _loadCards();
          }
        },
        icon: const Icon(Icons.add_card),
        label: const Text(
          'New Card',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CardDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.mint,
              ),
            );
          }
          if (state is CardDeleteError) {
            final msg = state.balance != null && state.balance! > 0
                ? 'Cannot delete: card has ₦${_formatBalance(state.balance!)}. Withdraw funds first.'
                : state.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.orange),
            );
          }
          if (state is CardToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.mint,
              ),
            );
          }
          if (state is CardFunded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.message}. Card: ₦${_formatBalance(state.cardBalance)} • Wallet: ₦${_formatBalance(state.walletBalance)}',
                ),
                backgroundColor: AppColors.mint,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CardsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadCards(),
              child: _buildBody(state),
            );
          }
          if (state is WalletLoading) {
            return RefreshIndicator(
              onRefresh: () async => _loadCards(),
              child: _buildLoadingShimmers(),
            );
          }
          if (state is WalletError) {
            return RefreshIndicator(
              onRefresh: () async => _loadCards(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _loadCards,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadCards(),
            child: _buildLoadingShimmers(),
          );
        },
      ),
    );
  }

  Widget _buildBody(CardsLoaded state) {
    if (state.cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          const Center(
            child: Icon(
              Icons.credit_card_off_outlined,
              color: Colors.white54,
              size: 72,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No cards yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tap "New Card" to generate your first virtual card.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final card = state.cards[index];
        return _buildCardTile(card);
      },
    );
  }

  Widget _buildCardTile(Map<String, dynamic> card) {
    final brand = (card['card_brand'] ?? '').toString();
    final number = (card['card_number'] ?? '').toString();
    final month = (card['expiry_month'] ?? '').toString();
    final year = (card['expiry_year'] ?? '').toString();
    final isActive = card['is_active'] == true;
    final balance = _parseInt(card['balance']);
    final createdAt = _formatDate(card['created_at']?.toString());
    final brandColor = _brandColor(brand);
    final cvv = (card['cvv'] ?? '').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showCardDetails(card),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              brandColor,
              brandColor.withValues(alpha: 0.7),
              AppColors.violet,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      brand.isEmpty ? 'CARD' : brand.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.redAccent : AppColors.mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'INACTIVE' : 'ACTIVE',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              number.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _formatCardNumber(number),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    label: 'EXPIRES',
                    value: (month.isEmpty || year.isEmpty)
                        ? '--/--'
                        : '$month/$year',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(label: 'CVV', value: "$cvv"),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    label: 'BALANCE',
                    value: '₦${_formatBalance(balance)}',
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    label: 'CREATED',
                    value: createdAt.isEmpty ? '--' : createdAt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmers() {
    return Shimmer.fromColors(
      baseColor: Colors.white12,
      highlightColor: Colors.white24,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    children: List.generate(
                      4,
                      (_) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showCardDetails(Map<String, dynamic> card) {
    final brand = (card['card_brand'] ?? '').toString();
    final number = (card['card_number'] ?? '').toString();
    final month = (card['expiry_month'] ?? '').toString();
    final year = (card['expiry_year'] ?? '').toString();
    final isActive = card['is_active'] == true;
    final balance = _parseInt(card['balance']);
    final createdAt = _formatDate(card['created_at']?.toString());
    final id = card['id']?.toString() ?? '';
    final cvv = (card['cvv'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Card Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Card ID',
                  value: id,
                  icon: Icons.fingerprint,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Brand',
                  value: brand.isEmpty ? '--' : brand.toUpperCase(),
                  icon: Icons.credit_card,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Card Number',
                  value: number.isEmpty ? '--' : _formatCardNumber(number),
                  icon: Icons.numbers,
                  copyable: true,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'CVV',
                  value: cvv.isEmpty ? '--' : cvv,
                  icon: Icons.lock_outline,
                  copyable: true,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Expiry',
                  value: (month.isEmpty || year.isEmpty)
                      ? '--/--'
                      : '$month/$year',
                  icon: Icons.event,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Balance',
                  value: '₦${_formatBalance(balance)}',
                  icon: Icons.account_balance_wallet,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Status',
                  value: isActive ? 'InActive' : 'Active',
                  icon: Icons.toggle_on,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  label: 'Created',
                  value: createdAt.isEmpty ? '--' : createdAt,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmDeleteCard(card);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Delete Card',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _toggleCardStatus(card);
                    },
                    icon: Icon(
                      isActive
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      isActive ? 'Deactivate Card' : 'Activate Card',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isActive
                            ? Colors.orange.shade400
                            : AppColors.mint,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _fundCard(card);
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Fund Card',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fundCard(Map<String, dynamic> card) {
    final cardId = _parseInt(card['id']);
    if (cardId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid card id'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Fund Card', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the amount to fund card #${card['card_number']?.toString() ?? cardId.toString()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount (₦)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.mint,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.mint),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = int.tryParse(value.trim());
                    if (amount == null) {
                      return 'Enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = int.parse(amountController.text.trim());
                  Navigator.pop(dialogContext);
                  context.read<WalletBloc>().add(
                    FundCard(cardId: cardId, amount: amount),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.black,
              ),
              child: const Text('Fund'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCardStatus(Map<String, dynamic> card) {
    final cardId = _parseInt(card['id']);
    final isActive = card['is_active'] == true;
    final brand = (card['card_brand'] ?? '').toString().toUpperCase();
    final number = (card['card_number'] ?? '').toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isActive ? 'Deactivate Card?' : 'Activate Card?',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isActive
                    ? 'This will deactivate the $brand card. It cannot be used for transactions while inactive.'
                    : 'This will activate the $brand card. It can then be used for transactions.',
                style: const TextStyle(color: Colors.white70),
              ),
              if (number.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Card: $number',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(
                  ToggleCardStatus(cardId: cardId, currentStatus: isActive),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? Colors.orange.shade700
                    : AppColors.mint,
                foregroundColor: Colors.black,
              ),
              child: Text(isActive ? 'Deactivate' : 'Activate'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCard(Map<String, dynamic> card) {
    final cardId = _parseInt(card['id']);
    final balance = _parseInt(card['balance']);
    final brand = (card['card_brand'] ?? '').toString().toUpperCase();
    final number = (card['card_number'] ?? '').toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Card?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this $brand card?',
                style: const TextStyle(color: Colors.white70),
              ),
              if (number.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Card: $number',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
              if (balance > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This card has ₦${_formatBalance(balance)}. Withdraw funds first.',
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: balance > 0
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      context.read<WalletBloc>().add(
                        DeleteCard(cardId: cardId),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: Text(
                balance > 0 ? 'Has Balance' : 'Delete',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy, color: AppColors.mint, size: 18),
              onPressed: () => _copy(context, value, label),
            ),
        ],
      ),
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}
