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

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<WalletBloc>().add(LoadTransactionHistory());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Received'),
          ],
          onTap: (index) {
            if (index == 0) {
              context.read<WalletBloc>().add(LoadTransactionHistory());
            } else {
              context.read<WalletBloc>().add(LoadReceivedMoney());
            }
          },
        ),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> transactions = [];
          if (state is TransactionHistoryLoaded) {
            transactions = state.transactions;
          } else if (state is ReceivedMoneyLoaded) {
            transactions = state.received;
          }

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_tabController.index == 0) {
                context.read<WalletBloc>().add(LoadTransactionHistory());
              } else {
                context.read<WalletBloc>().add(LoadReceivedMoney());
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final type = tx['type']?.toString() ?? 'unknown';
                final amount = int.tryParse(tx['amount'].toString()) ?? 0;
                final isDeposit = type == 'deposit';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDeposit
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDeposit ? Colors.green : Colors.blue,
                      ),
                    ),
                    title: Text(
                      type == 'deposit'
                          ? 'Deposit'
                          : type == 'transfer'
                          ? 'Transfer'
                          : type,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tx['note'] != null) Text(tx['note'].toString()),
                        Text(
                          _formatDate(tx['created_at']?.toString()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${isDeposit ? '+' : '-'}₦$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDeposit ? Colors.green : Colors.green,
                      ),
                    ),
                    isThreeLine: tx['note'] != null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
