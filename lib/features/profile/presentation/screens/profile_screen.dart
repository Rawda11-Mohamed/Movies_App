import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';

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
      context.read<ProfileBloc>().add(LoadProfile(
            uid: authState.user.uid,
            email: authState.user.email,
            displayName: authState.user.displayName,
          ));
    }
  }

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
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;
  const _ProfileContent({required this.profile});

  /// Returns an [ImageProvider] for the given avatar key.
  /// - `avatar_1` / `avatar_2` / `avatar_3` → asset image
  /// - http URL → NetworkImage
  /// - local file path → FileImage
  ImageProvider _resolveAvatar(String key) {
    if (key.startsWith('http')) return NetworkImage(key);
    if (key.startsWith('/') || key.contains(r':\')) {
      final file = File(key);
      if (file.existsSync()) return FileImage(file);
    }
    final index = (int.tryParse(key.replaceAll('avatar_', '')) ?? 1) - 1;
    final safeIndex = index.clamp(0, AppConstants.avatarImages.length - 1);
    return AssetImage(AppConstants.avatarImages[safeIndex]);
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
    final imageProvider = _resolveAvatar(profile.avatarKey);

    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.surface,
          backgroundImage: imageProvider,
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName.isNotEmpty ? profile.displayName : 'Movie Fan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
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
