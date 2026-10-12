import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exam_models.dart';

class ApiService {
  // Can be configured or changed at runtime
  static String baseUrl = 'http://localhost:5000/api/ToeicApi';

  // Alternative fallback urls
  static final List<String> fallbackUrls = [
    'http://localhost:5000/api/ToeicApi',
    'https://localhost:44312/api/ToeicApi',
    'http://10.0.2.2:5000/api/ToeicApi', // Android emulator
  ];

  static dynamic _extractData(dynamic raw) {
    if (raw is Map && raw.containsKey('result')) {
      return raw['result'];
    }
    return raw;
  }

  static Future<List<ExamSummary>> getExams() async {
    Exception? lastEx;
    for (var url in [baseUrl, ...fallbackUrls.where((u) => u != baseUrl)]) {
      try {
        final uri = Uri.parse('$url/exams');
        final response = await http.get(uri).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          baseUrl = url;
          final raw = json.decode(utf8.decode(response.bodyBytes));
          final data = _extractData(raw);
          if (data is List) {
            return data.map((e) => ExamSummary.fromJson(e)).toList();
          }
        }
      } catch (e) {
        lastEx = Exception('URL $url thất bại: $e');
      }
    }
    throw lastEx ?? Exception('Không thể kết nối tới máy chủ Backend.');
  }

  static Future<ExamDetailModel> getExamDetail(int examId) async {
    final uri = Uri.parse('$baseUrl/exams/$examId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      final data = _extractData(raw);
      return ExamDetailModel.fromJson(data);
    } else {
      throw Exception('Lỗi tải đề thi: Mã ${response.statusCode}');
    }
  }

  static Future<ExamResultModel> submitExam({
    required int examId,
    required String candidateName,
    required int timeSpentSeconds,
    required List<SubmitAnswerItem> answers,
  }) async {
    final uri = Uri.parse('$baseUrl/submit');
    final body = json.encode({
      'examId': examId,
      'candidateName': candidateName,
      'timeSpentSeconds': timeSpentSeconds,
      'answers': answers.map((a) => a.toJson()).toList(),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      final data = _extractData(raw);
      return ExamResultModel.fromJson(data);
    } else {
      throw Exception('Lỗi nộp bài thi: Mã ${response.statusCode} - ${response.body}');
    }
  }

  static Future<ExamResultModel> getSubmissionResult(int submissionId) async {
    final uri = Uri.parse('$baseUrl/submission/$submissionId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      final data = _extractData(raw);
      return ExamResultModel.fromJson(data);
    } else {
      throw Exception('Lỗi lấy kết quả: Mã ${response.statusCode}');
    }
  }

  // Admin APIs
  static Future<ExamDetailModel> getAdminExamDetail(int examId) async {
    final uri = Uri.parse('$baseUrl/admin/exams/$examId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      final data = _extractData(raw);
      return ExamDetailModel.fromJson(data);
    } else {
      throw Exception('Lỗi tải chi tiết đề thi Admin: Mã ${response.statusCode}');
    }
  }

  static Future<ImportExamResultModel> importExamByPath(String filePath, String customTitle) async {
    final uri = Uri.parse('$baseUrl/upload-path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'filePath': filePath,
        'customTitle': customTitle,
      }),
    ).timeout(const Duration(seconds: 30));

    final raw = json.decode(utf8.decode(response.bodyBytes));
    final data = _extractData(raw);
    return ImportExamResultModel.fromJson(data);
  }

  static Future<bool> updateQuestion({
    required int id,
    required String content,
    required String correctOption,
    required String explanation,
    required List<Map<String, dynamic>> options,
  }) async {
    final uri = Uri.parse('$baseUrl/update-question');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'content': content,
        'correctOption': correctOption,
        'explanation': explanation,
        'options': options,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Lỗi lưu câu hỏi: Mã ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> updateQuestionGroup({
    required int id,
    required String title,
    required String passageText,
  }) async {
    final uri = Uri.parse('$baseUrl/update-group');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'title': title,
        'passageText': passageText,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Lỗi lưu đoạn văn nhóm: Mã ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> deleteExam(int examId) async {
    final uri = Uri.parse('$baseUrl/exams/$examId');
    final response = await http.delete(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Lỗi xóa đề thi: Mã ${response.statusCode}');
    }
  }

  static Future<List<ExamSubmissionSummary>> getSubmissions(int examId) async {
    final uri = Uri.parse('$baseUrl/submissions/$examId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final raw = json.decode(utf8.decode(response.bodyBytes));
      final data = _extractData(raw);
      if (data is List) {
        return data.map((e) => ExamSubmissionSummary.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Lỗi lấy danh sách bài nộp: Mã ${response.statusCode}');
    }
  }
}

