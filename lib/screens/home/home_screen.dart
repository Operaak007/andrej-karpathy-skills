// ignore_for_file: avoid_print

import 'package:ak_api_test/constants.dart';
import 'package:ak_api_test/screens/home/profile_screen.dart';
import 'package:ak_api_test/screens/home/settings_screen.dart';
import 'package:ak_api_test/util/widget/page_dot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

import '../../bloc/auth/auth_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

import 'send_money_screen.dart';
import 'deposit_screen.dart';
import 'history_screen.dart';
import 'notification_detail_screen.dart';
import 'notification_list_screen.dart';
import 'generate_card_screen.dart';
import 'cards_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const HistoryScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryPurple,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _formatBalance(int? balance) {
    if (balance == null) return '0';
    return balance.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() {
    context.read<WalletBloc>().add(LoadBalance());
  }

  String _userName(AuthState state) {
    if (state is! Authenticated) {
      return 'User';
    }

    final user = state.user;
    final value =
        user['name'] ??
        user['full_name'] ??
        user['username'] ??
        user['email'] ??
        'User';

    return value.toString().trim().isEmpty ? 'User' : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is MoneySent || state is MoneyDeposited) {
          _loadBalance();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryPurple,
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _loadBalance();
                // _buildHeader();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    _buildHeader(),
                    const SizedBox(height: 24),

                    _buildBalancePanel(state),
                    const SizedBox(height: 10),
                    _buildTransferGrid(),
                    const SizedBox(height: 10),
                    _buildServicesGrid(),
                    SizedBox(height: 10),
                    _buildRewardBanner(),
                    SizedBox(height: 10),
                    _buildWealthProducts(),
                    SizedBox(height: 10),
                    _buildPromoBanner(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final name = _userName(authState).toUpperCase();

        return Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondaryPurple,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A3B2E), Color(0xFFB3A58C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hi, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _buildTopIcon(Icons.headphones_outlined),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationListScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTopIcon(Icons.notifications_none_rounded),
                  Positioned(
                    right: -3,
                    top: -7,
                    child: Container(
                      height: 18,
                      width: 18,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF303E),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(WalletState state) {
    int? balance;
    String? displayText;

    print('HomeScreen _buildBalanceCard state: $state'); // Debug log

    if (state is WalletLoading || state is WalletInitial) {
      displayText = '...';
    } else if (state is BalanceLoaded) {
      print('BalanceLoaded: ${state.balance}'); // Debug log
      balance = state.balance;
    } else if (state is MoneySent) {
      print('MoneySent newBalance: ${state.newBalance}'); // Debug log
      balance = state.newBalance;
    } else if (state is MoneyDeposited) {
      print('MoneyDeposited newBalance: ${state.newBalance}'); // Debug log
      balance = state.newBalance;
    } else if (state is WalletError) {
      print('WalletError: ${state.message}'); // Debug log
      displayText = '0';
    }

    // Fallback to Authenticated balance if WalletBloc balance is 0 or null
    if (balance == null || balance == 0) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated && authState.balance > 0) {
        print(
          'Using Authenticated balance as fallback: ${authState.balance}',
        ); // Debug log
        balance = authState.balance;
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '₦',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  displayText ?? _formatBalance(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  final userName =
                      authState.user['name'] ??
                      authState.user['full_name'] ??
                      authState.user['username'] ??
                      authState.user['email'] ??
                      authState.user['balance'] ??
                      'User';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        authState.user['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.send,
            label: 'Send',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle,
            label: 'Deposit',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DepositScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history,
            label: 'History',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.send, color: Colors.blue),
            title: const Text('Send Money'),
            subtitle: const Text('Transfer to another user'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.green,
            ),
            title: const Text('Deposit'),
            subtitle: const Text('Add money to your wallet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DepositScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.orange),
            title: const Text('Transaction History'),
            subtitle: const Text('View all transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 20);
  }

  Widget _buildBalancePanel(WalletState state) {
    int? balance;
    String? displayText;

    print('HomeScreen _buildBalanceCard state: $state'); // Debug log

    if (state is WalletLoading || state is WalletInitial) {
      displayText = '...';
    } else if (state is BalanceLoaded) {
      print('BalanceLoaded: ${state.balance}'); // Debug log
      balance = state.balance;
    } else if (state is MoneySent) {
      print('MoneySent newBalance: ${state.newBalance}'); // Debug log
      balance = state.newBalance;
    } else if (state is MoneyDeposited) {
      print('MoneyDeposited newBalance: ${state.newBalance}'); // Debug log
      balance = state.newBalance;
    } else if (state is WalletError) {
      print('WalletError: ${state.message}'); // Debug log
      displayText = '0';
    }

    // Fallback to Authenticated balance if WalletBloc balance is 0 or null
    if (balance == null || balance == 0) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated && authState.balance > 0) {
        print(
          'Using Authenticated balance as fallback: ${authState.balance}',
        ); // Debug log
        balance = authState.balance;
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.mint,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.chevron_right, size: 20),
                      label: const Text(
                        'Transaction History',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₦${displayText ?? _formatBalance(balance)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DepositScreen()),
                        );
                      },
                      child: Container(
                        height: 25,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Align(
                          alignment: AlignmentGeometry.center,
                          child: Text(
                            "Add Money",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.stacked_bar_chart,
                  color: AppColors.purple,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      children: [
                        TextSpan(text: "Yesterday's Earnings: "),
                        TextSpan(
                          text: '+₦9.30',
                          style: TextStyle(color: AppColors.mint),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWealthProducts() {
    return _section(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildYieldCard(
                  title: 'CashBox',
                  subtitle: 'Your Available Balance, Earning\nfor You Daily!',
                  yieldText: '20.00%',
                  buttonText: '₦1 to Start',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildYieldCard(
                  title: 'Mutual Funds',
                  subtitle: 'Grow your Money while you go!',
                  yieldText: '88.82%',
                  buttonText: 'Invest',
                  topBadge: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC9C9CD),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text(
              'More Wealth Product',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldCard({
    required String title,
    required String subtitle,
    required String yieldText,
    required String buttonText,
    bool topBadge = false,
  }) {
    return Container(
      height: 172,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (topBadge)
            Positioned(
              right: -21,
              top: -21,
              child: Transform.rotate(
                angle: .78,
                child: Container(
                  color: AppColors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 2,
                  ),
                  child: const Text(
                    'Top',
                    style: TextStyle(color: Colors.black, fontSize: 11),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                yieldText,
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Maximum Annual Yield',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFFC9C9CD), fontSize: 12),
              ),
              const SizedBox(height: 5),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  buttonText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferGrid() {
    final items = [
      // _ActionItem(
      //   Icons.account_balance,
      //   'To Bank',
      //   AppColors.violet,
      //   '0 Fee',
      //   () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
      //     );
      //   },
      // ),
      _ActionItem(
        Icons.wallet_rounded,
        'To Wallet',
        AppColors.violet,
        null,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
          );
        },
      ),
      _ActionItem(
        Icons.savings_rounded,
        'Savings',
        AppColors.violet,
        null,
        () {},
      ),

      _ActionItem(Icons.credit_card, "MY CARDS", AppColors.mint, null, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CardsListScreen()),
        );
      }),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _buildLargeAction(items[i])),
          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildLargeAction(_ActionItem item) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon, color: item.AppColors, size: 25),
                  if (item.badge != null)
                    Positioned(
                      right: -25,
                      top: -7,
                      child: _buildTinyBadge(item.badge!),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTinyBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    final items = [
      _ActionItem(
        Icons.phone_in_talk_rounded,
        'Airtime',
        Colors.blue,
        null,
        () {},
      ),
      _ActionItem(
        Icons.swap_vert_rounded,
        'Data',
        AppColors.mint,
        'Promo',
        () {},
      ),
      _ActionItem(
        Icons.sports_soccer_rounded,
        'Betting',
        AppColors.mint,
        '10% Off',
        () {},
      ),
      _ActionItem(
        Icons.bolt_rounded,
        'Electricity',
        AppColors.mint,
        null,
        () {},
      ),
      _ActionItem(
        Icons.wallet_giftcard_rounded,
        'Refer & Earn',
        AppColors.violet,
        null,
        () {},
      ),
      _ActionItem(
        Icons.assured_workload_rounded,
        'Insurance',
        Colors.blue,
        'FREE',
        () {},
      ),
      _ActionItem(Icons.flag_rounded, 'Loan', AppColors.mint, null, () {}),
      _ActionItem(
        Icons.grid_view_rounded,
        'More',
        AppColors.violet,
        null,
        () {},
      ),
    ];

    return _section(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 74,
          crossAxisSpacing: 6,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) => _buildSmallAction(items[index]),
      ),
    );
  }

  Widget _section({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildSmallAction(_ActionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, color: item.AppColors, size: 25),
              if (item.badge != null)
                Positioned(
                  right: -23,
                  top: -8,
                  child: _buildTinyBadge(item.badge!),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

Widget _buildPromoBanner() {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
    decoration: BoxDecoration(
      color: const Color(0xFF347325),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROAD TO THE TROPHY',
          style: TextStyle(
            color: Color(0xFFD8EBD0),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 3),
        Text(
          '₦10,000,000',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Play, win, and claim your reward',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget _buildRewardBanner() {
  return _section(
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF163C11), Color(0xFF3AA33E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                '₦2500\nEach Share',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '100% Cash Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Earn up to ₦2500 per invite',
                    style: TextStyle(color: Color(0xFFC9C9CD), fontSize: 15),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB38DFF),
                side: const BorderSide(color: AppColors.purple, width: 1.4),
                minimumSize: const Size(82, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {},
              child: const Text('Claim'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            PagerDot(active: false),
            PagerDot(active: true),
            PagerDot(active: false),
            PagerDot(active: false),
          ],
        ),
      ],
    ),
  );
}

Widget _section({required Widget child, EdgeInsetsGeometry? padding}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );
}

class _ActionItem {
  const _ActionItem(
    this.icon,
    this.label,
    this.AppColors,
    this.badge,
    this.onTap,
  );

  final IconData icon;
  final String label;
  final AppColors;
  final String? badge;
  final VoidCallback onTap;
}
