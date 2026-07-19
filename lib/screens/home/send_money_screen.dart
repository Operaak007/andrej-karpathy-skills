import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1F1F1F);
  static const _primary = Color(0xFF8E5CFF);
  static const _primaryDisabled = Color(0xFF473B66);
  static const _mutedText = Color(0xFFA4A4AF);

  final _recipientController = TextEditingController();
  Timer? _debounce;

  bool _userVerified = false;
  bool _amountRouteOpen = false;
  String? _verifiedUserId;
  String? _verifiedUserName;
  String? _verifiedUserEmail;
  String? _verifiedUserPhone;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentTransactions() async {
    if (!mounted) return;
    context.read<WalletBloc>().add(LoadRecentTransactions());
  }

  String _formatBalance(int balance) {
    return balance.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String _recipientValue() => _recipientController.text.trim();

  bool _looksLikeEmail(String value) => value.contains('@');

  bool _isPhoneRecipient() => !_looksLikeEmail(_recipientValue());

  void _clearVerifiedUser() {
    _userVerified = false;
    _verifiedUserId = null;
    _verifiedUserName = null;
    _verifiedUserEmail = null;
    _verifiedUserPhone = null;
  }

  void _onRecipientChanged(String value) {
    _debounce?.cancel();
    setState(_clearVerifiedUser);

    final recipient = value.trim();
    if (recipient.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 700), _verifyUser);
  }

  void _verifyUser() {
    final recipient = _recipientValue();
    if (recipient.isEmpty) {
      _showSnackBar('Please enter recipient account or phone', Colors.orange);
      return;
    }

    context.read<WalletBloc>().add(
      VerifyUser(
        email: _looksLikeEmail(recipient) ? recipient : null,
        phone: _looksLikeEmail(recipient) ? null : recipient,
      ),
    );
  }

  void _selectRecentTransaction(Map<String, dynamic> transaction) {
    final email = transaction['receiver_email']?.toString();
    final phone = transaction['receiver_phone']?.toString();

    setState(() {
      _recipientController.text = (phone?.isNotEmpty ?? false)
          ? phone!
          : email ?? '';
      _userVerified = true;
      _verifiedUserId = transaction['receiver_id']?.toString();
      _verifiedUserName = transaction['receiver_name']?.toString();
      _verifiedUserEmail = email;
      _verifiedUserPhone = phone;
    });

    if (_recipientController.text.trim().isNotEmpty) {
      _verifyUser();
    }
  }

  Future<void> _openAmountScreen() async {
    if (!_userVerified || _verifiedUserId == null) {
      _verifyUser();
      return;
    }

    _amountRouteOpen = true;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WalletBloc>(),
          child: _SendMoneyAmountScreen(
            receiverId: _verifiedUserId!,
            receiverName: _verifiedUserName ?? 'Recipient',
            receiverEmail: _verifiedUserEmail,
            receiverPhone: _verifiedUserPhone,
            enteredRecipient: _recipientValue(),
            isPhoneRecipient: _isPhoneRecipient(),
            formatBalance: _formatBalance,
          ),
        ),
      ),
    );
    _amountRouteOpen = false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 88,
        titleSpacing: 0,
        title: const Text(
          'Transfer to EasyW@llet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'More',
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 18),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is UserVerified) {
            setState(() {
              _userVerified = true;
              _verifiedUserId = state.userId;
              _verifiedUserName = state.userName;
              _verifiedUserEmail = state.userEmail;
              _verifiedUserPhone = state.userPhone;
            });
          } else if (state is RecentTransactionsLoaded) {
            setState(() {
              _recentTransactions = state.recent
                  .whereType<Map<String, dynamic>>()
                  .toList();
            });
          }
          //  else if (state is WalletError && !_amountRouteOpen) {
          //   setState(_clearVerifiedUser);
          //   _showSnackBar(state.message, Colors.red);
          // }
        },
        builder: (context, state) {
          final isVerifying = state is WalletLoading && !_userVerified;
          final canContinue = _userVerified && !isVerifying;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 36),
            children: [
              _buildRecipientCard(
                isVerifying: isVerifying,
                enabled: canContinue,
              ),
              const SizedBox(height: 26),
              _buildHistoryPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipientCard({
    required bool isVerifying,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recipient Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _recipientController,
                  onChanged: _onRecipientChanged,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: _primary,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter 10-digit Account No. or Email Add.',
                    hintStyle: TextStyle(
                      color: Color(0xFF6F6F7D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Verify recipient',
                onPressed: isVerifying ? null : _verifyUser,
                icon: isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: _primary,
                        ),
                      )
                    : Icon(
                        _userVerified
                            ? Icons.verified_outlined
                            : Icons.person_search_outlined,
                        color: _userVerified ? Colors.greenAccent : _mutedText,
                        size: 20,
                      ),
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFF303030)),
          if (_userVerified && _verifiedUserName != null) ...[
            _buildVerifiedRecipient(),
            const SizedBox(height: 18),
          ],
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: enabled ? _openAmountScreen : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDisabled,
                disabledBackgroundColor: _primaryDisabled,
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF7D719B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedRecipient() {
    final recipient = _isPhoneRecipient()
        ? (_verifiedUserPhone?.isNotEmpty == true
              ? _verifiedUserPhone!
              : _recipientValue())
        : (_verifiedUserEmail?.isNotEmpty == true
              ? _verifiedUserEmail!
              : _recipientValue());

    return Row(
      children: [
        _buildAvatar(_verifiedUserName ?? 'R'),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _verifiedUserName ?? 'Recipient',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recipient,
                style: const TextStyle(color: _mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text(
                      'Recent',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container(
                    //   width: 52,
                    //   height: 4,
                    //   decoration: BoxDecoration(
                    //     color: _primary,
                    //     borderRadius: BorderRadius.circular(99),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 20),
                const Text(
                  'Favorites',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Search',
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: _mutedText, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          if (_recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 46),
              child: Text(
                'No recent transfers yet',
                style: TextStyle(color: _mutedText, fontSize: 17),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFF2A2A2A)),
              itemBuilder: (context, index) {
                return _buildRecentTile(_recentTransactions[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentTile(Map<String, dynamic> transaction, int index) {
    final name = transaction['receiver_name']?.toString() ?? 'Unknown';
    final phone = transaction['receiver_phone']?.toString();
    final email = transaction['receiver_email']?.toString();
    final recipient = (phone?.isNotEmpty ?? false) ? phone! : email ?? '';

    return InkWell(
      onTap: () => _selectRecentTransaction(transaction),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          recipient,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: _buildAvatar(name, index: index),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: _mutedText,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, {int index = 0}) {
    const colors = [
      Color(0xFFD7C8FF),
      Color(0xFFB7E4D2),
      Color(0xFFFFD6A5),
      Color(0xFFBDE0FE),
    ];
    final color = colors[index % colors.length];
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 21,
      backgroundColor: color,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF473B66),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SendMoneyAmountScreen extends StatefulWidget {
  const _SendMoneyAmountScreen({
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    required this.receiverPhone,
    required this.enteredRecipient,
    required this.isPhoneRecipient,
    required this.formatBalance,
  });

  final String receiverId;
  final String receiverName;
  final String? receiverEmail;
  final String? receiverPhone;
  final String enteredRecipient;
  final bool isPhoneRecipient;
  final String Function(int balance) formatBalance;

  @override
  State<_SendMoneyAmountScreen> createState() => _SendMoneyAmountScreenState();
}

class _SendMoneyAmountScreenState extends State<_SendMoneyAmountScreen> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1F1F1F);
  static const _primary = Color(0xFF8E5CFF);
  static const _primaryDisabled = Color(0xFF473B66);
  static const _mutedText = Color(0xFFA4A4AF);

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final confirmed = await _showConfirmSheet(amount);
    if (confirmed != true || !mounted) return;

    final pinConfirmed = await _showPinSheet();
    if (pinConfirmed != true || !mounted) return;

    _dispatchSendMoney(amount);
  }

  void _dispatchSendMoney(int amount) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again to continue'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentEmail = authState.user['email']?.toString();
    if (currentEmail == null || currentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to find your account email'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<WalletBloc>().add(
      SendMoneyWithPin(
        email: currentEmail,
        pin: _pinController.text.trim(),
        receiverId: int.tryParse(widget.receiverId),
        receiverEmail: widget.isPhoneRecipient ? null : widget.enteredRecipient,
        receiverPhone: widget.isPhoneRecipient ? widget.enteredRecipient : null,
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  Future<bool?> _showConfirmSheet(int amount) {
    final recipient = _displayRecipient();
    final note = _noteController.text.trim();

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF57515F),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Confirm Transfer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFD7C8FF),
                  child: Text(
                    widget.receiverName.isEmpty
                        ? '?'
                        : widget.receiverName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF473B66),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.receiverName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipient,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _mutedText, fontSize: 15),
                ),
                const SizedBox(height: 22),
                _ConfirmRow(
                  label: 'Amount',
                  value: 'NGN ${_formatAmount(amount)}',
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ConfirmRow(label: 'Note', value: note),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF3B3B3B)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showPinSheet() {
    _pinController.clear();
    String enteredPin = '';

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                  decoration: const BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF57515F),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Enter PIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // PIN display dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < enteredPin.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled ? _primary : Colors.transparent,
                              border: Border.all(
                                color: isFilled ? _primary : _mutedText,
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      // Numeric keypad
                      _buildKeypad(
                        onDigit: (digit) {
                          if (enteredPin.length < 4) {
                            setSheetState(() {
                              enteredPin += digit;
                              _pinController.text = enteredPin;
                            });
                            if (enteredPin.length == 4) {
                              Navigator.of(sheetContext).pop(true);
                            }
                          }
                        },
                        onDelete: () {
                          if (enteredPin.isNotEmpty) {
                            setSheetState(() {
                              enteredPin = enteredPin.substring(
                                0,
                                enteredPin.length - 1,
                              );
                              _pinController.text = enteredPin;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF3B3B3B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKeypad({
    required void Function(String) onDigit,
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            '1',
            '2',
            '3',
          ].map((d) => _keypadButton(d, () => onDigit(d))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            '4',
            '5',
            '6',
          ].map((d) => _keypadButton(d, () => onDigit(d))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            '7',
            '8',
            '9',
          ].map((d) => _keypadButton(d, () => onDigit(d))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72),
            _keypadButton('0', () => onDigit('0')),
            _keypadButton('', onDelete, icon: Icons.backspace_outlined),
          ],
        ),
      ],
    );
  }

  Widget _keypadButton(String label, VoidCallback onTap, {IconData? icon}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: label.isNotEmpty || icon != null ? onTap : null,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF151515),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 26)
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  String _displayRecipient() {
    if (widget.isPhoneRecipient) {
      return widget.receiverPhone?.isNotEmpty == true
          ? widget.receiverPhone!
          : widget.enteredRecipient;
    }
    return widget.receiverEmail?.isNotEmpty == true
        ? widget.receiverEmail!
        : widget.enteredRecipient;
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipient = _displayRecipient();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 82,
        titleSpacing: 0,
        title: const Text(
          'Enter Amount',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) async {
          if (state is MoneySent) {
            final amount = int.tryParse(_amountController.text.trim()) ?? 0;
            if (!context.mounted) return;
            context.read<WalletBloc>().add(LoadRecentTransactions());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transfer successful. New Balance: NGN ${widget.formatBalance(state.newBalance)}',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSending = state is WalletLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 36),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 31,
                        backgroundColor: const Color(0xFFD7C8FF),
                        child: Text(
                          widget.receiverName.isEmpty
                              ? '?'
                              : widget.receiverName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF473B66),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.receiverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              recipient,
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                        cursorColor: _primary,
                        decoration: const InputDecoration(
                          prefixText: 'NGN ',
                          prefixStyle: TextStyle(
                            color: _primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                          hintText: '0',
                          hintStyle: TextStyle(color: Color(0xFF6F6F7D)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF303030)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: _primary, width: 2),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                        ),
                        validator: (value) {
                          final amount = int.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: _primary,
                        decoration: InputDecoration(
                          hintText: 'Note (optional)',
                          hintStyle: const TextStyle(color: _mutedText),
                          filled: true,
                          fillColor: const Color(0xFF151515),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: isSending ? null : _sendMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: const Color(0xFF473B66),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF7D719B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      isSending ? 'Sending' : 'Send',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA4A4AF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
