import 'package:movies_app/movies/data/models/movie_model.dart';

class MovieListModel {
  String? status;
  String? statusMessage;
  Data? data;

  MovieListModel({this.status, this.statusMessage, this.data});

  MovieListModel.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    statusMessage = json["status_message"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  static List<MovieListModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(MovieListModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["status"] = status;
    _data["status_message"] = statusMessage;
    if (data != null) {
      _data["data"] = data?.toJson();
    }

    return _data;
  }
}

class Data {
  int? movieCount;
  int? limit;
  int? pageNumber;
  List<Movies>? movies;

  Data({this.movieCount, this.limit, this.pageNumber, this.movies});

  Data.fromJson(Map<String, dynamic> json) {
    movieCount = json["movie_count"];
    limit = json["limit"];
    pageNumber = json["page_number"];
    movies =
        json["movies"] == null
            ? null
            : (json["movies"] as List).map((e) => Movies.fromJson(e)).toList();
  }

  static List<Data> fromList(List<Map<String, dynamic>> list) {
    return list.map(Data.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["movie_count"] = movieCount;
    _data["limit"] = limit;
    _data["page_number"] = pageNumber;
    if (movies != null) {
      _data["movies"] = movies?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}


class Torrents {
  String? url;
  String? hash;
  String? quality;
  String? type;
  String? isRepack;
  String? videoCodec;
  String? bitDepth;
  String? audioChannels;
  int? seeds;
  int? peers;
  String? size;
  int? sizeBytes;
  String? dateUploaded;
  int? dateUploadedUnix;

  Torrents({
    this.url,
    this.hash,
    this.quality,
    this.type,
    this.isRepack,
    this.videoCodec,
    this.bitDepth,
    this.audioChannels,
    this.seeds,
    this.peers,
    this.size,
    this.sizeBytes,
    this.dateUploaded,
    this.dateUploadedUnix,
  });

  Torrents.fromJson(Map<String, dynamic> json) {
    url = json["url"];
    hash = json["hash"];
    quality = json["quality"];
    type = json["type"];
    isRepack = json["is_repack"];
    videoCodec = json["video_codec"];
    bitDepth = json["bit_depth"];
    audioChannels = json["audio_channels"];
    seeds = json["seeds"];
    peers = json["peers"];
    size = json["size"];
    sizeBytes = json["size_bytes"];
    dateUploaded = json["date_uploaded"];
    dateUploadedUnix = json["date_uploaded_unix"];
  }

  static List<Torrents> fromList(List<Map<String, dynamic>> list) {
    return list.map(Torrents.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["url"] = url;
    _data["hash"] = hash;
    _data["quality"] = quality;
    _data["type"] = type;
    _data["is_repack"] = isRepack;
    _data["video_codec"] = videoCodec;
    _data["bit_depth"] = bitDepth;
    _data["audio_channels"] = audioChannels;
    _data["seeds"] = seeds;
    _data["peers"] = peers;
    _data["size"] = size;
    _data["size_bytes"] = sizeBytes;
    _data["date_uploaded"] = dateUploaded;
    _data["date_uploaded_unix"] = dateUploadedUnix;
    return _data;
  }
}
