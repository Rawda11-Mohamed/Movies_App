import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/movies/presentation/bloc/movie_details/movie_details_bloc.dart';
import 'package:movies_app/movies/presentation/bloc/movie_details/movie_details_event.dart';
import 'package:movies_app/movies/presentation/bloc/movie_details/movie_details_state.dart';

// 🔧 [3] الألوان دي مؤقتة، استبدليها بـ AppColors
const _bg = Color(0xFF121312);
const _card = Color(0xFF282A28);
const _gold = Color(0xFFF6BD00);
const _red = Color(0xFFE82626);

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoaded) {
            return _Content(movie: state.movie);
          }
          if (state is MovieDetailsError) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      // 🔧 [1] LoadMovieDetailsEvent لازم يطابق constructor الـ event بتاعك
                      onPressed: () => context
                          .read<MovieDetailsBloc>()
                          .add(LoadMovieDetailsEvent(movieId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.movie});

  // 🔧 [4] غيّري dynamic لنوع الـ entity بتاعك
  final dynamic movie;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(movie: movie),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    // TODO: افتحي الـ trailer أو الفيديو
                    onPressed: () {},
                    child: const Text(
                      'Watch',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    // 🔧 [6] بدّلي الـ Icons بأيقونات الـ Figma من AppAssets
                    _Badge(icon: Icons.favorite, value: '${movie.likeCount}'),
                    SizedBox(width: 10.w),
                    _Badge(icon: Icons.timer, value: '${movie.runtime}'),
                    SizedBox(width: 10.w),
                    _Badge(icon: Icons.star, value: '${movie.rating}'),
                  ],
                ),
                if ((movie.screenshots as List).isNotEmpty) ...[
                  const _SectionTitle('Screen Shots'),
                  for (final url in movie.screenshots as List<String>)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _NetImage(url: url, height: 160.h, radius: 12.r),
                    ),
                ],
                // 🔧 [7] هنا قسم Similar (لسه ما اتعملش، شوفي النقطة 7 تحت)
                const _SectionTitle('Summary'),
                Text(
                  movie.summary ?? '',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                if ((movie.cast as List).isNotEmpty) ...[
                  const _SectionTitle('Cast'),
                  for (final member in movie.cast as List)
                    _CastTile(member: member),
                ],
                const _SectionTitle('Genres'),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final g in movie.genres as List<String>)
                      _GenreChip(label: g),
                  ],
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.movie});

  final dynamic movie;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _NetImage(url: movie.largeCoverImage, height: 480.h, radius: 0),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _bg.withOpacity(0.95)],
                stops: const [0.5, 1],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  // TODO: Watch list
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(Icons.play_circle_fill, size: 72.r, color: _gold),
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 8.h,
          child: Column(
            children: [
              Text(
                movie.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${movie.year}',
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage({
    required this.url,
    required this.height,
    required this.radius,
  });

  final String? url;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url ?? '',
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(height: height, color: _card),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: _card,
          child: const Icon(Icons.broken_image, color: Colors.white38),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _gold, size: 20.r),
            SizedBox(width: 6.w),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final dynamic member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: member.imageUrl ?? '',
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 50.w,
                height: 50.w,
                color: Colors.black26,
                child: const Icon(Icons.person, color: Colors.white38),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name : ${member.name}',
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Character : ${member.characterName}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}