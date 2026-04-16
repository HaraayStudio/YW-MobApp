import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'token_service.dart';
import '../api/constants.dart';

class StageService {
  static String get baseUrl => "${ApiConstants.baseUrl}/stages";

  /// POST /api/stages/{stageId}/documents/addDocument/{documentName}/{documentType}
  static Future<bool> addStageDocument({
    required int stageId,
    required File file,
    required String documentName,
    required String documentType,
    String? description,
  }) async {
    final token = TokenService.accessToken;
    try {
      // URL Encode name and type to handle spaces/special characters
      final encodedName = Uri.encodeComponent(documentName);
      final encodedType = Uri.encodeComponent(documentType);
      
      final uri = Uri.parse("$baseUrl/$stageId/documents/addDocument/$encodedName/$encodedType");
      print("UPLOADING DOCUMENT TO: $uri");
      
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['description'] = description ?? "";

      final multipartFile = await http.MultipartFile.fromPath(
        'document', 
        file.path,
        filename: documentName,
        contentType: _getMediaType(file.path),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("UPLOAD STATUS: ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("UPLOAD ERROR BODY: ${response.body}");
      }
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR UPLOADING STAGE DOCUMENT: $e");
      return false;
    }
  }

  static MediaType _getMediaType(String path) {
    String ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
