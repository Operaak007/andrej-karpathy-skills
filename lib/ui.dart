import 'package:ak_api_test/screens/auth/login_screen.dart';
import 'package:ak_api_test/screens/home/deposit_screen.dart';
import 'package:ak_api_test/screens/home/history_screen.dart';
import 'package:ak_api_test/screens/home/send_money_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1D1D1F);
  static const _surfaceDeep = Color(0xFF121213);
  static const _purple = Color(0xFF8658FF);
  static const _violet = Color(0xFF6F35F1);
  static const _mint = Color(0xFF27D3A2);
  static const _orange = Color(0xFFFFA31A);

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() {
    context.read<WalletBloc>().add(LoadBalance());
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
        backgroundColor: _background,
        bottomNavigationBar: _buildBottomBar(),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: _purple,
              backgroundColor: _surface,
              onRefresh: () async => _loadBalance(),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildBalancePanel(state),
                      const SizedBox(height: 14),
                      _buildTransferGrid(),
                      const SizedBox(height: 12),
                      _buildRecentTransfer(),
                      const SizedBox(height: 12),
                      _buildServicesGrid(),
                      const SizedBox(height: 12),
                      _buildRewardBanner(),
                      const SizedBox(height: 12),
                      _buildWealthProducts(),
                      const SizedBox(height: 12),
                      _buildPromoBanner(),
                    ],
                  ),
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
            CircleAvatar(
              radius: 20,
              backgroundColor: _surface,
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hi, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _buildTopIcon(Icons.headphones_outlined),
            const SizedBox(width: 14),
            Stack(
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
          ],
        );
      },
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }

  Widget _buildBalancePanel(WalletState state) {
    final display = _balanceLabel(state);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_purple, _violet],
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
                      color: _mint,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        display,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _surfaceDeep,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        minimumSize: const Size(0, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DepositScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Money',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: _surface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.stacked_bar_chart, color: _purple, size: 24),
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
                          style: TextStyle(color: _mint),
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

  Widget _buildTransferGrid() {
    final items = [
      _ActionItem(Icons.account_balance, 'To Bank', _violet, '0 Fee', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
        );
      }),
      _ActionItem(Icons.wallet_rounded, 'To PalmPay', _violet, null, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
        );
      }),
      _ActionItem(Icons.savings_rounded, 'Savings', _violet, null, () {}),
      _ActionItem(Icons.credit_card_rounded, 'ATM Card', _violet, null, () {}),
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
      color: _surface,
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
                  Icon(item.icon, color: item.color, size: 36),
                  if (item.badge != null)
                    Positioned(
                      right: -20,
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransfer() {
    return _section(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Successful',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                SizedBox(height: 5),
                Text(
                  '₦8,000.00 Success',
                  style: TextStyle(color: Color(0xFFB9B9BE), fontSize: 15),
                ),
              ],
            ),
          ),
          Text(
            'Today 2:57 PM',
            style: TextStyle(color: Color(0xFFB9B9BE), fontSize: 15),
          ),
        ],
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
      _ActionItem(Icons.swap_vert_rounded, 'Data', _mint, 'Promo', () {}),
      _ActionItem(
        Icons.sports_soccer_rounded,
        'Betting',
        _mint,
        '10% Off',
        () {},
      ),
      _ActionItem(Icons.bolt_rounded, 'Electricity', _mint, null, () {}),
      _ActionItem(
        Icons.wallet_giftcard_rounded,
        'Refer & Earn',
        _violet,
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
      _ActionItem(Icons.flag_rounded, 'Loan', _mint, null, () {}),
      _ActionItem(Icons.grid_view_rounded, 'More', _violet, null, () {}),
    ];

    return _section(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
      child: GridView.builder(
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
              Icon(item.icon, color: item.color, size: 31),
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
            style: const TextStyle(color: Colors.white, fontSize: 13),
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
                  side: const BorderSide(color: _purple, width: 1.4),
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
              _PagerDot(active: false),
              _PagerDot(active: true),
              _PagerDot(active: false),
              _PagerDot(active: false),
            ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceDeep,
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
                  color: _orange,
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
                  color: _purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.15,
                ),
              ),
              const Spacer(),
              Text(
                yieldText,
                style: const TextStyle(
                  color: _mint,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Maximum Annual Yield',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFFC9C9CD), fontSize: 12),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  minimumSize: const Size(0, 36),
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

  Widget _buildPromoBanner() {
    return Container(
      height: 92,
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

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: Color(0xFF252528))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              _buildNavItem(Icons.home_filled, 'Home', true, () {}),
              _buildNavItem(
                Icons.person_pin_circle_outlined,
                'Loan',
                false,
                () {},
              ),
              _buildNavItem(
                Icons.insert_chart_outlined_rounded,
                'Wealth',
                false,
                () {},
              ),
              _buildNavItem(
                Icons.card_giftcard_rounded,
                'Reward',
                false,
                () {},
              ),
              _buildNavItem(
                Icons.account_circle_outlined,
                'Me',
                false,
                _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final color = active ? _purple : Colors.white;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (label == 'Loan')
                  const Positioned(
                    right: -11,
                    top: -8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFD9414A),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 12, height: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildTinyBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: _orange,
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

  String _balanceLabel(WalletState state) {
    if (state is WalletLoading || state is WalletInitial) {
      return '....';
    }

    if (state is WalletError) {
      return '--';
    }

    return '****';
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFFC9C9CD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem(this.icon, this.label, this.color, this.badge, this.onTap);

  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 16 : 13,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? _HomeScreenState._purple : const Color(0xFF34245D),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
