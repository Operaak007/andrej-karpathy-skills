// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../constants.dart';

class GenerateCardScreen extends StatefulWidget {
  const GenerateCardScreen({super.key});

  @override
  State<GenerateCardScreen> createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends State<GenerateCardScreen> {
  String _selectedBrand = 'visa';

  String _formatBalance(int balance) {
    return balance.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _maskCardNumber(String number) {
    if (number.length < 8) return number;
    final first4 = number.substring(0, 4);
    final last4 = number.substring(number.length - 4);
    return '$first4 •••• •••• $last4';
  }

  void _generate() {
    context.read<WalletBloc>().add(GenerateCard(brand: _selectedBrand));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      appBar: AppBar(
        title: const Text('Generate Virtual Card'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
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
          // Note: Do NOT dispatch LoadBalance() here.
          // Doing so would change state away from CardGenerated
          // before the user sees the success view.
          // Balance is refreshed when the user taps "Done".
        },
        builder: (context, state) {
          if (state is CardGenerated) {
            return _buildSuccessView(state);
          }

          return _buildFormView(state);
        },
      ),
    );
  }

  Widget _buildFormView(WalletState state) {
    final isLoading = state is WalletLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.credit_card, color: Colors.white, size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Virtual Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate a virtual card instantly. A one-time charge of ₦500 will be deducted from your wallet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Charge: ₦500',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Brand selection
          const Text(
            'Select Card Brand',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildBrandOption(
            brand: 'visa',
            label: 'VISA',
            icon: Icons.credit_card,
            color: const Color(0xFF1A1F71),
          ),
          const SizedBox(height: 8),
          _buildBrandOption(
            brand: 'mastercard',
            label: 'Mastercard',
            icon: Icons.credit_card,
            color: const Color(0xFFEB001B),
          ),
          const SizedBox(height: 8),
          _buildBrandOption(
            brand: 'verve',
            label: 'Verve',
            icon: Icons.credit_card,
            color: const Color(0xFF004B87),
          ),

          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Generate Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.orange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your virtual card details will be shown only once. Please save them securely.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandOption({
    required String brand,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedBrand == brand;

    return InkWell(
      onTap: () => setState(() => _selectedBrand = brand),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mint : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.mint, size: 22)
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Colors.white24,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(CardGenerated state) {
    final card = state.card;
    final cardNumber = card['card_number']?.toString() ?? '';
    final cardBrand = card['card_brand']?.toString() ?? '';
    final expiry = card['expiry']?.toString() ?? '';
    final cvv = card['cvv']?.toString() ?? '';
    final pin = card['pin']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Success header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mint, width: 1),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppColors.mint, size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Card Generated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Virtual card visual
          _buildCardVisual(cardNumber, cardBrand, expiry),

          const SizedBox(height: 24),

          // Card details
          _buildDetailRow('Card Number', cardNumber, copyable: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow('Expiry', expiry, copyable: true),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildDetailRow('CVV', cvv, copyable: true)),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('PIN', pin, copyable: true),

          const SizedBox(height: 24),

          // Charges summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Charge',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '₦${_formatBalance(state.charge)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remaining Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₦${_formatBalance(state.remainingBalance)}',
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Done button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Refresh wallet balance after the user has seen the card details
                context.read<WalletBloc>().add(LoadBalance());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardVisual(String cardNumber, String brand, String expiry) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F71), Color(0xFF4A3B8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Virtual Card',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                brand.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Icon(Icons.contactless, color: Colors.white, size: 28),
          Text(
            _maskCardNumber(cardNumber),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VALID THRU',
                    style: TextStyle(color: Colors.white54, fontSize: 9),
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.sim_card, color: Colors.white, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (copyable && value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: AppColors.mint, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.surface,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
