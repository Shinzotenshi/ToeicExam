import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../services/api_service.dart';
import 'exam_screen.dart';
import 'admin/admin_exam_list_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  late Future<List<ExamSummary>> _examsFuture;
  final TextEditingEx _candidateController = TextEditingEx(text: 'Hoàng Duy Mạnh - 2380601317');

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() {
    setState(() {
      _examsFuture = ApiService.getExams();
    });
  }

  void _showConfigServerDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình địa chỉ Backend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'API Base URL',
            hintText: 'http://localhost:5000/api/ToeicApi',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.baseUrl = controller.text.trim();
              Navigator.pop(ctx);
              _loadExams();
            },
            child: const Text('Lưu & Tải lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'TOEIC Reading Test',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Switch to Admin Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminExamListScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            icon: const Icon(Icons.admin_panel_settings, size: 16),
            label: const Text('Quản Trị Viên / Giảng Viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt kết nối server',
            onPressed: _showConfigServerDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadExams,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadExams(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Candidate Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_pin, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Thông tin thí sinh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _candidateController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        hintText: 'Nhập họ tên thí sinh / MSSV',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.badge, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Header
              const Row(
                children: [
                  Icon(Icons.assignment, color: Color(0xFF1E3A8A)),
                  SizedBox(width: 8),
                  Text(
                    'Danh sách đề thi có sẵn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exams Future List
              FutureBuilder<List<ExamSummary>>(
                future: _examsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Không thể tải danh sách đề thi',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _showConfigServerDialog,
                                icon: const Icon(Icons.settings),
                                label: const Text('Cấu hình IP'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _loadExams,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  final exams = snapshot.data ?? [];
                  if (exams.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có đề thi nào trong hệ thống',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Vui lòng import đề thi từ trang Admin trước.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.description, color: Color(0xFF2563EB), size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exam.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        if (exam.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            exam.description,
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _buildTag(Icons.timer, '${exam.durationMinutes} phút', Colors.orange),
                                  const SizedBox(width: 8),
                                  _buildTag(Icons.format_list_numbered, '${exam.totalQuestions} câu hỏi', Colors.blue),
                                  const SizedBox(width: 8),
                                  _buildTag(Icons.layers, 'Phần 5, 6, 7', Colors.purple),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExamScreen(
                                          examId: exam.id,
                                          examTitle: exam.title,
                                          candidateName: _candidateController.text.trim().isNotEmpty
                                              ? _candidateController.text.trim()
                                              : 'Thí sinh',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow, size: 20),
                                      SizedBox(width: 6),
                                      Text(
                                        'Bắt đầu làm bài thi',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.shade700),
          ),
        ],
      ),
    );
  }
}

class TextEditingEx extends TextEditingController {
  TextEditingEx({super.text});
}
