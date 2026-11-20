import 'package:movies_app/movies/data/models/movie_response_model.dart';

class Movies {
  int? id;
  String? url;
  String? imdbCode;
  String? title;
  String? titleEnglish;
  String? titleLong;
  String? slug;
  int? year;
  double? rating;
  int? runtime;
  List<String>? genres;
  String? summary;
  String? descriptionFull;
  String? synopsis;
  String? ytTrailerCode;
  String? language;
  String? mpaRating;
  String? backgroundImage;
  String? backgroundImageOriginal;
  String? smallCoverImage;
  String? mediumCoverImage;
  String? largeCoverImage;
  String? state;
  List<Torrents>? torrents;
  String? dateUploaded;
  int? dateUploadedUnix;

  Movies({
    this.id,
    this.url,
    this.imdbCode,
    this.title,
    this.titleEnglish,
    this.titleLong,
    this.slug,
    this.year,
    this.rating,
    this.runtime,
    this.genres,
    this.summary,
    this.descriptionFull,
    this.synopsis,
    this.ytTrailerCode,
    this.language,
    this.mpaRating,
    this.backgroundImage,
    this.backgroundImageOriginal,
    this.smallCoverImage,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.state,
    this.torrents,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  Movies.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    url = json["url"];
    imdbCode = json["imdb_code"];
    title = json["title"];
    titleEnglish = json["title_english"];
    titleLong = json["title_long"];
    slug = json["slug"];
    year = json["year"];
    rating = (json["rating"] as num?)?.toDouble();
    runtime = json["runtime"];
    genres = json["genres"] == null ? null : List<String>.from(json["genres"]);
    summary = json["summary"];
    descriptionFull = json["description_full"];
    synopsis = json["synopsis"];
    ytTrailerCode = json["yt_trailer_code"];
    language = json["language"];
    mpaRating = json["mpa_rating"];
    backgroundImage = json["background_image"];
    backgroundImageOriginal = json["background_image_original"];
    smallCoverImage = json["small_cover_image"];
    mediumCoverImage = json["medium_cover_image"];
    largeCoverImage = json["large_cover_image"];
    state = json["state"];
    torrents =
        json["torrents"] == null
            ? null
            : (json["torrents"] as List)
                .map((e) => Torrents.fromJson(e))
                .toList();
    dateUploaded = json["date_uploaded"];
    dateUploadedUnix = json["date_uploaded_unix"];
  }

  static List<Movies> fromList(List<Map<String, dynamic>> list) {
    return list.map(Movies.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["url"] = url;
    _data["imdb_code"] = imdbCode;
    _data["title"] = title;
    _data["title_english"] = titleEnglish;
    _data["title_long"] = titleLong;
    _data["slug"] = slug;
    _data["year"] = year;
    _data["rating"] = rating;
    _data["runtime"] = runtime;
    if (genres != null) {
      _data["genres"] = genres;
    }
    _data["summary"] = summary;
    _data["description_full"] = descriptionFull;
    _data["synopsis"] = synopsis;
    _data["yt_trailer_code"] = ytTrailerCode;
    _data["language"] = language;
    _data["mpa_rating"] = mpaRating;
    _data["background_image"] = backgroundImage;
    _data["background_image_original"] = backgroundImageOriginal;
    _data["small_cover_image"] = smallCoverImage;
    _data["medium_cover_image"] = mediumCoverImage;
    _data["large_cover_image"] = largeCoverImage;
    _data["state"] = state;
    if (torrents != null) {
      _data["torrents"] = torrents?.map((e) => e.toJson()).toList();
    }
    _data["date_uploaded"] = dateUploaded;
    _data["date_uploaded_unix"] = dateUploadedUnix;
    return _data;
  }
}
