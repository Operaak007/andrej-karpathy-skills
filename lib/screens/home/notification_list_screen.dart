import 'package:ak_api_test/screens/home/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            final message = state.message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = state is NotificationsLoaded
              ? state.notifications
              : [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = Map<String, dynamic>.from(
                notifications[index] as Map,
              );
              final title = notification['title']?.toString() ?? 'Notification';
              final subtitle = notification['subtitle']?.toString() ?? '';
              final amount = notification['amount']?.toString() ?? '';
              final createdAt = notification['created_at']?.toString() ?? '';
              final transactionId = int.tryParse(
                notification['transaction_id']?.toString() ?? '',
              );

              return ListTile(
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: Text('NGN $amount'),
                onTap: transactionId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailScreen(
                              transactionId: transactionId,
                            ),
                          ),
                        );
                      },
                isThreeLine: true,
                dense: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
