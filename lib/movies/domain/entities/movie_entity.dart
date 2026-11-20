class MovieEntity {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String ytTrailerCode;
  final String language;
  final String backgroundImage;
  final String mediumCoverImage;
  final String largeCoverImage;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.ytTrailerCode,
    required this.language,
    required this.backgroundImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
  });
}