import 'package:ak_api_test/services/api_service.dart';
import 'package:flutter/material.dart';

class SetNewPinScreen extends StatefulWidget {
  const SetNewPinScreen({super.key});

  @override
  State<SetNewPinScreen> createState() => _SetNewPinScreenState();
}

class _SetNewPinScreenState extends State<SetNewPinScreen> {
  static const _pageBg = Color(0xFF101010);
  static const _headerBg = Color(0xFF1D1D1F);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _mutedText = Color(0xFFA4A7AE);
  static const _accentPurple = Color(0xFF754CFF);
  static const _success = Color(0xFF18D99A);
  static const _danger = Color(0xFFFF4D57);

  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _showNewPin = false;
  bool _showConfirmPin = false;
  String? _errorMessage;
  String? _successMessage;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _setPin() async {
    if (!_validatePin()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _apiService.post(
        '/api/v1/wallet/set-pin',
        body: {'pin': _newPinController.text.trim()},
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'PIN set successfully!';
        });

        // Clear fields and show success
        _newPinController.clear();
        _confirmPinController.clear();

        // Navigate back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  bool _validatePin() {
    _errorMessage = null;

    if (_newPinController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a new PIN');
      return false;
    }

    if (_newPinController.text.length < 4) {
      setState(() => _errorMessage = 'PIN must be at least 4 digits');
      return false;
    }

    if (_newPinController.text.length > 8) {
      setState(() => _errorMessage = 'PIN must be maximum 8 digits');
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(_newPinController.text)) {
      setState(() => _errorMessage = 'PIN must contain only numbers');
      return false;
    }

    if (_confirmPinController.text.isEmpty) {
      setState(() => _errorMessage = 'Please confirm your PIN');
      return false;
    }

    if (_newPinController.text != _confirmPinController.text) {
      setState(() => _errorMessage = 'PINs do not match');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        toolbarHeight: 110,
        titleSpacing: 0,
        title: const Text(
          'Set New PIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: _headerBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildPinInputSection(),
            const SizedBox(height: 16),
            if (_errorMessage != null) _buildErrorMessage(),
            if (_successMessage != null) _buildSuccessMessage(),
            const SizedBox(height: 32),
            _buildSetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentPurple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: _accentPurple, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Create a Secure PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set a 4-8 digit PIN to secure your wallet transactions',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPinField(
          label: 'New PIN',
          controller: _newPinController,
          isVisible: _showNewPin,
          onVisibilityToggle: () {
            setState(() => _showNewPin = !_showNewPin);
          },
        ),
        const SizedBox(height: 20),
        _buildPinField(
          label: 'Confirm PIN',
          controller: _confirmPinController,
          isVisible: _showConfirmPin,
          onVisibilityToggle: () {
            setState(() => _showConfirmPin = !_showConfirmPin);
          },
        ),
      ],
    );
  }

  Widget _buildPinField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accentPurple.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            keyboardType: TextInputType.number,
            maxLength: 8,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '',
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: _mutedText,
                ),
                onPressed: onVisibilityToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _danger.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: _danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: _danger,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _success.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: _success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(
                color: _success,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _setPin,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Set PIN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
