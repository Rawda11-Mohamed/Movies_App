import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => context.go(AppRoutes.editProfile),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileLoaded || state is ProfileUpdatedSuccess) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdatedSuccess).profile;
            return _ProfileContent(profile: profile);
          }
          return const Center(
            child: Text('No profile data', style: TextStyle(color: AppColors.textSecondary)),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;
  const _ProfileContent({required this.profile});

  static const List<IconData> _avatarIcons = [
    Icons.face,
    Icons.face_2,
    Icons.face_3,
    Icons.face_4,
    Icons.face_5,
    Icons.face_6,
  ];

  IconData _getAvatarIcon(String key) {
    final index = int.tryParse(key.replaceAll('avatar_', '')) ?? 1;
    return _avatarIcons[(index - 1).clamp(0, _avatarIcons.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          _buildStatsRow(context),
          const SizedBox(height: 20),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          _buildTabSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.surface,
          child: Icon(
            _getAvatarIcon(profile.avatarKey),
            size: 70,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatChip(label: AppStrings.wishList, count: profile.wishlistCount),
          _StatChip(label: AppStrings.history, count: profile.historyCount),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.editProfile),
              child: const Text(AppStrings.editProfile),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutRequested());
                context.read<ProfileBloc>().add(const ClearProfile());
                context.go(AppRoutes.login);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
              child: const Text(AppStrings.logout),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: AppStrings.wishList),
              Tab(text: AppStrings.history),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildEmptyTab('Your wishlist is empty'),
                _buildEmptyTab('No watch history yet'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.movie_creation_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  const _StatChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
