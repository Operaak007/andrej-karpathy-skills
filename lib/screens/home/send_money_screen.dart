// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../bloc/wallet/wallet_bloc.dart';
// import '../../bloc/wallet/wallet_event.dart';
// import '../../bloc/wallet/wallet_state.dart';
// import '../../services/recent_transactions_storage.dart';

// class SendMoneyScreen extends StatefulWidget {
//   const SendMoneyScreen({super.key});

//   @override
//   State<SendMoneyScreen> createState() => _SendMoneyScreenState();
// }

// class _SendMoneyScreenState extends State<SendMoneyScreen> {
//   String _formatBalance(int balance) {
//     return balance.toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//   }

//   String _formatAmount(int amount) {
//     return amount.toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]},',
//     );
//   }

//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _noteController = TextEditingController();
//   int _selectedMethod = 0; // 0 = email, 1 = phone
//   bool _userVerified = false;
//   String? _verifiedUserId;
//   String? _verifiedUserName;
//   String? _verifiedUserEmail;
//   String? _verifiedUserPhone;
//   Timer? _debounce;
//   List<Map<String, dynamic>> _recentTransactions = [];
//   bool _showRecentTransactions = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRecentTransactions();
//   }

//   Future<void> _loadRecentTransactions() async {
//     final transactions = await RecentTransactionsStorage.loadTransactions();
//     if (mounted) {
//       setState(() {
//         _recentTransactions = transactions;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _amountController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   void _onRecipientChanged(String value) {
//     _debounce?.cancel();
//     if (value.isEmpty) {
//       setState(() {
//         _userVerified = false;
//         _verifiedUserId = null;
//         _verifiedUserName = null;
//         _verifiedUserEmail = null;
//         _verifiedUserPhone = null;
//       });
//       return;
//     }
//     _debounce = Timer(const Duration(milliseconds: 800), () {
//       _verifyUser();
//     });
//   }

//   void _verifyUser() {
//     final identifier = _selectedMethod == 0
//         ? _emailController.text.trim()
//         : _phoneController.text.trim();

//     if (identifier.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             _selectedMethod == 0
//                 ? 'Please enter recipient email'
//                 : 'Please enter recipient phone',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     context.read<WalletBloc>().add(
//       VerifyUser(
//         email: _selectedMethod == 0 ? identifier : null,
//         phone: _selectedMethod == 1 ? identifier : null,
//       ),
//     );
//   }

//   void _selectRecentTransaction(Map<String, dynamic> transaction) {
//     setState(() {
//       _selectedMethod = transaction['method'] == 'email' ? 0 : 1;
//       if (_selectedMethod == 0) {
//         _emailController.text = transaction['receiver_email'] ?? '';
//       } else {
//         _phoneController.text = transaction['receiver_phone'] ?? '';
//       }
//       _userVerified = true;
//       _verifiedUserId = transaction['receiver_id']?.toString();
//       _verifiedUserName = transaction['receiver_name'];
//       _verifiedUserEmail = transaction['receiver_email'];
//       _verifiedUserPhone = transaction['receiver_phone'];
//     });
//     _verifyUser();
//   }

//   void _sendMoney() {
//     if (!_userVerified || _verifiedUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please verify recipient first'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//       final amount = int.tryParse(_amountController.text);
//       if (amount == null || amount <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enter a valid amount'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       context.read<WalletBloc>().add(
//         SendMoney(
//           amount: amount,
//           receiverId: _verifiedUserId,
//           receiverEmail: _selectedMethod == 0
//               ? _emailController.text.trim()
//               : null,
//           receiverPhone: _selectedMethod == 1
//               ? _phoneController.text.trim()
//               : null,
//           note: _noteController.text.trim().isNotEmpty
//               ? _noteController.text.trim()
//               : null,
//         ),
//       );
//     }
//   }

//   Future<void> _saveRecentTransaction({
//     required String receiverId,
//     required String receiverName,
//     required String? receiverEmail,
//     required String? receiverPhone,
//     required int amount,
//   }) async {
//     await RecentTransactionsStorage.saveTransaction({
//       'receiver_id': receiverId,
//       'receiver_name': receiverName,
//       'receiver_email': receiverEmail,
//       'receiver_phone': receiverPhone,
//       'amount': amount,
//       'method': _selectedMethod == 0 ? 'email' : 'phone',
//     });
//     await _loadRecentTransactions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Modern App Bar with gradient
//           SliverAppBar(
//             expandedHeight: 180,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF667eea),
//                       Color(0xFF764ba2),
//                     ],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 40),
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.send_rounded,
//                           size: 48,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         'Send Money',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Text(
//                         'Transfer to friends & family',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             backgroundColor: const Color(0xFF667eea),
//             foregroundColor: Colors.white,
//           ),
//           // Content
//           SliverToBoxAdapter(
//             child: BlocConsumer<WalletBloc, WalletState>(
//               listener: (context, state) {
//                 if (state is MoneySent) {
//                   // Save to recent transactions
//                   if (_verifiedUserId != null && _verifiedUserName != null) {
//                     final amount = int.tryParse(_amountController.text) ?? 0;
//                     _saveRecentTransaction(
//                       receiverId: _verifiedUserId!,
//                       receiverName: _verifiedUserName!,
//                       receiverEmail: _verifiedUserEmail,
//                       receiverPhone: _verifiedUserPhone,
//                       amount: amount,
//                     );
//                   }
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Row(
//                         children: [
//                           const Icon(Icons.check_circle, color: Colors.white),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Transfer Successful!',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   'New Balance: ₦${_formatBalance(state.newBalance)}',
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       backgroundColor: Colors.green,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                   Navigator.pop(context);
//                 } else if (state is WalletError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Row(
//                         children: [
//                           const Icon(Icons.error_outline, color: Colors.white),
//                           const SizedBox(width: 12),
//                           Expanded(child: Text(state.message)),
//                         ],
//                       ),
//                       backgroundColor: Colors.red,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                   setState(() {
//                     _userVerified = false;
//                     _verifiedUserId = null;
//                     _verifiedUserName = null;
//                     _verifiedUserEmail = null;
//                     _verifiedUserPhone = null;
//                   });
//                 } else if (state is UserVerified) {
//                   setState(() {
//                     _userVerified = true;
//                     _verifiedUserId = state.userId;
//                     _verifiedUserName = state.userName;
//                     _verifiedUserEmail = state.userEmail;
//                     _verifiedUserPhone = state.userPhone;
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Row(
//                         children: [
//                           const Icon(Icons.verified, color: Colors.white),
//                           const SizedBox(width: 12),
//                           Text('User verified: ${state.userName}'),
//                         ],
//                       ),
//                       backgroundColor: Colors.green,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 return Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Recent Transactions Section
//                         if (_recentTransactions.isNotEmpty && _showRecentTransactions) ...[
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Icon(Icons.history, size: 20, color: Color(0xFF667eea)),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Recent',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _showRecentTransactions = false;
//                                   });
//                                 },
//                                 child: const Text('Hide'),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           SizedBox(
//                             height: 100,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: _recentTransactions.length,
//                               itemBuilder: (context, index) {
//                                 final transaction = _recentTransactions[index];
//                                 return _buildRecentTransactionCard(transaction);
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                         ],
//                         // Recipient Section
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Row(
//                                   children: [
//                                     Icon(Icons.person_outline, color: Color(0xFF667eea)),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Recipient',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 // Method Selection Tabs
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             setState(() {
//                                               _selectedMethod = 0;
//                                               _userVerified = false;
//                                             });
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(vertical: 12),
//                                             decoration: BoxDecoration(
//                                               color: _selectedMethod == 0
//                                                   ? const Color(0xFF667eea)
//                                                   : Colors.transparent,
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.email_outlined,
//                                                   size: 18,
//                                                   color: _selectedMethod == 0
//                                                       ? Colors.white
//                                                       : Colors.grey.shade600,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   'Email',
//                                                   style: TextStyle(
//                                                     color: _selectedMethod == 0
//                                                         ? Colors.white
//                                                         : Colors.grey.shade600,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             setState(() {
//                                               _selectedMethod = 1;
//                                               _userVerified = false;
//                                             });
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(vertical: 12),
//                                             decoration: BoxDecoration(
//                                               color: _selectedMethod == 1
//                                                   ? const Color(0xFF667eea)
//                                                   : Colors.transparent,
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.phone_outlined,
//                                                   size: 18,
//                                                   color: _selectedMethod == 1
//                                                       ? Colors.white
//                                                       : Colors.grey.shade600,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   'Phone',
//                                                   style: TextStyle(
//                                                     color: _selectedMethod == 1
//                                                         ? Colors.white
//                                                         : Colors.grey.shade600,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 if (_selectedMethod == 0)
//                                   TextFormField(
//                                     controller: _emailController,
//                                     keyboardType: TextInputType.emailAddress,
//                                     decoration: InputDecoration(
//                                       labelText: 'Recipient Email',
//                                       prefixIcon: const Icon(Icons.email_outlined),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter recipient email';
//                                       }
//                                       if (!value.contains('@')) {
//                                         return 'Please enter a valid email';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: _onRecipientChanged,
//                                   )
//                                 else
//                                   TextFormField(
//                                     controller: _phoneController,
//                                     keyboardType: TextInputType.phone,
//                                     decoration: InputDecoration(
//                                       labelText: 'Recipient Phone',
//                                       prefixIcon: const Icon(Icons.phone_outlined),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       filled: true,
//                                       fillColor: Colors.grey.shade50,
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter recipient phone';
//                                       }
//                                       return null;
//                                     },
//                                     onChanged: _onRecipientChanged,
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Verification Status
//                         if (state is WalletLoading && !_userVerified) ...[
//                           Card(
//                             elevation: 1,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Color(0xFF667eea),
//                                     ),
//                                   ),
//                                   SizedBox(width: 12),
//                                   Text('Verifying recipient...'),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                         if (_userVerified && _verifiedUserName != null) ...[
//                           Card(
//                             elevation: 2,
//                             color: Colors.green.shade50,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 56,
//                                     height: 56,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                                       ),
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         _verifiedUserName![0].toUpperCase(),
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 24,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Text(
//                                               _verifiedUserName!,
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Container(
//                                               padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8,
//                                                 vertical: 2,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.green,
//                                                 borderRadius: BorderRadius.circular(12),
//                                               ),
//                                               child: const Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.check,
//                                                     size: 12,
//                                                     color: Colors.white,
//                                                   ),
//                                                   SizedBox(width: 4),
//                                                   Text(
//                                                     'Verified',
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 10,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           _selectedMethod == 0
//                                               ? _emailController.text
//                                               : _phoneController.text,
//                                           style: TextStyle(
//                                             color: Colors.grey.shade600,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                         // Amount Section
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Row(
//                                   children: [
//                                     Icon(Icons.attach_money, color: Color(0xFF667eea)),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Amount',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 TextFormField(
//                                   controller: _amountController,
//                                   keyboardType: TextInputType.number,
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   decoration: InputDecoration(
//                                     prefixText: '₦ ',
//                                     prefixStyle: const TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF667eea),
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.grey.shade50,
//                                     hintText: '0',
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter amount';
//                                     }
//                                     final amount = int.tryParse(value);
//                                     if (amount == null || amount <= 0) {
//                                       return 'Please enter a valid amount';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Note Section
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Row(
//                                   children: [
//                                     Icon(Icons.note_outlined, color: Color(0xFF667eea)),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Note (Optional)',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 TextFormField(
//                                   controller: _noteController,
//                                   maxLines: 2,
//                                   decoration: InputDecoration(
//                                     hintText: 'Add a note for this transfer...',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     filled: true,
//                                     fillColor: Colors.grey.shade50,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         // Send Button
//                         SizedBox(
//                           height: 56,
//                           child: ElevatedButton(
//                             onPressed: state is WalletLoading ? null : _sendMoney,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF667eea),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               elevation: 4,
//                             ),
//                             child: state is WalletLoading
//                                 ? const SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.send_rounded),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         'Send Money',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentTransactionCard(Map<String, dynamic> transaction) {
//     final name = transaction['receiver_name'] ?? 'Unknown';
//     final amount = transaction['amount'] ?? 0;

//     return GestureDetector(
//       onTap: () => _selectRecentTransaction(transaction),
//       child: Container(
//         width: 100,
//         margin: const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white,
//               Colors.grey.shade50,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Text(
//                   name.isNotEmpty ? name[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 2),
//             Text(
//               '₦${_formatAmount(amount)}',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 11,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../services/recent_transactions_storage.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String _formatBalance(int balance) {
    return balance.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedMethod = 0; // 0 = email, 1 = phone
  bool _userVerified = false;
  String? _verifiedUserId;
  String? _verifiedUserName;
  String? _verifiedUserEmail;
  String? _verifiedUserPhone;
  Timer? _debounce;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _showRecentTransactions = true;

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
  }

  Future<void> _loadRecentTransactions() async {
    final transactions = await RecentTransactionsStorage.loadTransactions();
    if (mounted) {
      setState(() {
        _recentTransactions = transactions;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onRecipientChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _userVerified = false;
        _verifiedUserId = null;
        _verifiedUserName = null;
        _verifiedUserEmail = null;
        _verifiedUserPhone = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _verifyUser();
    });
  }

  void _verifyUser() {
    final identifier = _selectedMethod == 0
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedMethod == 0
                ? 'Please enter recipient email'
                : 'Please enter recipient phone',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<WalletBloc>().add(
      VerifyUser(
        email: _selectedMethod == 0 ? identifier : null,
        phone: _selectedMethod == 1 ? identifier : null,
      ),
    );
  }

  void _selectRecentTransaction(Map<String, dynamic> transaction) {
    setState(() {
      _selectedMethod = transaction['method'] == 'email' ? 0 : 1;
      if (_selectedMethod == 0) {
        _emailController.text = transaction['receiver_email'] ?? '';
      } else {
        _phoneController.text = transaction['receiver_phone'] ?? '';
      }
      _userVerified = true;
      _verifiedUserId = transaction['receiver_id']?.toString();
      _verifiedUserName = transaction['receiver_name'];
      _verifiedUserEmail = transaction['receiver_email'];
      _verifiedUserPhone = transaction['receiver_phone'];
    });
    _verifyUser();
  }

  void _sendMoney() {
    if (!_userVerified || _verifiedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify recipient first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final amount = int.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<WalletBloc>().add(
        SendMoney(
          amount: amount,
          receiverId: _verifiedUserId,
          receiverEmail: _selectedMethod == 0
              ? _emailController.text.trim()
              : null,
          receiverPhone: _selectedMethod == 1
              ? _phoneController.text.trim()
              : null,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        ),
      );
    }
  }

  Future<void> _saveRecentTransaction({
    required String receiverId,
    required String receiverName,
    required String? receiverEmail,
    required String? receiverPhone,
    required int amount,
  }) async {
    await RecentTransactionsStorage.saveTransaction({
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_email': receiverEmail,
      'receiver_phone': receiverPhone,
      'amount': amount,
      'method': _selectedMethod == 0 ? 'email' : 'phone',
    });
    await _loadRecentTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Send Money',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Transfer to friends & family',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
          ),
          // Content
          SliverToBoxAdapter(
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {
                if (state is MoneySent) {
                  // Save to recent transactions
                  if (_verifiedUserId != null && _verifiedUserName != null) {
                    final amount = int.tryParse(_amountController.text) ?? 0;
                    _saveRecentTransaction(
                      receiverId: _verifiedUserId!,
                      receiverName: _verifiedUserName!,
                      receiverEmail: _verifiedUserEmail,
                      receiverPhone: _verifiedUserPhone,
                      amount: amount,
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Transfer Successful!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'New Balance: ₦${_formatBalance(state.newBalance)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                } else if (state is WalletError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(state.message)),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  setState(() {
                    _userVerified = false;
                    _verifiedUserId = null;
                    _verifiedUserName = null;
                    _verifiedUserEmail = null;
                    _verifiedUserPhone = null;
                  });
                } else if (state is UserVerified) {
                  setState(() {
                    _userVerified = true;
                    _verifiedUserId = state.userId;
                    _verifiedUserName = state.userName;
                    _verifiedUserEmail = state.userEmail;
                    _verifiedUserPhone = state.userPhone;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('User verified: ${state.userName}'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Recent Transactions Section
                        if (_recentTransactions.isNotEmpty &&
                            _showRecentTransactions) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 20,
                                    color: Color(0xFF667eea),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Recent',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showRecentTransactions = false;
                                  });
                                },
                                child: const Text('Hide'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _recentTransactions[index];
                                return _buildRecentTransactionCard(transaction);
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Recipient Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF667eea),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Recipient',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Method Selection Tabs
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedMethod = 0;
                                              _userVerified = false;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _selectedMethod == 0
                                                  ? const Color(0xFF667eea)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.email_outlined,
                                                  size: 18,
                                                  color: _selectedMethod == 0
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Email',
                                                  style: TextStyle(
                                                    color: _selectedMethod == 0
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedMethod = 1;
                                              _userVerified = false;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _selectedMethod == 1
                                                  ? const Color(0xFF667eea)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone_outlined,
                                                  size: 18,
                                                  color: _selectedMethod == 1
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Phone',
                                                  style: TextStyle(
                                                    color: _selectedMethod == 1
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_selectedMethod == 0)
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Recipient Email',
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter recipient email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    onChanged: _onRecipientChanged,
                                  )
                                else
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Recipient Phone',
                                      prefixIcon: const Icon(
                                        Icons.phone_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter recipient phone';
                                      }
                                      return null;
                                    },
                                    onChanged: _onRecipientChanged,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Verification Status
                        if (state is WalletLoading && !_userVerified) ...[
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Verifying recipient...'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_userVerified && _verifiedUserName != null) ...[
                          Card(
                            elevation: 2,
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _verifiedUserName![0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _verifiedUserName!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Verified',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedMethod == 0
                                              ? _emailController.text
                                              : _phoneController.text,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Amount Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Color(0xFF667eea),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₦ ',
                                    prefixStyle: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    hintText: '0',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    final amount = int.tryParse(value);
                                    if (amount == null || amount <= 0) {
                                      return 'Please enter a valid amount';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.note_outlined,
                                      color: Color(0xFF667eea),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Note (Optional)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _noteController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Add a note for this transfer...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Send Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state is WalletLoading
                                ? null
                                : _sendMoney,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: state is WalletLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded),
                                      SizedBox(width: 8),
                                      Text(
                                        'Send Money',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionCard(Map<String, dynamic> transaction) {
    final name = transaction['receiver_name'] ?? 'Unknown';
    final amount = transaction['amount'] ?? 0;

    return GestureDetector(
      onTap: () => _selectRecentTransaction(transaction),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '₦${_formatAmount(amount)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
