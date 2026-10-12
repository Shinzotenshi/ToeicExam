import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/exam_models.dart';
import '../exam_list_screen.dart';
import 'admin_import_word_screen.dart';
import 'admin_exam_preview_screen.dart';
import 'admin_exam_edit_screen.dart';
import 'admin_submissions_screen.dart';

class AdminExamListScreen extends StatefulWidget {
  const AdminExamListScreen({super.key});

  @override
  State<AdminExamListScreen> createState() => _AdminExamListScreenState();
}

class _AdminExamListScreenState extends State<AdminExamListScreen> {
  List<ExamSummary> _exams = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getExams();
      setState(() {
        _exams = list;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDeleteExam(ExamSummary exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa đề thi'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa "${exam.title}" (Mã #${exam.id})?\nToàn bộ câu hỏi và bài làm liên quan sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa Đề Thi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteExam(exam.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa đề thi #${exam.id} thành công!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
        _loadExams();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa đề: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF2563EB), size: 26),
            SizedBox(width: 10),
            Text(
              'TOEIC Exam System - Quản Trị Đề Thi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Switch to Candidate Mode Button
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamListScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF93C5FD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.school, size: 18),
              label: const Text('Chế độ Thí sinh'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            tooltip: 'Làm mới',
            onPressed: _loadExams,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadExams, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero Lecturer Dashboard Card
                          _buildHeroBanner(),
                          const SizedBox(height: 24),

                          // Header + Import Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Danh Sách Đề Thi TOEIC Reading',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hiện có ${_exams.length} đề thi trong cơ sở dữ liệu hệ thống',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdminImportWordScreen(),
                                    ),
                                  );
                                  _loadExams();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.upload_file, size: 20),
                                label: const Text(
                                  'Nhập Đề Từ File Word (.docx)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Exam Cards
                          if (_exams.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _exams.length,
                              itemBuilder: (context, index) {
                                final exam = _exams[index];
                                return _buildExamItemCard(exam);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x1F1E3A8A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 24,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cổng Giảng Viên & Quản Trị Hệ Thống',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Quản lý đề thi TOEIC Reading chuẩn ETS (Phần 5, 6, 7 - 100 câu)',
                        style: TextStyle(fontSize: 13, color: Color(0xFFBFDBFE)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Color(0xFF86EFAC)),
                    SizedBox(width: 6),
                    Text(
                      'Hệ thống trực tuyến v1.0',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 14),

          // Features highlights
          Row(
            children: [
              _buildFeatureBadge(Icons.auto_stories, '100 câu chuẩn ETS'),
              const SizedBox(width: 24),
              _buildFeatureBadge(Icons.timer, 'Thời gian 75 phút'),
              const SizedBox(width: 24),
              _buildFeatureBadge(Icons.rule_folder, 'Import Word kiểm duyệt 100%'),
              const SizedBox(width: 24),
              _buildFeatureBadge(Icons.grade, 'Thang điểm TOEIC 495'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF93C5FD)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.folder_open, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đề thi nào trong hệ thống',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy tải lên file Word (.docx) chuẩn readingv01 để khởi tạo đề thi ngay.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminImportWordScreen()),
                );
                _loadExams();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('Nhập đề thi ngay'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamItemCard(ExamSummary exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exam ID badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '#${exam.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exam.description.isNotEmpty ? exam.description : 'Đề thi TOEIC Reading chuẩn ETS quốc tế',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: exam.isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: exam.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    exam.isActive ? 'Đang mở' : 'Đóng',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: exam.isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meta tags row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildMetaChip(Icons.quiz, '${exam.totalQuestions} câu hỏi'),
                _buildMetaChip(Icons.timer, '${exam.durationMinutes} phút'),
                _buildMetaChip(Icons.menu_book, 'Phần 5, 6, 7'),
                _buildMetaChip(Icons.grading, 'Thang 495 điểm'),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFF1F5F9)),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 10,
                  children: [
                    // Preview Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminExamPreviewScreen(examId: exam.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Xem Trước'),
                    ),

                    // Edit Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminExamEditScreen(examId: exam.id),
                          ),
                        );
                        _loadExams();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Chỉnh Sửa Đề'),
                    ),

                    // Submissions Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminSubmissionsScreen(
                              examId: exam.id,
                              examTitle: exam.title,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                        side: const BorderSide(color: Color(0xFFDDD6FE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.analytics, size: 16),
                      label: const Text('Kết Quả Thi'),
                    ),
                  ],
                ),

                // Delete Button
                IconButton(
                  tooltip: 'Xóa đề thi này',
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                  onPressed: () => _handleDeleteExam(exam),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
