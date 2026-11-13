import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
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

  static const List<IconData> _avatarIcons = [
    Icons.face,
    Icons.face_2,
    Icons.face_3,
    Icons.face_4,
    Icons.face_5,
    Icons.face_6,
  ];

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    String name = '';
    String phone = '';
    if (profileState is ProfileLoaded) {
      name = profileState.profile.displayName;
      phone = profileState.profile.phone;
      final avatarKey = profileState.profile.avatarKey;
      _selectedAvatarIndex = (int.tryParse(avatarKey.replaceAll('avatar_', '')) ?? 1) - 1;
      _selectedAvatarIndex = _selectedAvatarIndex.clamp(0, _avatarIcons.length - 1);
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

  void _onUpdateData() {
    if (_formKey.currentState!.validate()) {
      final avatarKey = 'avatar_${_selectedAvatarIndex + 1}';
      context.read<ProfileBloc>().add(UpdateProfile(
        displayName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarKey: avatarKey,
      ));
      context.read<AuthBloc>().add(UpdateProfileRequested(
        displayName: _nameController.text.trim(),
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
              context.go(AppRoutes.login);
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
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
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatarGrid(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: AppStrings.name,
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.iconColor),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
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
                    state is ProfileLoading
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
    );
  }

  Widget _buildAvatarGrid() {
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.surface,
          child: Icon(
            _avatarIcons[_selectedAvatarIndex],
            size: 70,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _avatarIcons.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedAvatarIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatarIndex = index),
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
                  _avatarIcons[index],
                  color: isSelected ? AppColors.primary : AppColors.iconColor,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
