// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Wallet App';
  static const String appVersion = '1.0.0';
  static const String incoming = 'incoming';
  static const String outgoing = 'incoming';

  // API Endpoints (for future backend integration)
  static const String baseUrl = 'https://api.walletapp.com/v1';

  // SharedPreferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserPrefix = 'user_';
  static const String keyTransactionsPrefix = 'transactions_';
  static const String keyCardsPrefix = 'cards_';
  static const String keyOtpPrefix = 'otp_';
  static const String keyOtpExpiryPrefix = 'otp_expiry_';
  static const String keyDarkMode = 'dark_mode';
  static const String keyCurrentUserId = 'current_user_id';
  static const String keyLastUserId = 'last_user_id';

  // Transaction Limits by KYC Tier
  static const Map<int, double> dailyTransactionLimits = {
    0: 10000, // Unverified
    1: 50000, // Tier 1
    2: 200000, // Tier 2
    3: double.infinity, // Tier 3 unlimited
  };

  static const Map<int, double> dailyTransferLimits = {
    0: 5000,
    1: 25000,
    2: 100000,
    3: 500000,
  };

  // Colors

  // Asset Paths
  static const String mtnLogo = 'asset/banner/mtn.png';
  static const String gloLogo = 'asset/banner/Glo.png';
  static const String airtelLogo = 'asset/banner/airlet.png';
  static const String etisalatLogo = 'asset/banner/etisalat.jpeg';
  static const String bill = 'asset/banner/bill.png';
  static const String card = 'asset/banner/card.png';
  static const String wifi = 'asset/banner/wifi.png';
  static const String smartphone = 'asset/banner/smartphone.png';
  static const String phone = 'asset/banner/phone.png';
  static const String card1 = 'asset/banner/card1.png';
  static const String card2 = 'asset/banner/card2.png';
  static const String card3 = 'asset/banner/card3.png';
  static const String card4 = 'asset/banner/card4.png';
  static const String money = 'asset/banner/money.png';
  static const String visa1 = 'asset/banner/visa1.png';
  static const String delete = 'asset/banner/delete.png';
  static const String delete1 = 'asset/banner/delete1.png';
  static const String electric = 'asset/banner/electric.png';
  static const String electric1 = 'asset/banner/electric1.png';
  static const String empty = 'asset/banner/empty.png';
  static const String fingerprint = 'asset/banner/fingerprint.png';
  static const String fingerprint1 = 'asset/banner/fingerprint1.png';
  static const String fingerprint2 = 'asset/banner/fingerprint2.png';
  static const String gear = 'asset/banner/gear.png';
  static const String history = 'asset/banner/history.png';
  static const String information = 'asset/banner/information.png';
  static const String logout = 'asset/banner/logout.png';
  static const String mail = 'asset/banner/mail.png';
  static const String more = 'asset/banner/more.png';
  static const String more1 = 'asset/banner/more1.png';
  static const String more2 = 'asset/banner/more2.png';
  static const String night = 'asset/banner/night.png';
  static const String night1 = 'asset/banner/night1.png';
  static const String night2 = 'asset/banner/night2.png';
  static const String notification = 'asset/banner/notification.png';
  static const String notification1 = 'asset/banner/notification1.png';
  static const String notification2 = 'asset/banner/notification2.png';
  static const String paper = 'asset/banner/paper.png';
  static const String password2 = 'asset/banner/password2.png';
  static const String paying = 'asset/banner/paying.png';
  static const String pin = 'asset/banner/pin.png';
  static const String pin2 = 'asset/banner/pin3.png';
  static const String profile1 = 'asset/banner/profile.png';
  static const String profile = 'asset/banner/profile.gif';
  static const String settings1 = 'asset/banner/setting.png';
  static const String setting = 'asset/banner/setting.png';
  static const String sim = 'asset/banner/sim.png';
  static const String transfer = 'asset/banner/transfer.png';
  static const String transfer1 = 'asset/banner/transfer1.png';
  static const String user = 'asset/banner/user.png';
  static const String vasa = 'asset/banner/vasa.png';
  static const String wallet = 'asset/banner/wallet.png';
  static const String withdraw = 'asset/banner/withdraw.png';
  static const String bank = 'asset/banner/bank.png';

  // Network Logos
  static const Map<String, String> networkLogos = {
    'mtn': mtnLogo,
    'glo': gloLogo,
    'airtel': airtelLogo,
    'etisalat': etisalatLogo,
    'bank': bank,
  };

  // Banks List
  static const List<String> banks = [
    'Access Bank',
    'First Bank',
    'GTBank',
    'UBA',
    'Zenith Bank',
    'Fidelity Bank',
    'Union Bank',
    'Sterling Bank',
    'Wema Bank',
    'Ecobank',
    'Heritage Bank',
    'Keystone Bank',
    'Polaris Bank',
    'Stanbic IBTC',
    'Unity Bank',
  ];

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration otpResendDuration = Duration(seconds: 60);

  // Regular Expressions
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp phoneRegex = RegExp(r'^[0-9]{10,15}$');
  static final RegExp pinRegex = RegExp(r'^[0-9]{4}$');
  static final RegExp passwordRegex = RegExp(r'^.{6,}$');

  // Card BINs (Bank Identification Numbers)
  static const Map<String, String> cardBins = {
    'mastercard': '5',
    'visa': '4',
    'verve': '506',
  };
}

class AppColors {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const primary = Color.fromARGB(255, 14, 9, 78);
  static const Color primaryPurple = Color(0xFF101010);
  static const Color secondaryPurple = Color(0xFF121213);
  static const Color softPurpleBg = Color(0xFFF0EEFF);
  static const Color purple = Color(0xFF8658FF);
  static const Color orange = Color(0xFFFFA31A);
  static const Color violet = Color(0xFF6F35F1);
  static const Color mint = Color(0xFF27D3A2);
  static const Color surface = Color(0xFF1D1D1F);

  static const Color backgroundOffWhite = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF212529);
  static const Color textDarkBlue = Color(0xFF1A2C3E);
  static const Color textGray = Color(0xFF6C757D);
  static const Color textDarkGray = Color(0xFF343A40);
  static const Color textLightGray = Color(0xFFADB5BD);
  static const Color successGreen = Color(0xFF28A745);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color bottomNavInactive = Color(0xFF6C757D);
  static const Color bottomNavActive = Color(0xFF6C63FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  static const Color background = Color(0xFF101010);
  static const Color surface4 = Color(0xFF1D1D1F);
  static const Color surfaceDeep = Color(0xFF121213);
  static const Color purple1 = Color(0xFF8658FF);
  static const Color violet1 = Color(0xFF6F35F1);
  static const Color mint1 = Color(0xFF27D3A2);
  static const Color orange1 = Color(0xFFFFA31A);
}

class AppStrings {
  // General
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String loading = 'Loading...';

  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String logout = 'Logout';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';

  // Form Labels
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String email = 'Email';
  static const String phoneNumber = 'Phone Number';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String address = 'Address';
  static const String occupation = 'Occupation';

  // Transaction
  static const String sendMoney = 'Send Money';
  static const String addMoney = 'Add Money';
  static const String withdraw = 'Withdraw';
  static const String transactionHistory = 'Transaction History';
  static const String balance = 'Balance';
  static const String amount = 'Amount';
  static const String note = 'Note';

  // Services
  static const String buyAirtime = 'Buy Airtime';
  static const String buyData = 'Buy Data';
  static const String payBills = 'Pay Bills';

  // Cards
  static const String myCards = 'My Cards';
  static const String virtualCard = 'Virtual Card';
  static const String physicalCard = 'Physical Card';
  static const String requestNewCard = 'Request New Card';

  // Settings
  static const String settings = 'Settings';
  static const String security = 'Security';
  static const String preferences = 'Preferences';
  static const String notifications = 'Notifications';
  static const String about = 'About';

  // Errors
  static const String error = 'Error';
  static const String success = 'Success';
  static const String networkError = 'Network connection error';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidPin = 'PIN must be 4 digits';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String insufficientBalance = 'Insufficient balance';
  static const String invalidCredentials = 'Invalid email/phone or password';
  static const String userNotFound = 'User not found';
  static const String emailAlreadyExists = 'Email already registered';
  static const String phoneAlreadyExists = 'Phone number already registered';
}

class AppAssets {
  // Images
  static const String logo3 = 'asset/banner/logo3.png';
  static const String logo2 = 'asset/banner/logo2.png';
  static const String logo1 = 'asset/banner/logo1.png';
  static const String banner1 = 'asset/banner/banner1.png';
  static const String banner2 = 'asset/banner/banner3.png';
  static const String glo = 'asset/banner/Glo.png';
  static const String mtn = 'asset/banner/mtn.png';
  static const String airtel = 'asset/banner/airtel.png';
  static const String etisalat = 'asset/banner/etisalat.png';
  static const String splashBg = 'assets/images/splash_bg.png';

  // Icons
  static const String icMtn = 'assets/icons/mtn.svg';
  static const String icGlo = 'assets/icons/glo.svg';
  static const String icAirtel = 'assets/icons/airtel.svg';
  static const String icNineMobile = 'assets/icons/9mobile.svg';
  static const String icMastercard = 'assets/icons/mastercard.svg';
  static const String icVisa = 'assets/icons/visa.svg';
  static const String icVerve = 'assets/icons/verve.svg';
}

class AppBlue {
  static const blue50 = Color(0xFFE3F2FD);
  static const blue100 = Color(0xFFBBDEFB);
  static const blue200 = Color(0xFF90CAF9);
  static const blue300 = Color(0xFF64B5F6);
  static const blue400 = Color(0xFF42A5F5);
  static const blue500 = Color(0xFF2196F3);
  static const blue600 = Color(0xFF1E88E5);
  static const blue700 = Color(0xFF1976D2);
  static const blue800 = Color(0xFF1565C0);
  static const blue900 = Color(0xFF0D47A1);
}

// class Colors {

// }
