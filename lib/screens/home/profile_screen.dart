import 'package:ak_api_test/bloc/auth/auth_bloc.dart';
import 'package:ak_api_test/bloc/auth/auth_event.dart';
import 'package:ak_api_test/bloc/profile/profile_bloc.dart';
import 'package:ak_api_test/bloc/profile/profile_event.dart';
import 'package:ak_api_test/bloc/profile/profile_state.dart';
import 'package:ak_api_test/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// Local palette for this screen, tuned to match the reference design
/// (near-black background, dark cards, violet accent). Swap these for
/// AppColors equivalents if you add matching shades there.
class _PC {
  static const background = Color(0xFF121214);
  static const card = Color(0xFF1C1C20);
  static const divider = Color(0xFF2C2C31);
  static const accent = Color(0xFF7C5CFC);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFA0A0A8);
  static const danger = Color(0xFFE94B4B);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _baseUrl = 'http://10.192.130.247:8000';

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<ProfileBloc>().add(UploadAvatar(image.path));
    }
  }

  // ---------- formatting helpers ----------

  String _groupDigits(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final fromEnd = digits.length - i - 1;
      if (fromEnd > 0 && fromEnd % 3 == 0 && i != digits.length - 1) {
        // group as 3-3-rest, matching "803 289 8649"
      }
    }
    // Simple 3-3-rest grouping tailored to Nigerian 11 digit numbers.
    if (digits.length >= 10) {
      final start = digits.length - 10;
      final tail = digits.substring(start);
      return '${tail.substring(0, 3)} ${tail.substring(3, 6)} ${tail.substring(6)}';
    }
    return digits;
  }

  String _maskedDob(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Not set';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return 'Not set';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} **, **';
  }

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return 'Not set';
    return value[0].toUpperCase() + value.substring(1);
  }

  // ---------- edit bottom sheet for simple text fields ----------

  void _editTextField({
    required String title,
    required String currentValue,
    required String profileKey,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      backgroundColor: _PC.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit $title',
                style: const TextStyle(
                  color: _PC.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                style: const TextStyle(color: _PC.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _PC.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PC.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                      UpdateProfile({profileKey: controller.text.trim()}),
                    );
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editGenderField(String? currentValue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _PC.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Edit Gender',
                    style: TextStyle(
                      color: _PC.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final option in const ['male', 'female', 'other'])
                  ListTile(
                    title: Text(
                      _capitalize(option),
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: currentValue?.toLowerCase() == option
                        ? const Icon(Icons.check, color: _PC.accent)
                        : null,
                    onTap: () {
                      context.read<ProfileBloc>().add(
                        UpdateProfile({'gender': option}),
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editDateOfBirth(String? currentIsoDate) async {
    final initial = currentIsoDate != null
        ? DateTime.tryParse(currentIsoDate) ?? DateTime(1990)
        : DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _PC.accent,
              onPrimary: Colors.white,
              surface: _PC.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      context.read<ProfileBloc>().add(
        UpdateProfile({'date_of_birth': formatted}),
      );
    }
  }

  void _showLockedFieldNotice(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label is verified via KYC and can\'t be edited here.'),
        backgroundColor: _PC.card,
      ),
    );
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied')));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _PC.card,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _PC.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
            child: const Text('Logout', style: TextStyle(color: _PC.danger)),
          ),
        ],
      ),
    );
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PC.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is AvatarUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          Map<String, dynamic> profile = {};
          bool isLoading = false;
          bool isUploading = false;

          if (state is ProfileLoading) {
            isLoading = true;
          } else if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileUpdating) {
            profile = state.profile;
            isLoading = true;
          } else if (state is ProfileUpdated) {
            profile = state.profile;
          } else if (state is AvatarUploading) {
            profile = state.profile;
            isUploading = true;
          } else if (state is AvatarUploaded) {
            profile = state.profile;
          } else if (state is ProfileError) {
            profile = state.profile ?? {};
          }

          if (isLoading && profile.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _PC.accent),
            );
          }

          final avatarUrl = profile['avatar_url'];
          final displayName = (profile['name'] ?? 'User').toString();
          final phone = (profile['phone'] ?? '').toString();
          final formattedPhone = _groupDigits(phone);
          final email = (profile['email'] ?? '').toString();
          final nickName = (profile['nickname'] ?? '').toString();
          final kycTier = (profile['kyc_tier'] ?? 'Tier 1').toString();
          final fullName = (profile['full_name'] ?? displayName).toString();
          final gender = _capitalize(profile['gender']);
          final dob = _maskedDob(profile['date_of_birth']);
          final address = (profile['address'] ?? '').toString();
          final occupation = (profile['occupation'] ?? '').toString();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Basic info card ---
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: _PC.accent,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(
                                        avatarUrl.toString().startsWith('http')
                                            ? avatarUrl.toString()
                                            : '$_baseUrl$avatarUrl',
                                      )
                                    : null,
                                child: avatarUrl == null
                                    ? Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              if (isUploading)
                                const Positioned.fill(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: _PC.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${displayName.toUpperCase()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      formattedPhone,
                                      style: const TextStyle(
                                        color: _PC.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _copyToClipboard(
                                        formattedPhone,
                                        'Account number',
                                      ),
                                      child: const Icon(
                                        Icons.copy,
                                        size: 14,
                                        color: _PC.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _divider(),
                      _row(
                        label: 'Account Number',
                        value: formattedPhone,
                        onTap: () =>
                            _copyToClipboard(formattedPhone, 'Account number'),
                      ),
                      _divider(),
                      _row(
                        label: 'Email',
                        value: email.isEmpty ? null : email,
                        onTap: () => _editTextField(
                          title: 'Email',
                          currentValue: email,
                          profileKey: 'email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      _divider(),
                      _row(
                        label: 'Nick Name',
                        value: nickName.isEmpty ? null : nickName,
                        onTap: () => _editTextField(
                          title: 'Nick Name',
                          currentValue: nickName,
                          profileKey: 'nickname',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- KYC card ---
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(
                        label: 'KYC Levels',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _PC.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    kycTier,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right,
                              color: _PC.textSecondary,
                            ),
                          ],
                        ),
                        onTap: () => _showLockedFieldNotice('KYC Levels'),
                        showDefaultChevron: false,
                      ),
                      _divider(),
                      _row(
                        label: 'Full Name',
                        labelIcon: Icons.info_outline,
                        value: fullName,
                        onTap: () => _editTextField(
                          title: 'Full Name',
                          currentValue: fullName,
                          profileKey: 'full_name',
                        ),
                      ),
                      _divider(),
                      _row(
                        label: 'Gender',
                        value: gender,
                        onTap: () =>
                            _editGenderField(profile['gender']?.toString()),
                      ),
                      _divider(),
                      _row(
                        label: 'Date of Birth',
                        value: dob,
                        onTap: () => _editDateOfBirth(
                          profile['date_of_birth']?.toString(),
                        ),
                      ),
                      _divider(),
                      _row(
                        label: 'Mobile Number',
                        value: formattedPhone,
                        onTap: () => _editTextField(
                          title: 'Mobile Number',
                          currentValue: phone,
                          profileKey: 'phone',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _divider(),
                      _row(
                        label: 'Address',
                        value: address.isEmpty ? null : address,
                        onTap: () => _editTextField(
                          title: 'Address',
                          currentValue: address,
                          profileKey: 'address',
                        ),
                      ),
                      _divider(),
                      _row(
                        label: 'Occupation',
                        value: occupation.isEmpty ? null : occupation,
                        onTap: () => _editTextField(
                          title: 'Occupation',
                          currentValue: occupation,
                          profileKey: 'occupation',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Management of accounts ---
                _card(
                  child: _row(
                    label: 'Management of Accounts',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(radius: 4, backgroundColor: _PC.danger),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: _PC.textSecondary),
                      ],
                    ),
                    showDefaultChevron: false,
                    onTap: () {
                      // TODO: hook this up to your account management screen.
                    },
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _PC.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _showLogoutDialog,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- shared row / card widgets ----------

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _PC.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _divider() => const Divider(color: _PC.divider, height: 1);

  Widget _row({
    required String label,
    String? value,
    IconData? labelIcon,
    Widget? trailing,
    VoidCallback? onTap,
    bool showChevron = true,
    bool showDefaultChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            if (labelIcon != null) ...[
              const SizedBox(width: 6),
              Icon(labelIcon, size: 15, color: _PC.textSecondary),
            ],
            const Spacer(),
            if (trailing != null)
              trailing
            else ...[
              Text(
                value ?? 'Not set',
                style: const TextStyle(color: _PC.textSecondary, fontSize: 15),
              ),
              if (showChevron && showDefaultChevron && onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: _PC.textSecondary,
                  size: 20,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
