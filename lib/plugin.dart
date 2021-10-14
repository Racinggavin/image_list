import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image_list/data/media.dart';

class ImageListPlugin {
  static const MethodChannel _channel = const MethodChannel('image_list');

  static Future<List<Album>?> getAlbums({
    List<MediaType> types = const <MediaType>[MediaType.image, MediaType.video],
  }) async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) return null;

    final List<dynamic> images = await _channel.invokeMethod(
      'getAlbums',
      {
        'types': types
            .map((e) => e.toString().replaceAll("MediaType.", "").toUpperCase())
            .join("-")
      },
    );
    List<Album> albums = <Album>[];
    for (var element in images) {
      albums.add(Album.fromJson(element));
    }
    return albums;
  }

  static Future<dynamic> checkPermission() async {
    final bool hasPermission = await _channel.invokeMethod('checkPermission');

    return hasPermission;
  }

  static Future<Uint8List> getThumbnail({
    required String imageUri,
    int? width,
    int? height,
    int? size,
    int quality = 100,
  }) async {
    final raw = await _channel.invokeMethod(
      'getThumbnail',
      {
        'uri': imageUri,
        'width': width,
        'height': height,
        'size': size,
        'quality': quality,
      },
    );

    return Uint8List.fromList(raw ?? <int>[]);
  }

  static Future<OriginalPhotoItem> getOriginal({
    required String imageUri,
    int quality = 100,
  }) async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'getOriginal',
      {
        'uri': imageUri,
        'quality': quality,
      },
    );

    return OriginalPhotoItem.fromMap(result);
  }

  static Future<Uint8List> getAlbumThumbnail({
    required String albumUri,
    int? width,
    int? height,
    int? size,
    int quality = 100,
  }) async {
    final raw = await _channel.invokeMethod(
      'getAlbumThumbnail',
      {
        'albumUri': albumUri,
        'width': width,
        'height': height,
        'size': size,
        'quality': quality,
      },
    );

    return Uint8List.fromList(raw ?? <int>[]);
  }
}

class Album {
  final String name;
  final String identifier;
  final int count;

  Album(this.name, this.identifier, this.count);

  factory Album.fromJson(Map<dynamic, dynamic>? raw) {
    if (raw == null) {
      return Album("", "", 0);
    }

    return Album(raw["name"] ?? "", raw["identifier"] ?? "", raw["count"] ?? 0);
  }

  Album copyWith({
    String? name,
    String? identifier,
    int? count,
  }) {
    return Album(
      name ?? this.name,
      identifier ?? this.identifier,
      count ?? this.count,
    );
  }

  @override
  String toString() {
    return "Album(name: $name, identifier: $identifier, count: $count)";
  }
}

class AlbumWithThumbnail extends Album {
  final Uint8List thumbnail;

  AlbumWithThumbnail(
    String name,
    String identifier,
    int count, {
    Uint8List? thumbnail,
  })  : this.thumbnail = thumbnail ?? Uint8List.fromList([]),
        super(name, identifier, count);

  static AlbumWithThumbnail fromAlbum(Album album, {Uint8List? thumbnail}) {
    return AlbumWithThumbnail(
      album.name,
      album.identifier,
      album.count,
      thumbnail: thumbnail,
    );
  }
}

class OriginalPhotoItem {
  final Size resolution;
  final int filesize;
  final Uint8List? image;
  final String filepath;
  const OriginalPhotoItem({
    required this.resolution,
    required this.filesize,
    this.image,
    required this.filepath,
  });

  static OriginalPhotoItem fromMap(Map<dynamic, dynamic> obj) {
    final width = (obj['width'] ?? 0).toDouble();
    final height = (obj['height'] ?? 0).toDouble();
    final filesize = obj['filesize'] ?? 0;
    final image = obj['image'];
    final filepath = obj['filepath'] ?? '';

    return OriginalPhotoItem(
      resolution: Size(width, height),
      filesize: filesize,
      image: image,
        filepath: filepath,
    );
  }
}