import 'dart:async';

import 'package:csbingo/csbingo.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;

class ImagesGateway {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<List<RenderImage?>> loadImages(List<Cell> cells) async {
    return await Future.wait(
      List.generate(cells.length, (i) async {
        try {
          return await _getImage(cells[i]);
        } catch (e) {
          var asset = "assets/images/${cells[i].criteria}_placeholder.png";
          var bytes = await _getBytesFromLocalAsset(asset);
          return await Factory.rive.decodeImage(bytes);
        }
      }),
    );
  }

  Future<RenderImage?> _getImage(Cell cell) async {
    Uint8List? bytes;
    switch (cell.criteria) {
      case "nationality":
        bytes = await getImageFromUrl(
            "https://flagsapi.com/${cell.title}/flat/64.png");
        break;
      default:
        if (cell.imageUrl.startsWith("http")) {
          bytes = await getImageFromUrl(cell.imageUrl);
        } else {
          var asset = "assets/images/${cell.criteria}_placeholder.png";
          bytes = await _getBytesFromLocalAsset(asset);
        }
    }

    return await Factory.rive.decodeImage(bytes!);
  }

  Future<Uint8List> _getBytesFromLocalAsset(String asset) async =>
      (await rootBundle.load(asset)).buffer.asUint8List();

  Future<Uint8List?> getImageFromUrl(url) async {
    Uint8List? bytes;

    try {
      const proxyBase = 'https://vercel-image-proxy-nu.vercel.app/api/proxy';
      final proxiedUrl = '$proxyBase?url=${Uri.encodeComponent(url)}';

      var _httpClient = http.Client();

      final resp = await _httpClient.get(Uri.parse(proxiedUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Image request timeout for: $url');
        },
      );

      if (resp.statusCode == 200) {
        bytes = resp.bodyBytes;
      } else {
        print(
            "[CELL_IMAGE] Failed to retrieve image from url: $url (status: ${resp.statusCode})");
      }
    } catch (e) {
      print("[CELL_IMAGE] Error fetching image from url: $url - Error: $e");
    }

    return bytes;
  }
}
