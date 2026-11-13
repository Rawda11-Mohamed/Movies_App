import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  int _selectedAvatarIndex = 0;
  String? _customImagePath;
  String _email = '';

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    final authState = context.read<AuthBloc>().state;

    String name = '';
    String phone = '';

    if (authState is Authenticated) {
      _email = authState.user.email;
      name = authState.user.displayName;
    }

    if (profileState is ProfileLoaded) {
      if (profileState.profile.displayName.isNotEmpty) {
        name = profileState.profile.displayName;
      }
      phone = profileState.profile.phone;
      final avatarKey = profileState.profile.avatarKey;

      if (avatarKey.startsWith('/') || avatarKey.contains(r':\')) {
        _customImagePath = avatarKey;
      } else {
        _selectedAvatarIndex = (int.tryParse(avatarKey.replaceAll('avatar_', '')) ?? 1) - 1;
        _selectedAvatarIndex = _selectedAvatarIndex.clamp(0, AppConstants.avatarIcons.length - 1);
      }
    }

    _nameController = TextEditingController(text: name);
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _customImagePath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onUpdateData() {
    if (_formKey.currentState!.validate()) {
      final avatarValue = _customImagePath ?? 'avatar_${_selectedAvatarIndex + 1}';
      final newDisplayName = _nameController.text.trim();

      context.read<ProfileBloc>().add(UpdateProfile(
        displayName: newDisplayName,
        phone: _phoneController.text.trim(),
        avatarKey: avatarValue,
      ));

      context.read<AuthBloc>().add(UpdateProfileRequested(
        displayName: newDisplayName,
        photoURL: avatarValue,
      ));
    }
  }

  void _onResetPassword() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<AuthBloc>().add(
        ForgotPasswordRequested(email: authState.user.email),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.resetEmailSent),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _onDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const DeleteAccountRequested());
              context.read<ProfileBloc>().add(const ClearProfile());
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        title: const Text(AppStrings.editProfile),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.profileUpdated),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go(AppRoutes.profile);
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isAuthLoading = context.watch<AuthBloc>().state is AuthLoading;
            final isLoading = state is ProfileLoading || isAuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 24),
                    // Display Authenticated User's Email (Read-Only)
                    TextFormField(
                      initialValue: _email,
                      readOnly: true,
                      style: const TextStyle(color: AppColors.textSecondary),
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.iconColor),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Display & Update Display Name
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: AppStrings.name,
                        hintText: AppStrings.name,
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.iconColor),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: AppStrings.phoneNumber,
                        hintText: AppStrings.phoneNumber,
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.iconColor),
                      ),
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _onResetPassword,
                      child: const Text(
                        AppStrings.resetPassword,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _onDeleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text(AppStrings.deleteAccount),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : ElevatedButton(
                            onPressed: _onUpdateData,
                            child: const Text(AppStrings.updateData),
                          ),
                    const SizedBox(height: 24),
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

  Widget _buildAvatarSection() {
    ImageProvider? imageProvider;
    if (_customImagePath != null) {
      final file = File(_customImagePath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.surface,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(
                        AppConstants.avatarIcons[_selectedAvatarIndex],
                        size: 70,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primary),
          label: const Text(
            'Upload Custom Photo',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        // Preset Avatars Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: AppConstants.avatarIcons.length,
          itemBuilder: (context, index) {
            final isSelected = _customImagePath == null && _selectedAvatarIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _customImagePath = null;
                  _selectedAvatarIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  AppConstants.avatarIcons[index],
                  color: isSelected ? AppColors.primary : AppColors.iconColor,
                  size: 26,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
