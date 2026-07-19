import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadBalance extends WalletEvent {}

class SendMoney extends WalletEvent {
  final String? receiverEmail;
  final String? receiverPhone;
  final String? receiverId;
  final int amount;
  final String? note;

  const SendMoney({
    this.receiverEmail,
    this.receiverPhone,
    this.receiverId,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [
    receiverEmail,
    receiverPhone,
    receiverId,
    amount,
    note,
  ];
}

class SendMoneyWithPin extends WalletEvent {
  final String email;
  final String pin;
  final String? receiverEmail;
  final String? receiverPhone;
  final int? receiverId;
  final int amount;
  final String? note;

  const SendMoneyWithPin({
    required this.email,
    required this.pin,
    this.receiverEmail,
    this.receiverPhone,
    this.receiverId,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [
    email,
    pin,
    receiverEmail,
    receiverPhone,
    receiverId,
    amount,
    note,
  ];
}

class DepositMoney extends WalletEvent {
  final int amount;

  const DepositMoney({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class LoadTransactionHistory extends WalletEvent {}

class LoadReceivedMoney extends WalletEvent {}

class LoadRecentTransactions extends WalletEvent {}

class LoadNotifications extends WalletEvent {}

class LoadNotificationDetail extends WalletEvent {
  final int transactionId;

  const LoadNotificationDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class VerifyUser extends WalletEvent {
  final String? email;
  final String? phone;

  const VerifyUser({this.email, this.phone});

  @override
  List<Object?> get props => [email, phone];
}

class GenerateCard extends WalletEvent {
  final String brand; // 'visa', 'mastercard', or 'verve'

  const GenerateCard({required this.brand});

  @override
  List<Object?> get props => [brand];
}

class LoadCards extends WalletEvent {}

class DeleteCard extends WalletEvent {
  final int cardId;

  const DeleteCard({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class ToggleCardStatus extends WalletEvent {
  final int cardId;
  final bool currentStatus;

  const ToggleCardStatus({required this.cardId, required this.currentStatus});

  @override
  List<Object?> get props => [cardId, currentStatus];
}

class FundCard extends WalletEvent {
  final int cardId;
  final int amount;

  const FundCard({required this.cardId, required this.amount});

  @override
  List<Object?> get props => [cardId, amount];
}
