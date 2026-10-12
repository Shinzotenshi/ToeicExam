import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/exam_models.dart';
import 'admin_exam_preview_screen.dart';

class AdminImportWordScreen extends StatefulWidget {
  const AdminImportWordScreen({super.key});

  @override
  State<AdminImportWordScreen> createState() => _AdminImportWordScreenState();
}

class _AdminImportWordScreenState extends State<AdminImportWordScreen> {
  final _pathController = TextEditingController(
    text: r'c:\Users\ADMIN\Downloads\ToeicExam\readingv01.docx',
  );
  final _titleController = TextEditingController(
    text: 'Đề thi TOEIC Reading v01 ETS Chuẩn',
  );

  bool _isLoading = false;
  ImportExamResultModel? _importResult;
  String? _errorMessage;

  @override
  void dispose() {
    _pathController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    final path = _pathController.text.trim();
    final title = _titleController.text.trim();

    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đường dẫn file .docx.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _importResult = null;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.importExamByPath(path, title);
      setState(() {
        _importResult = result;
      });
      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nhập đề thi thành công! Đã tạo mã #${result.examId}'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Nhập Đề Thi Từ File Word (.docx)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top introduction banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.upload_file, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhập Đề Thi TOEIC Reading Tự Động (ETS 100 câu)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Hệ thống áp dụng thuật toán kiểm duyệt cú pháp nghiêm ngặt 100%. File Word (.docx) phải tuân thủ chuẩn các thẻ [PART: 5/6/7], [PASSAGE_START], [PASSAGE_END], [Q: xxx], [A]..[D], [KEY: x]. Nếu phát hiện bất kỳ sai sót nào về số câu, thiếu đáp án hoặc lệch thẻ, hệ thống sẽ từ chối và liệt kê chi tiết để giảng viên chỉnh sửa.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Form Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin đề thi & Đường dẫn file',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),

                        // Title input
                        const Text(
                          'Tên đề thi hiển thị:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên đề thi TOEIC...',
                            prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // File path input
                        const Text(
                          'Đường dẫn tuyệt đối file Word (.docx) trên máy:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _pathController,
                          decoration: InputDecoration(
                            hintText: r'c:\Users\ADMIN\Downloads\ToeicExam\readingv01.docx',
                            prefixIcon: const Icon(Icons.description, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            suffixIcon: IconButton(
                              tooltip: 'Sử dụng file mẫu readingv01.docx',
                              icon: const Icon(Icons.restore, color: Color(0xFF2563EB)),
                              onPressed: () {
                                _pathController.text = r'c:\Users\ADMIN\Downloads\ToeicExam\readingv01.docx';
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Quick path chips
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.file_present, size: 16, color: Color(0xFF2563EB)),
                              label: const Text('File chuẩn: readingv01.docx', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _pathController.text = r'c:\Users\ADMIN\Downloads\ToeicExam\readingv01.docx';
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleImport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                              _isLoading ? 'Đang kiểm duyệt và xử lý dữ liệu...' : 'Bắt đầu Kiểm duyệt & Tạo Đề thi',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Success Card
                if (_importResult != null && _importResult!.success) ...[
                  Card(
                    color: const Color(0xFFF0FDF4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nhập Đề Thi Thành Công 100%!',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _importResult!.message,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF15803D)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28, color: Color(0xFFBBF7D0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mã đề thi: #${_importResult!.examId} | Tổng số câu: ${_importResult!.totalQuestionsParsed} câu',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14532D)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminExamPreviewScreen(examId: _importResult!.examId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Xem Trước Đề'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Validation Errors Card
                if (_importResult != null && !_importResult!.success) ...[
                  Card(
                    color: const Color(0xFFFEF2F2),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Không thể tạo đề thi - File Word vi phạm quy chuẩn',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _importResult!.message,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFFED7D7)),
                          const Text(
                            'Chi tiết các lỗi được phát hiện:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D), fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _importResult!.validationErrors.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _importResult!.validationErrors[index],
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Error Exception Message
                if (_errorMessage != null) ...[
                  Card(
                    color: const Color(0xFFFEF2F2),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off, color: Color(0xFFDC2626)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Syntax Guidelines Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.rule, color: Color(0xFF475569)),
                            SizedBox(width: 8),
                            Text(
                              'Quy Định Định Dạng Thẻ (Tags) Trong File Word:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildRuleItem('Phần thi', '[PART: 5], [PART: 6], [PART: 7]'),
                        _buildRuleItem('Đoạn văn (Part 6, 7)', 'Bắt đầu bằng [PASSAGE_START] và kết thúc bằng [PASSAGE_END]'),
                        _buildRuleItem('Câu hỏi', '[Q: 101] Nội dung câu hỏi... (đánh số liên tục từ 101 đến 200)'),
                        _buildRuleItem('Bốn đáp án', '[A] ... [B] ... [C] ... [D] ... (bắt buộc đủ 4 đáp án)'),
                        _buildRuleItem('Đáp án đúng', '[KEY: A] (hoặc B, C, D) đặt ngay dưới câu hỏi'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF0F172A),
                backgroundColor: Color(0xFFF1F5F9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
