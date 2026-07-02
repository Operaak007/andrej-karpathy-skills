import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class BalanceLoaded extends WalletState {
  final int balance;

  const BalanceLoaded(this.balance);

  @override
  List<Object?> get props => [balance];
}

class MoneySent extends WalletState {
  final String message;
  final int newBalance;

  const MoneySent({required this.message, required this.newBalance});

  @override
  List<Object?> get props => [message, newBalance];
}

class MoneyDeposited extends WalletState {
  final String message;
  final int newBalance;

  const MoneyDeposited({required this.message, required this.newBalance});

  @override
  List<Object?> get props => [message, newBalance];
}

class TransactionHistoryLoaded extends WalletState {
  final List<dynamic> transactions;

  const TransactionHistoryLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class ReceivedMoneyLoaded extends WalletState {
  final List<dynamic> received;

  const ReceivedMoneyLoaded(this.received);

  @override
  List<Object?> get props => [received];
}

class UserVerified extends WalletState {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;

  const UserVerified({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  List<Object?> get props => [userId, userName, userEmail, userPhone];
}

class CardGenerated extends WalletState {
  final String message;
  final Map<String, dynamic> card;
  final int charge;
  final int remainingBalance;

  const CardGenerated({
    required this.message,
    required this.card,
    required this.charge,
    required this.remainingBalance,
  });

  @override
  List<Object?> get props => [message, card, charge, remainingBalance];
}

class CardsLoaded extends WalletState {
  final String message;
  final List<Map<String, dynamic>> cards;

  const CardsLoaded({required this.message, required this.cards});

  @override
  List<Object?> get props => [message, cards];
}

class CardDeleted extends WalletState {
  final String message;
  final int cardId;

  const CardDeleted({required this.message, required this.cardId});

  @override
  List<Object?> get props => [message, cardId];
}

class CardDeleteError extends WalletState {
  final String message;
  final int? balance;

  const CardDeleteError({required this.message, this.balance});

  @override
  List<Object?> get props => [message, balance];
}

class CardToggled extends WalletState {
  final String message;
  final int cardId;
  final bool isActive;

  const CardToggled({
    required this.message,
    required this.cardId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [message, cardId, isActive];
}

class CardFunded extends WalletState {
  final String message;
  final int cardId;
  final int amount;
  final int cardBalance;
  final int walletBalance;

  const CardFunded({
    required this.message,
    required this.cardId,
    required this.amount,
    required this.cardBalance,
    required this.walletBalance,
  });

  @override
  List<Object?> get props => [
    message,
    cardId,
    amount,
    cardBalance,
    walletBalance,
  ];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
