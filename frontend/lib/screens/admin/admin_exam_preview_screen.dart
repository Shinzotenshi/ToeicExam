import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/exam_models.dart';
import 'admin_exam_edit_screen.dart';

class AdminExamPreviewScreen extends StatefulWidget {
  final int examId;

  const AdminExamPreviewScreen({super.key, required this.examId});

  @override
  State<AdminExamPreviewScreen> createState() => _AdminExamPreviewScreenState();
}

class _AdminExamPreviewScreenState extends State<AdminExamPreviewScreen> {
  ExamDetailModel? _exam;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedPartFilter = 0; // 0: All, 5: Part 5, 6: Part 6, 7: Part 7

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exam = await ApiService.getAdminExamDetail(widget.examId);
      setState(() {
        _exam = exam;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _exam != null ? 'Xem Trước Đề: ${_exam!.title}' : 'Chi Tiết Đề Thi (Admin)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
        actions: [
          if (_exam != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminExamEditScreen(examId: widget.examId),
                    ),
                  );
                  _loadExam();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Chỉnh Sửa Đề'),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadExam, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : _exam == null
                  ? const Center(child: Text('Không tìm thấy dữ liệu đề thi.'))
                  : _buildExamContent(),
    );
  }

  Widget _buildExamContent() {
    final filteredGroups = _exam!.questionGroups.where((g) {
      if (_selectedPartFilter == 0) return true;
      return g.partNumber == _selectedPartFilter;
    }).toList();

    return Column(
      children: [
        // Sub-header with statistics & part tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'Mã #${_exam!.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tổng ${_exam!.totalQuestions} câu hỏi • Thời gian: ${_exam!.durationMinutes} phút',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          'Đáp án đúng đã đánh dấu',
                          style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả các phần (100 câu)', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('Phần 5: Điền câu (101 - 130)', 5),
                    const SizedBox(width: 8),
                    _buildFilterChip('Phần 6: Điền đoạn văn (131 - 146)', 6),
                    const SizedBox(width: 8),
                    _buildFilterChip('Phần 7: Đọc hiểu văn bản (147 - 200)', 7),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Question groups list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = filteredGroups[index];
              return _buildGroupCard(group);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int partNumber) {
    final isSelected = _selectedPartFilter == partNumber;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPartFilter = partNumber;
          });
        }
      },
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
    );
  }

  Widget _buildGroupCard(QuestionGroupModel group) {
    final hasPassage = group.passageText != null && group.passageText!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: group.partNumber == 5
                        ? const Color(0xFF3B82F6)
                        : group.partNumber == 6
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFEC4899),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Phần ${group.partNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.title.isNotEmpty ? group.title : 'Nhóm câu hỏi',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  ),
                ),
                Text(
                  '${group.questions.length} câu',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Passage Box (if Part 6 or 7)
          if (hasPassage)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book, size: 16, color: Color(0xFF475569)),
                      SizedBox(width: 6),
                      Text(
                        'ĐOẠN VĂN ĐỌC HIỂU (PASSAGE)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    group.passageText!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF0F172A),
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
            ),

          // Questions List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: group.questions.length,
            separatorBuilder: (_, _) => const Divider(height: 24, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, qIdx) {
              final q = group.questions[qIdx];
              return _buildQuestionItem(q);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(QuestionModel q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number & text
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Câu ${q.questionNumber}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SelectableText(
                q.content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 Options Grid/Column
        ...q.options.map((opt) {
          final isCorrect = q.correctOption?.toUpperCase() == opt.optionKey.toUpperCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                width: isCorrect ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCorrect ? const Color(0xFF10B981) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    opt.optionKey,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    opt.content,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF334155),
                    ),
                  ),
                ),
                if (isCorrect) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          'ĐÁP ÁN ĐÚNG',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        if (q.explanation != null && q.explanation!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Giải thích: ${q.explanation}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
