import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../domain/entities/saved_movie_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_state.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_state.dart';
import 'saved_movies_grid.dart';

class ProfileTabsSection extends StatelessWidget {
  const ProfileTabsSection({super.key});

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
                BlocBuilder<WatchlistBloc, WatchlistState>(
                  builder: (context, state) {
                    if (state is WatchlistLoading) {
                      return const CustomLoadingIndicator();
                    }
                    if (state is WatchlistError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    final List<SavedMovieEntity> movies =
                        state is WatchlistLoaded ? state.movies : const [];
                    return SavedMoviesGrid(
                      movies: movies,
                      emptyMessage: 'No movies in your watch list',
                    );
                  },
                ),
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return const CustomLoadingIndicator();
                    }
                    if (state is HistoryError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    final List<SavedMovieEntity> movies =
                        state is HistoryLoaded ? state.movies : const [];
                    return SavedMoviesGrid(
                      movies: movies,
                      emptyMessage: 'No history yet',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}