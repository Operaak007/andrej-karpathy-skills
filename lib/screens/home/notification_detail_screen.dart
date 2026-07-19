import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int transactionId;

  const NotificationDetailScreen({super.key, required this.transactionId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(
      LoadNotificationDetail(widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationDetailLoaded) {
            final notification = state.notification;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    notification['title']?.toString() ?? 'Transaction Detail',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(notification['subtitle']?.toString() ?? ''),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Amount',
                    'NGN ${notification['amount']?.toString() ?? '0'}',
                  ),
                  _buildDetailRow(
                    'Type',
                    notification['type']?.toString() ?? '',
                  ),
                  _buildDetailRow(
                    'Note',
                    notification['note']?.toString() ?? '',
                  ),
                  _buildDetailRow(
                    'Sent by',
                    notification['sender_name']?.toString() ?? '',
                  ),
                  _buildDetailRow(
                    'Received by',
                    notification['receiver_name']?.toString() ?? '',
                  ),
                  _buildDetailRow(
                    'Created at',
                    notification['created_at']?.toString() ?? '',
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Unable to load notification details.'),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
