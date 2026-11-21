import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_movie_entity.dart';
import 'saved_movies_grid.dart';

class ProfileTabsSection extends StatelessWidget {
  final List<SavedMovieEntity> watchlist;
  final List<SavedMovieEntity> history;

  const ProfileTabsSection({
    super.key,
    required this.watchlist,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
        const TabBar(
  indicatorColor: AppColors.primary,
  labelColor: AppColors.textPrimary,
  unselectedLabelColor: AppColors.textPrimary,
  dividerColor: AppColors.divider,
  tabs: [
    Tab(
      icon: Icon(Icons.list, color: AppColors.primary),
      text: 'Watch List',
    ),
    Tab(
      icon: Icon(Icons.folder, color: AppColors.primary),
      text: 'History',
    ),
  ],
),
          Expanded(
            child: TabBarView(
              children: [
                SavedMoviesGrid(
                  movies: watchlist,
                  emptyMessage: 'No movies in your watch list',
                ),
                SavedMoviesGrid(
                  movies: history,
                  emptyMessage: 'No history yet',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}