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
    if (avatarKey.startsWith('/') || avatarKey.contains(':\\')) {
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

            return Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(profile),
                const SizedBox(height: 20),
                _buildActionButtons(context),
                const SizedBox(height: 20),
                Expanded(child: _buildTabsSection(profile)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: _resolveAvatar(profile.avatarKey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : 'Movie Fan',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextEmitter.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextEmitter.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('${profile.wishlistCount}', AppStrings.wishList),
                    const SizedBox(width: 24),
                    _buildStatItem('${profile.historyCount}', AppStrings.history),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomElevatedButton(
              title: AppStrings.editProfile,
              height: 46,
              onPressed: () => context.push(AppRoutes.editProfile),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: CustomOutlinedButton(
              title: AppStrings.logout,
              height: 46,
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

  Widget _buildTabsSection(ProfileEntity profile) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
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
                icon: Icon(Icons.history),
                text: AppStrings.history,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEmptyTabState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No Movies in Wish List',
                  subtitle: 'Explore movies and add your favorites to watch later',
                ),
                _buildEmptyTabState(
                  icon: Icons.history_toggle_off_rounded,
                  title: 'No Watch History',
                  subtitle: 'Movies you have watched will appear here',
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
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper typedef for text overflow
typedef TextEmitter = TextOverflow;
