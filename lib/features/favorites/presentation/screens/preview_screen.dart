import 'package:flutter/material.dart';
import 'package:movies_app/features/favorites/presentation/widgets/profile_tabs_section.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_movie_entity.dart';
import '../widgets/saved_movies_grid.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = List.generate(
      9,
      (i) => SavedMovieEntity(
        movieId: i,
        title: 'Movie $i',
        posterPath: 'https://picsum.photos/300/450?random=$i',
        rating: 6.0 + i * 0.3,
        savedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ProfileTabsSection(watchlist: movies, history: const []),
      ),
    );
  }
}
