// import 'package:ak_api_test/bloc/auth/auth_bloc.dart';
// import 'package:ak_api_test/bloc/auth/auth_event.dart';
// import 'package:ak_api_test/bloc/auth/auth_state.dart';
// import 'package:ak_api_test/bloc/profile/profile_bloc.dart';
// import 'package:ak_api_test/bloc/profile/profile_event.dart';
// import 'package:ak_api_test/bloc/profile/profile_state.dart';
// import 'package:ak_api_test/constants.dart';
// import 'package:ak_api_test/screens/auth/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _countryController = TextEditingController();

//   String? _selectedGender;
//   DateTime? _dateOfBirth;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     context.read<ProfileBloc>().add(LoadProfile());
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _countryController.dispose();
//     super.dispose();
//   }

//   void _populateFields(Map<String, dynamic> profile) {
//     _nameController.text = profile['name'] ?? '';
//     _phoneController.text = profile['phone'] ?? '';
//     _addressController.text = profile['address'] ?? '';
//     _cityController.text = profile['city'] ?? '';
//     _stateController.text = profile['state'] ?? '';
//     _countryController.text = profile['country'] ?? '';
//     _selectedGender = profile['gender'];
//     if (profile['date_of_birth'] != null) {
//       _dateOfBirth = DateTime.tryParse(profile['date_of_birth']);
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 800,
//       maxHeight: 800,
//       imageQuality: 85,
//     );
//     if (image != null && mounted) {
//       context.read<ProfileBloc>().add(UploadAvatar(image.path));
//     }
//   }

//   Future<void> _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _dateOfBirth ?? DateTime(1990),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: AppColors.secondaryPurple,
//               onPrimary: Colors.white,
//               surface: AppColors.primaryPurple,
//               onSurface: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _dateOfBirth = picked;
//       });
//     }
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '';
//     return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }

//   void _saveProfile() {
//     if (_formKey.currentState!.validate()) {
//       final data = {
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'date_of_birth': _dateOfBirth != null
//             ? _formatDate(_dateOfBirth)
//             : null,
//         'gender': _selectedGender,
//         'address': _addressController.text.trim(),
//         'city': _cityController.text.trim(),
//         'state': _stateController.text.trim(),
//         'country': _countryController.text.trim(),
//       };
//       context.read<ProfileBloc>().add(UpdateProfile(data));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryPurple,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: AppColors.primaryPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           if (!_isEditing)
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => setState(() => _isEditing = true),
//             ),
//         ],
//       ),
//       body: BlocConsumer<ProfileBloc, ProfileState>(
//         listener: (context, state) {
//           if (state is ProfileLoaded) {
//             _populateFields(state.profile);
//           }
//           if (state is ProfileUpdated) {
//             setState(() => _isEditing = false);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Profile updated successfully'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//           if (state is AvatarUploaded) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Avatar uploaded successfully'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//           if (state is ProfileError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           Map<String, dynamic> profile = {};
//           bool isLoading = false;
//           bool isUploading = false;

//           if (state is ProfileLoading) {
//             isLoading = true;
//           } else if (state is ProfileLoaded) {
//             profile = state.profile;
//           } else if (state is ProfileUpdating) {
//             profile = state.profile;
//             isLoading = true;
//           } else if (state is ProfileUpdated) {
//             profile = state.profile;
//           } else if (state is AvatarUploading) {
//             profile = state.profile;
//             isUploading = true;
//           } else if (state is AvatarUploaded) {
//             profile = state.profile;
//           } else if (state is ProfileError) {
//             profile = state.profile ?? {};
//           }

//           final avatarUrl = profile['avatar_url'];
//           final displayName = profile['name'] ?? 'User';
//           final email = profile['email'] ?? '';

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: AppColors.secondaryPurple,
//                       backgroundImage: avatarUrl != null
//                           ? NetworkImage(
//                               avatarUrl.startsWith('http')
//                                   ? avatarUrl
//                                   : 'http://10.192.130.247:8000$avatarUrl',
//                             )
//                           : null,
//                       child: avatarUrl == null
//                           ? Text(
//                               displayName.isNotEmpty
//                                   ? displayName[0].toUpperCase()
//                                   : 'U',
//                               style: const TextStyle(
//                                 fontSize: 40,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                     ),
//                     if (isUploading)
//                       const Positioned.fill(
//                         child: CircleAvatar(
//                           backgroundColor: Colors.black45,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: _pickImage,
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: const BoxDecoration(
//                             color: AppColors.secondaryPurple,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.camera_alt,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   displayName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   email,
//                   style: TextStyle(
//                     color: Colors.white.withValues(alpha: 0.8),
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 if (isLoading)
//                   const CircularProgressIndicator(color: Colors.white)
//                 else if (_isEditing)
//                   _buildEditForm()
//                 else
//                   _buildProfileView(profile),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProfileView(Map<String, dynamic> profile) {
//     return Column(
//       children: [
//         _buildInfoCard('Email', profile['email'] ?? 'Not set', Icons.email),
//         _buildInfoCard('Phone', profile['phone'] ?? 'Not set', Icons.phone),
//         _buildInfoCard(
//           'Date of Birth',
//           profile['date_of_birth'] ?? 'Not set',
//           Icons.calendar_today,
//         ),
//         _buildInfoCard(
//           'Gender',
//           profile['gender'] ?? 'Not set',
//           Icons.person_outline,
//         ),
//         _buildInfoCard(
//           'Address',
//           profile['address'] ?? 'Not set',
//           Icons.location_on,
//         ),
//         _buildInfoCard(
//           'City',
//           profile['city'] ?? 'Not set',
//           Icons.location_city,
//         ),
//         _buildInfoCard('State', profile['state'] ?? 'Not set', Icons.map),
//         _buildInfoCard('Country', profile['country'] ?? 'Not set', Icons.flag),
//         const SizedBox(height: 24),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//             icon: const Icon(Icons.logout),
//             label: const Text('Logout'),
//             onPressed: () => _showLogoutDialog(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoCard(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.white70),
//         title: Text(
//           label,
//           style: const TextStyle(color: Colors.white54, fontSize: 12),
//         ),
//         subtitle: Text(
//           value,
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildEditForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           _buildTextField(
//             controller: _nameController,
//             label: 'Name',
//             icon: Icons.person,
//             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//           ),
//           _buildTextField(
//             controller: _phoneController,
//             label: 'Phone',
//             icon: Icons.phone,
//             keyboardType: TextInputType.phone,
//           ),
//           _buildDateField(),
//           _buildGenderDropdown(),
//           _buildTextField(
//             controller: _addressController,
//             label: 'Address',
//             icon: Icons.location_on,
//           ),
//           _buildTextField(
//             controller: _cityController,
//             label: 'City',
//             icon: Icons.location_city,
//           ),
//           _buildTextField(
//             controller: _stateController,
//             label: 'State',
//             icon: Icons.map,
//           ),
//           _buildTextField(
//             controller: _countryController,
//             label: 'Country',
//             icon: Icons.flag,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     side: const BorderSide(color: Colors.white54),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   onPressed: () => setState(() => _isEditing = false),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.secondaryPurple,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   onPressed: _saveProfile,
//                   child: const Text('Save'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white54),
//           prefixIcon: Icon(icon, color: Colors.white54),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateField() {
//     return GestureDetector(
//       onTap: _selectDate,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.calendar_today, color: Colors.white54),
//             const SizedBox(width: 12),
//             Text(
//               _dateOfBirth != null
//                   ? _formatDate(_dateOfBirth)
//                   : 'Date of Birth',
//               style: TextStyle(
//                 color: _dateOfBirth != null ? Colors.white : Colors.white54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGenderDropdown() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: _selectedGender,
//         dropdownColor: AppColors.surface,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           labelText: 'Gender',
//           labelStyle: TextStyle(color: Colors.white54),
//           prefixIcon: Icon(Icons.person_outline, color: Colors.white54),
//           border: InputBorder.none,
//         ),
//         items: const [
//           DropdownMenuItem(value: 'male', child: Text('Male')),
//           DropdownMenuItem(value: 'female', child: Text('Female')),
//           DropdownMenuItem(value: 'other', child: Text('Other')),
//         ],
//         onChanged: (v) => setState(() => _selectedGender = v),
//       ),
//     );
//   }

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppColors.primaryPurple,
//         title: const Text('Logout', style: TextStyle(color: Colors.white)),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<AuthBloc>().add(LogoutRequested());
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             child: const Text('Logout', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:ak_api_test/bloc/auth/auth_bloc.dart';
import 'package:ak_api_test/bloc/auth/auth_event.dart';
import 'package:ak_api_test/bloc/profile/profile_bloc.dart';
import 'package:ak_api_test/bloc/profile/profile_event.dart';
import 'package:ak_api_test/bloc/profile/profile_state.dart';
import 'package:ak_api_test/constants.dart';
import 'package:ak_api_test/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _pageBg = Color(0xFF101010);
  static const _headerBg = Color(0xFF1D1D1F);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _divider = Color(0xFF2A2A2C);
  static const _mutedText = Color(0xFFA4A7AE);
  static const _accentPurple = Color(0xFF754CFF);
  static const _success = Color(0xFF18D99A);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedGender;
  DateTime? _dateOfBirth;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> profile) {
    _nameController.text = _profileValue(profile, ['name', 'full_name']);
    _phoneController.text = _profileValue(profile, ['phone', 'mobile']);
    _addressController.text = _profileValue(profile, ['address']);
    _cityController.text = _profileValue(profile, ['city']);
    _stateController.text = _profileValue(profile, ['state']);
    _countryController.text = _profileValue(profile, ['country']);
    _selectedGender = _nullableProfileValue(profile, ['gender']);
    final dob = _nullableProfileValue(profile, ['date_of_birth', 'dob']);
    _dateOfBirth = dob == null ? null : DateTime.tryParse(dob);
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accentPurple,
              onPrimary: Colors.white,
              surface: _cardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _profileValue(
    Map<String, dynamic> profile,
    List<String> keys, {
    String fallback = '',
  }) {
    return _nullableProfileValue(profile, keys) ?? fallback;
  }

  String? _nullableProfileValue(
    Map<String, dynamic> profile,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = profile[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _displayDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
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
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  String _tierLabel(String value) {
    if (value.isEmpty) return 'Tier 3';
    final normalized = value.toLowerCase();
    return normalized.startsWith('tier') ? _titleCase(value) : 'Tier $value';
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date_of_birth': _dateOfBirth != null
            ? _formatDate(_dateOfBirth)
            : null,
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
      };
      context.read<ProfileBloc>().add(UpdateProfile(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        toolbarHeight: 110,
        titleSpacing: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 34),
          onPressed: () => Navigator.maybePop(context),
        ),
        backgroundColor: _headerBg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _isEditing ? 'Close edit' : 'Edit profile',
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state.profile);
          }
          if (state is ProfileUpdated) {
            _populateFields(state.profile);
            setState(() => _isEditing = false);
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

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: isLoading && profile.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : _isEditing
                ? _buildEditForm()
                : _buildProfileView(profile, isUploading: isUploading),
                
          );
        },
      ),
    );
  }

  Widget _buildProfileView(
    Map<String, dynamic> profile, {
    required bool isUploading,
  }) {
    final displayName = _profileValue(profile, [
      'name',
      'full_name',
    ], fallback: 'User');
    final email = _profileValue(profile, ['email'], fallback: 'Not set');
    final phone = _profileValue(profile, [
      'phone',
      'mobile',
    ], fallback: 'Not set');
    final accountNumber = _profileValue(profile, [
      'account_number',
      'accountNumber',
      'wallet_account_number',
      'phone',
    ], fallback: 'Not set');
    final nickname = _profileValue(profile, [
      'nickname',
      'nick_name',
      'username',
    ], fallback: 'Not set');
    final tier = _tierLabel(
      _profileValue(profile, ['kyc_tier', 'kyc_level', 'tier'], fallback: ''),
    );
    final fullName = _profileValue(profile, [
      'full_name',
      'name',
    ], fallback: displayName).toUpperCase();
    final gender = _titleCase(
      _profileValue(profile, ['gender'], fallback: 'Not set'),
    );
    final dob = _profileValue(profile, [
      'date_of_birth',
      'dob',
    ], fallback: 'Not set');
    final address = _profileValue(profile, ['address'], fallback: '');
    final occupation = _profileValue(profile, [
      'occupation',
      'job',
    ], fallback: '');
    final lastLogin = _profileValue(profile, [
      'last_login',
      'lastLogin',
      'last_seen',
    ], fallback: 'Not available');

    return Column(
      children: [
        _buildTopCard(
          profile: profile,
          displayName: displayName,
          lastLogin: lastLogin,
          isUploading: isUploading,
        ),
        const SizedBox(height: 16),
        _buildSection(
          rows: [
            _ProfileRow(
              label: 'Account Number',
              value: accountNumber,
              showChevron: true,
            ),
            _ProfileRow(
              label: 'Email',
              value: email,
              showChevron: true,
              leadingValue: const Icon(
                Icons.verified_user_rounded,
                color: _success,
                size: 22,
              ),
            ),
            _ProfileRow(label: 'Nick Name', value: nickname, showChevron: true),
          ],
        ),
        const SizedBox(height: 30),
        _buildSection(
          rows: [
            _ProfileRow(label: 'KYC Levels', value: tier, showChevron: true),
            _ProfileRow(
              label: 'Full Name',
              value: fullName,
              showChevron: true,
              labelSuffix: const Icon(
                Icons.info_outline,
                color: _mutedText,
                size: 17,
              ),
            ),
            _ProfileRow(label: 'Gender', value: gender),
            _ProfileRow(
              label: 'Date of Birth',
              value: dob == 'Not set' ? dob : _displayDate(dob),
            ),
            _ProfileRow(label: 'Mobile Number', value: phone),
            _ProfileRow(label: 'Address', value: address, showChevron: true),
            _ProfileRow(
              label: 'Occupation',
              value: occupation,
              showChevron: true,
            ),
          ],
        ),
        const SizedBox(height: 30),
        _buildManagementRow(),
      ],
    );
  }

  Widget _buildTopCard({
    required Map<String, dynamic> profile,
    required String displayName,
    required String lastLogin,
    required bool isUploading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 26, 32, 28),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          _buildAvatar(profile, displayName, isUploading),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${displayName.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Last login: $lastLogin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    Map<String, dynamic> profile,
    String displayName,
    bool isUploading,
  ) {
    final avatarUrl = _nullableProfileValue(profile, ['avatar_url', 'avatar']);

    ImageProvider? avatarImage;
    if (avatarUrl != null) {
      avatarImage = NetworkImage(
        avatarUrl.startsWith('http')
            ? avatarUrl
            : 'http://10.192.130.247:8000$avatarUrl',
      );
    }

    return SizedBox(
      width: 82,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            bottom: 0,
            child: CircleAvatar(
              radius: 34,
              backgroundColor: _accentPurple,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          if (isUploading)
            const Positioned(
              left: 4,
              bottom: 0,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.black54,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          Positioned(
            left: -6,
            top: 4,
            child: Transform.rotate(
              angle: -0.55,
              child: const Icon(
                Icons.auto_awesome,
                color: _accentPurple,
                size: 44,
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'AI Photo',
                style: TextStyle(
                  color: _accentPurple,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: _accentPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required List<_ProfileRow> rows}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _buildRow(rows[i]),
            if (i != rows.length - 1) const Divider(height: 1, color: _divider),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(_ProfileRow row) {
    return InkWell(
      // onTap: row.showChevron ? () => setState(() => _isEditing = true) : null,
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Flexible(
              flex: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Flexible(
                    child: Text(
                      row.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (row.labelSuffix != null) ...[
                    // const SizedBox(width: 7),
                    row.labelSuffix!,
                  ],
                ],
              ),
            ),

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (row.leadingValue != null) ...[
                    row.leadingValue!,
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      row.value.isEmpty ? 'Not set' : row.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (row.showChevron) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right,
                      color: _mutedText,
                      size: 34,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Management of Accounts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.circle, color: Color(0xFFFF4D57), size: 14),
            SizedBox(width: 16),
            Icon(Icons.chevron_right, color: _mutedText, size: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Name',
            icon: Icons.person,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          _buildDateField(),
          _buildGenderDropdown(),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on,
          ),
          _buildTextField(
            controller: _cityController,
            label: 'City',
            icon: Icons.location_city,
          ),
          _buildTextField(
            controller: _stateController,
            label: 'State',
            icon: Icons.map,
          ),
          _buildTextField(
            controller: _countryController,
            label: 'Country',
            icon: Icons.flag,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveProfile,
                  child: const Text('Save'),
                ),
              ),

            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _mutedText),
          prefixIcon: Icon(icon, color: _mutedText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: _mutedText),
            const SizedBox(width: 12),
            Text(
              _dateOfBirth != null
                  ? _formatDate(_dateOfBirth)
                  : 'Date of Birth',
              style: TextStyle(
                color: _dateOfBirth != null ? Colors.white : _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        dropdownColor: _cardBg,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(color: _mutedText),
          prefixIcon: Icon(Icons.person_outline, color: _mutedText),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: 'male', child: Text('Male')),
          DropdownMenuItem(value: 'female', child: Text('Female')),
          DropdownMenuItem(value: 'other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _selectedGender = v),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _mutedText),
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow {
  const _ProfileRow({
    required this.label,
    required this.value,
    this.showChevron = false,
    this.leadingValue,
    this.labelSuffix,
  });

  final String label;
  final String value;
  final bool showChevron;
  final Widget? leadingValue;
  final Widget? labelSuffix;
}
