import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const _background = Color(0xFF1D1D1D);
  static const _divider = Color(0xFF2B2B2B);
  static const _primary = Color(0xFF7B42F6);
  static const _muted = Color(0xFF9EA0A8);

  bool _receivedOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadTransactionHistory());
  }

  Future<void> _refresh() async {
    context.read<WalletBloc>().add(
      _receivedOnly ? LoadReceivedMoney() : LoadTransactionHistory(),
    );
  }

  void _changeStatus(bool receivedOnly) {
    if (_receivedOnly == receivedOnly) return;
    setState(() => _receivedOnly = receivedOnly);
    context.read<WalletBloc>().add(
      receivedOnly ? LoadReceivedMoney() : LoadTransactionHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 104,
        titleSpacing: 0,
        title: const Text(
          'Transaction History',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Download',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final transactions = _transactionsFromState(state);

          return RefreshIndicator(
            color: _primary,
            backgroundColor: const Color(0xFF272727),
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _PromoBanner()),
                SliverToBoxAdapter(child: _buildFilters()),
                if (state is WalletLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  )
                else if (transactions.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyHistory(),
                  )
                else ...[
                  SliverToBoxAdapter(child: _buildMonthSummary(transactions)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Column(
                        children: [
                          if (index > 0)
                            const Divider(
                              height: 1,
                              indent: 34,
                              endIndent: 34,
                              color: _divider,
                            ),
                          _TransactionTile(
                            tx: _TransactionView.fromMap(transactions[index]),
                          ),
                        ],
                      );
                    }, childCount: transactions.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<dynamic> _transactionsFromState(WalletState state) {
    if (state is TransactionHistoryLoaded) return state.transactions;
    if (state is ReceivedMoneyLoaded) return state.received;
    return const [];
  }

  Widget _buildFilters() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: _muted,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('All Categories'),
                SizedBox(width: 8),
                Icon(Icons.filter_alt_outlined, size: 20),
              ],
            ),
          ),
          const Spacer(),
          PopupMenuButton<bool>(
            color: const Color(0xFF282828),
            onSelected: _changeStatus,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: false,
                child: Text(
                  'All Status',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: true,
                child: Text('Received', style: TextStyle(color: Colors.white)),
              ),
            ],
            child: Row(
              children: [
                Text(
                  _receivedOnly ? 'Received' : 'All Status',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(List<dynamic> transactions) {
    final views = transactions.map(_TransactionView.fromMap).toList();
    final latestDate = views
        .map((tx) => tx.date)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, date) {
          if (latest == null || date.isAfter(latest)) return date;
          return latest;
        });
    final monthDate = latestDate ?? DateTime.now();
    final monthViews = views.where((tx) {
      final date = tx.date;
      return date != null &&
          date.year == monthDate.year &&
          date.month == monthDate.month;
    });
    final incoming = monthViews
        .where((tx) => tx.isIncoming)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final outgoing = monthViews
        .where((tx) => !tx.isIncoming)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 18, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            _monthShort(monthDate.month),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF452386),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.storage_rounded,
                            color: Color(0xFFA37CFF),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Monthly Overview',
                            style: TextStyle(
                              color: Color(0xFFA37CFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _SummaryAmount(label: 'In', amount: incoming),
                    const SizedBox(width: 10),
                    _SummaryAmount(label: 'Out', amount: outgoing),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B25D6), Color(0xFF8C77CC)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 0,
            child: Text(
              'Virtual Card',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Positioned(
            left: 10,
            top: 20,
            child: Text(
              'Only ₦199 TODAY',
              style: TextStyle(
                color: Color(0xFFB9D800),
                fontSize: 27,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: Color(0x66000000),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 75,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: const Color(0xFFB9D800),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Grab Yours',
                style: TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 16,
            child: Transform.rotate(
              angle: -0.18,
              child: const _MerchantStack(),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                color: Color(0xFFC7A900),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '40K+Merchants Accepted',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantStack extends StatelessWidget {
  const _MerchantStack();

  @override
  Widget build(BuildContext context) {
    const labels = ['NETFLIX', 'Bolt', 'Google Play', 'Uber', 'JUMIA'];

    return SizedBox(
      width: 170,
      height: 78,
      child: Stack(
        children: [
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: (i % 3) * 46.0,
              top: (i ~/ 3) * 30.0 + (i.isEven ? 0 : 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: i == 0
                        ? Colors.red
                        : i == 1
                        ? Colors.green
                        : const Color(0xFF343434),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              color: _HistoryScreenState._muted,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '₦${_formatMoney(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final _TransactionView tx;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 34, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: tx.iconBackground,
            child: Icon(tx.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  tx.formattedDate,
                  style: const TextStyle(
                    color: _HistoryScreenState._muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tx.signedAmount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 70, color: _HistoryScreenState._muted),
        SizedBox(height: 16),
        Text(
          'No transactions yet',
          style: TextStyle(color: _HistoryScreenState._muted, fontSize: 19),
        ),
      ],
    );
  }
}

class _TransactionView {
  const _TransactionView({
    required this.title,
    required this.amount,
    required this.isIncoming,
    required this.formattedDate,
    required this.date,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final double amount;
  final bool isIncoming;
  final String formattedDate;
  final DateTime? date;
  final IconData icon;
  final Color iconBackground;

  String get signedAmount {
    final sign = isIncoming ? '+' : '-';
    return '$sign${_formatMoney(amount)}';
  }

  factory _TransactionView.fromMap(dynamic raw) {
    final tx = raw is Map ? raw : const {};
    final type = _read(tx, [
      'type',
      'transaction_type',
      'category',
    ]).toLowerCase().trim();
    final amount = _readAmount(tx['amount']);
    final date = _readDate(_read(tx, ['created_at', 'date', 'timestamp']));
    final incoming = _isIncoming(type, tx);

    return _TransactionView(
      title: _titleFor(tx, type, incoming),
      amount: amount.abs(),
      isIncoming: incoming,
      formattedDate: _formatDate(date, _read(tx, ['created_at', 'date'])),
      date: date,
      icon: _iconFor(type, incoming),
      iconBackground: _iconBackgroundFor(type, incoming),
    );
  }

  static String _read(Map<dynamic, dynamic> tx, List<String> keys) {
    for (final key in keys) {
      final value = tx[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  static double _readAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }

  static DateTime? _readDate(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static bool _isIncoming(String type, Map<dynamic, dynamic> tx) {
    final direction = _read(tx, ['direction', 'status']).toLowerCase();
    if (direction.contains('in') || direction.contains('credit')) return true;
    if (direction.contains('out') || direction.contains('debit')) return false;
    return type.contains('deposit') ||
        type.contains('received') ||
        type.contains('credit') ||
        type.contains('interest') ||
        type.contains('save');
  }

  static String _titleFor(
    Map<dynamic, dynamic> tx,
    String type,
    bool incoming,
  ) {
    final explicit = _read(tx, ['description', 'title', 'note']);
    if (explicit.isNotEmpty) return explicit;

    final otherName = _read(tx, [
      incoming ? 'sender_name' : 'receiver_name',
      incoming ? 'from_name' : 'to_name',
      incoming ? 'sender' : 'receiver',
      'name',
    ]);

    if (type.contains('deposit')) return 'Deposit';
    if (type.contains('card')) return 'Card Payment-POS';
    if (type.contains('stamp')) return 'Stamp Duty';
    if (type.contains('interest')) return 'CashBox Interest';
    if (type.contains('save')) return 'CashBox Auto Save';
    if (incoming) {
      return otherName.isEmpty ? 'Received Money' : 'Received from $otherName';
    }
    if (type.contains('transfer') || type.contains('send')) {
      return otherName.isEmpty ? 'Send Money' : 'Send - $otherName';
    }
    if (type.isEmpty) return 'Transaction';
    return type
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static IconData _iconFor(String type, bool incoming) {
    if (type.contains('card')) return Icons.credit_card;
    if (type.contains('stamp')) return Icons.percent_rounded;
    if (type.contains('save') || type.contains('interest')) {
      return Icons.savings_outlined;
    }
    return incoming ? Icons.file_download_outlined : Icons.upload_outlined;
  }

  static Color _iconBackgroundFor(String type, bool incoming) {
    if (type.contains('stamp')) return const Color(0xFFECE8FF);
    if (incoming && !type.contains('save') && !type.contains('interest')) {
      return const Color(0xFF4C9BFF);
    }
    return const Color(0xFF7443F8);
  }
}

String _formatMoney(double amount) {
  final fixed = amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return '$whole.${parts.last}';
}

String _formatDate(DateTime? date, String fallback) {
  if (date == null) return fallback;
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_monthShort(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year} $hour:$minute $period';
}

String _monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}
