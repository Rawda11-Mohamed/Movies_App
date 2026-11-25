import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../core/widgets/custom_outlined_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProfileBloc>().add(
            LoadProfile(
              uid: authState.user.uid,
              email: authState.user.email,
              displayName: authState.user.displayName,
            ),
          );
    }
  }

  ImageProvider _resolveAvatar(String avatarKey) {
    if (avatarKey.startsWith('http')) {
      return NetworkImage(avatarKey);
    }
    if (avatarKey.startsWith('/') || avatarKey.contains(r':\')) {
      final file = File(avatarKey);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (avatarKey == 'avatar_2') {
      return const AssetImage(AppAssets.avatar2);
    }
    if (avatarKey == 'avatar_3') {
      return const AssetImage(AppAssets.avatar3);
    }
    return const AssetImage(AppAssets.avatar1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CustomLoadingIndicator());
            }

            final ProfileEntity profile;
            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileUpdatedSuccess) {
              profile = state.profile;
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No profile data found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    CustomElevatedButton(
                      title: 'Retry',
                      width: 140,
                      height: 44,
                      onPressed: _loadProfile,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                  _buildTabSection(profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileEntity profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: AppColors.surfaceVariant,
          backgroundImage: _resolveAvatar(profile.avatarKey),
        ),
        const SizedBox(height: 14),
        Text(
          profile.displayName.isNotEmpty ? profile.displayName : 'John Safwat',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('${profile.wishlistCount}', AppStrings.wishList),
              Container(
                height: 36,
                width: 1,
                color: AppColors.divider,
              ),
              _buildStatItem('${profile.historyCount}', AppStrings.history),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CustomElevatedButton(
              title: AppStrings.editProfile,
              height: 48,
              onPressed: () => context.push(AppRoutes.editProfile),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomOutlinedButton(
              title: 'Exit',
              height: 48,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              icon: const Icon(Icons.exit_to_app, color: AppColors.error, size: 20),
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const SignOutRequested());
              context.read<ProfileBloc>().add(const ClearProfile());
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(ProfileEntity profile) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: const TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(
                  icon: Icon(Icons.bookmark_outline),
                  text: AppStrings.wishList,
                ),
                Tab(
                  icon: Icon(Icons.folder_open_outlined),
                  text: AppStrings.history,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              children: [
                _buildEmptyTabState(
                  icon: Icons.movie_outlined,
                  message: 'No Movies in Wish List',
                ),
                _buildEmptyTabState(
                  icon: Icons.folder_open_outlined,
                  message: 'No Watch History Yet',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 75, color: AppColors.primary.withValues(alpha: 0.8)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
