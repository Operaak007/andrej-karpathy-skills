import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/card_storage.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final ApiService _apiService;

  WalletBloc(this._apiService) : super(WalletInitial()) {
    on<LoadBalance>(_onLoadBalance);
    on<SendMoney>(_onSendMoney);
    on<SendMoneyWithPin>(_onSendMoneyWithPin);
    on<DepositMoney>(_onDepositMoney);
    on<LoadTransactionHistory>(_onLoadTransactionHistory);
    on<LoadReceivedMoney>(_onLoadReceivedMoney);
    on<VerifyUser>(_onVerifyUser);
    on<GenerateCard>(_onGenerateCard);
    on<LoadCards>(_onLoadCards);
    on<DeleteCard>(_onDeleteCard);
    on<ToggleCardStatus>(_onToggleCardStatus);
    on<FundCard>(_onFundCard);
  }

  Future<void> _onLoadBalance(
    LoadBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post('/wallet/balance');
      print('Balance Response: $response'); // Debug log

      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      print('Balance data: $data'); // Debug log

      // Try multiple possible balance field names and handle both int and String
      int balance = 0;
      final balanceKeys = [
        'balance',
        'wallet_balance',
        'current_balance',
        'available_balance',
        'amount',
      ];

      for (final key in balanceKeys) {
        if (data.containsKey(key)) {
          balance = _parseBalance(data[key]);
          if (balance > 0) break;
        }
      }
      print('Parsed balance: $balance'); // Debug log

      emit(BalanceLoaded(balance));
    } on ApiException catch (e) {
      print('LoadBalance ApiException: ${e.message}'); // Debug log
      emit(WalletError(e.message));
    } catch (e) {
      print('LoadBalance error: $e'); // Debug log
      emit(WalletError(e.toString()));
    }
  }

  // Helper method to parse balance from various formats
  int _parseBalance(dynamic balanceValue) {
    if (balanceValue == null) return 0;

    // Handle String
    if (balanceValue is String) {
      final parsed = double.tryParse(balanceValue);
      return parsed?.toInt() ?? 0;
    }

    // Handle int
    if (balanceValue is int) return balanceValue;

    // Handle double
    if (balanceValue is double) return balanceValue.toInt();

    // Handle num
    if (balanceValue is num) return balanceValue.toInt();

    // Handle Map
    if (balanceValue is Map) {
      final value =
          balanceValue['value'] ??
          balanceValue['amount'] ??
          balanceValue['balance'];
      return _parseBalance(value);
    }

    return 0;
  }

  Future<void> _onSendMoney(SendMoney event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final body = <String, dynamic>{'amount': event.amount};
      if (event.receiverEmail != null) body['to_email'] = event.receiverEmail;
      if (event.receiverPhone != null) body['to_phone'] = event.receiverPhone;
      if (event.receiverId != null) body['to_user_id'] = event.receiverId;
      if (event.note != null) body['note'] = event.note;

      final response = await _apiService.post('/wallet/send', body: body);
      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      final newBalance = data['balance'] as int? ?? 0;
      emit(
        MoneySent(
          message: data['message'] ?? 'Money sent successfully',
          newBalance: newBalance,
        ),
      );
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onSendMoneyWithPin(
    SendMoneyWithPin event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final body = <String, dynamic>{
        'email': event.email,
        'pin': event.pin,
        'amount': event.amount,
      };
      if (event.receiverEmail != null) body['to_email'] = event.receiverEmail;
      if (event.receiverPhone != null) body['to_phone'] = event.receiverPhone;
      if (event.receiverId != null) body['to_user_id'] = event.receiverId;
      if (event.note != null) body['note'] = event.note;

      final response = await _apiService.post('/wallet/send-pin', body: body);
      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      final newBalance = data['balance'] as int? ?? 0;
      emit(
        MoneySent(
          message: data['message'] ?? 'Money sent successfully',
          newBalance: newBalance,
        ),
      );
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onDepositMoney(
    DepositMoney event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post(
        '/wallet/deposit',
        body: {'amount': event.amount},
      );
      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      // Handle balance as either int or String
      final balanceValue = data['balance'];
      final int newBalance;
      if (balanceValue is int) {
        newBalance = balanceValue;
      } else if (balanceValue is String) {
        newBalance = int.tryParse(balanceValue) ?? 0;
      } else {
        newBalance = 0;
      }
      emit(
        MoneyDeposited(
          message: data['message'] ?? 'Deposit successful',
          newBalance: newBalance,
        ),
      );
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionHistory(
    LoadTransactionHistory event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post('/wallet/history');
      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      final transactions = data['transactions'] as List<dynamic>? ?? [];
      emit(TransactionHistoryLoaded(transactions));
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onLoadReceivedMoney(
    LoadReceivedMoney event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post('/wallet/received');
      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      final received = data['received'] as List<dynamic>? ?? [];
      emit(ReceivedMoneyLoaded(received));
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onVerifyUser(
    VerifyUser event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final body = <String, dynamic>{};
      if (event.email != null) body['email'] = event.email;
      if (event.phone != null) body['phone'] = event.phone;

      final response = await _apiService.post(
        '/wallet/verify-user',
        body: body,
      );

      if (response['verified'] == true && response['user'] != null) {
        final user = response['user'] as Map<String, dynamic>;
        emit(
          UserVerified(
            userId: user['id'].toString(),
            userName: user['name'] as String,
            userEmail: user['email'] as String,
            userPhone: user['phone'] as String,
          ),
        );
      } else {
        emit(const WalletError('User not found'));
      }
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onGenerateCard(
    GenerateCard event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post(
        '/card/generate',
        body: {'brand': event.brand},
      );
      print('Generate Card Response: $response'); // Debug log

      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;
      print('Generate Card data: $data'); // Debug log

      // Card may be nested under data.card OR be the data itself
      Map<String, dynamic> card = {};
      if (data['card'] is Map<String, dynamic>) {
        card = data['card'] as Map<String, dynamic>;
      } else if (data['card'] != null && data['card'] is Map) {
        card = Map<String, dynamic>.from(data['card'] as Map);
      } else {
        // Some APIs return card fields directly on data
        final cardKeys = [
          'card_number',
          'card_brand',
          'expiry',
          'cvv',
          'pin',
          'brand',
        ];
        final hasCardFields = cardKeys.any((k) => data.containsKey(k));
        if (hasCardFields) {
          card = Map<String, dynamic>.from(data);
        }
      }
      print('Generate Card parsed card: $card'); // Debug log

      // Persist card locally so it appears on the cards list screen
      if (card.isNotEmpty) {
        await CardStorage.saveCard(card);
        print('Card saved to local storage'); // Debug log
      }

      final charge = _parseBalance(data['charge']);
      final remainingBalance = _parseBalance(
        data['remaining_balance'] ?? data['balance'] ?? data['wallet_balance'],
      );

      emit(
        CardGenerated(
          message: data['message'] ?? 'Card generated successfully',
          card: card,
          charge: charge,
          remainingBalance: remainingBalance,
        ),
      );
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onLoadCards(LoadCards event, Emitter<WalletState> emit) async {
    emit(WalletLoading());

    // Try multiple endpoint paths the server might support
    const endpoints = ['/card/list'];

    Map<String, dynamic>? lastError;
    for (final endpoint in endpoints) {
      try {
        print('Trying cards endpoint: $endpoint'); // Debug log
        final response = await _apiService.get(endpoint);
        print('Cards List Response: $response'); // Debug log

        // Handle nested response structure
        final data = response.containsKey('data')
            ? response['data'] as Map<String, dynamic>
            : response;
        print('Cards List data keys: ${data.keys.toList()}'); // Debug log
        print('Cards List data: $data'); // Debug log

        // Try multiple possible keys the API might use for the cards list
        List<dynamic> cardsRaw = [];
        if (data['cards'] is List) {
          cardsRaw = data['cards'] as List;
          print('Found cards under data["cards"]'); // Debug log
        } else if (data['card'] is List) {
          cardsRaw = data['card'] as List;
          print('Found cards under data["card"]'); // Debug log
        } else if (data['card'] is Map) {
          // API returns a single card object (not a list) — wrap it
          cardsRaw = [data['card']];
          print(
            'Found single card under data["card"], wrapped in list',
          ); // Debug log
        } else if (data['data'] is List) {
          cardsRaw = data['data'] as List;
          print('Found cards under data["data"]'); // Debug log
        } else if (data['data'] is Map) {
          // Cards nested under data.data with a list inside
          final nested = data['data'] as Map<String, dynamic>;
          if (nested['cards'] is List) {
            cardsRaw = nested['cards'] as List;
            print('Found cards under data.data["cards"]'); // Debug log
          } else if (nested['card'] is List) {
            cardsRaw = nested['card'] as List;
            print('Found cards under data.data["card"]'); // Debug log
          }
        } else if (data['all_cards'] is List) {
          cardsRaw = data['all_cards'] as List;
          print('Found cards under data["all_cards"]'); // Debug log
        } else if (data['user_cards'] is List) {
          cardsRaw = data['user_cards'] as List;
          print('Found cards under data["user_cards"]'); // Debug log
        } else {
          // No known list key found — dump all keys for debugging
          print(
            'No known cards key found. Dumping all data keys: ${data.keys.toList()}',
          ); // Debug log
        }

        final cards = cardsRaw.whereType<Map<String, dynamic>>().toList(
          growable: false,
        );
        print('Cards List parsed ${cards.length} cards'); // Debug log
        if (cards.isNotEmpty) {
          print('First card keys: ${cards.first.keys.toList()}'); // Debug log
        }

        emit(
          CardsLoaded(
            message: data['message'] ?? 'Cards retrieved',
            cards: cards,
          ),
        );
        return; // Success — exit the loop
      } on ApiException catch (e) {
        print(
          'Endpoint $endpoint failed: ${e.message} (${e.statusCode})',
        ); // Debug log
        lastError = {
          'endpoint': endpoint,
          'message': e.message,
          'statusCode': e.statusCode,
        };
        continue; // Try next endpoint
      } catch (e) {
        print('Endpoint $endpoint threw: $e'); // Debug log
        lastError = {'endpoint': endpoint, 'message': e.toString()};
        continue; // Try next endpoint
      }
    }

    // All server endpoints failed — fall back to locally saved cards
    print(
      'All server endpoints failed, loading cards from local storage',
    ); // Debug log
    final localCards = await CardStorage.loadCards();
    print('Loaded ${localCards.length} cards from local storage'); // Debug log

    if (localCards.isNotEmpty) {
      emit(CardsLoaded(message: 'Cards loaded from device', cards: localCards));
    } else {
      // No local cards either — show the last server error
      final msg = lastError?['message'] ?? 'No cards found';
      emit(WalletError(msg));
    }
  }

  Future<void> _onDeleteCard(
    DeleteCard event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post(
        '/card/delete',
        body: {'card_id': event.cardId},
      );
      print('Delete Card Response: $response'); // Debug log

      // Handle nested response structure
      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;

      // Check for error responses
      if (response['message']?.toString().contains('balance') == true) {
        final balance = _parseBalance(data['balance']);
        emit(
          CardDeleteError(
            message: data['message'] ?? 'Cannot delete card with balance',
            balance: balance,
          ),
        );
        return;
      }

      if (response['message']?.toString().contains('not found') == true) {
        emit(const WalletError('Card not found'));
        return;
      }

      // Remove card from local storage
      await CardStorage.deleteCard(event.cardId);

      emit(
        CardDeleted(
          message: data['message'] ?? 'Card deleted successfully',
          cardId: event.cardId,
        ),
      );

      // Reload cards after deletion
      add(LoadCards());
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onToggleCardStatus(
    ToggleCardStatus event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post(
        '/card/toggle-status',
        body: {'card_id': event.cardId},
      );
      print('Toggle Card Response: $response'); // Debug log

      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;

      final isActive = data['is_active'] == true || data['is_active'] == 1;

      // Update local storage
      await CardStorage.updateCardStatus(event.cardId, isActive);

      emit(
        CardToggled(
          message: data['message'] ?? 'Card status updated',
          cardId: event.cardId,
          isActive: isActive,
        ),
      );

      // Reload cards to reflect the change
      add(LoadCards());
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onFundCard(FundCard event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final response = await _apiService.post(
        '/card/fund',
        body: {'card_id': event.cardId, 'amount': event.amount},
      );
      print('Fund Card Response: $response'); // Debug log

      final data = response.containsKey('data')
          ? response['data'] as Map<String, dynamic>
          : response;

      final cardBalance = _parseBalance(
        data['card_balance'] ?? data['balance'] ?? data['new_balance'],
      );
      final walletBalance = _parseBalance(data['wallet_balance']);

      // Update local storage balance if card is saved locally
      await CardStorage.updateCardBalance(event.cardId, cardBalance);

      emit(
        CardFunded(
          message: data['message'] ?? 'Card funded successfully',
          cardId: event.cardId,
          amount: event.amount,
          cardBalance: cardBalance,
          walletBalance: walletBalance,
        ),
      );

      // Reload cards to reflect the new balance
      add(LoadCards());
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
