import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/exam_models.dart';

class AdminExamEditScreen extends StatefulWidget {
  final int examId;

  const AdminExamEditScreen({super.key, required this.examId});

  @override
  State<AdminExamEditScreen> createState() => _AdminExamEditScreenState();
}

class _AdminExamEditScreenState extends State<AdminExamEditScreen> with SingleTickerProviderStateMixin {
  ExamDetailModel? _exam;
  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  // Selected for editing
  QuestionGroupModel? _selectedGroup;
  QuestionModel? _selectedQuestion;

  // Form controllers for Group
  final _groupTitleController = TextEditingController();
  final _passageTextController = TextEditingController();
  bool _isSavingGroup = false;

  // Form controllers for Question
  final _questionContentController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  final _explanationController = TextEditingController();
  String _selectedCorrectKey = 'A';
  bool _isSavingQuestion = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExam();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupTitleController.dispose();
    _passageTextController.dispose();
    _questionContentController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    _explanationController.dispose();
    super.dispose();
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
        if (exam.questionGroups.isNotEmpty) {
          // Default to first group with passage or first group
          final groupWithPassage = exam.questionGroups.firstWhere(
            (g) => g.partNumber > 5,
            orElse: () => exam.questionGroups.first,
          );
          _selectGroup(groupWithPassage);

          final allQuestions = exam.getAllQuestions();
          if (allQuestions.isNotEmpty) {
            _selectQuestion(allQuestions.first);
          }
        }
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

  void _selectGroup(QuestionGroupModel group) {
    setState(() {
      _selectedGroup = group;
      _groupTitleController.text = group.title;
      _passageTextController.text = group.passageText ?? '';
    });
  }

  void _selectQuestion(QuestionModel question) {
    setState(() {
      _selectedQuestion = question;
      _questionContentController.text = question.content;
      _explanationController.text = question.explanation ?? '';
      _selectedCorrectKey = question.correctOption ?? 'A';

      // Options
      final optA = question.options.firstWhere((o) => o.optionKey == 'A', orElse: () => QuestionOptionModel(id: 0, questionId: question.id, optionKey: 'A', content: ''));
      final optB = question.options.firstWhere((o) => o.optionKey == 'B', orElse: () => QuestionOptionModel(id: 0, questionId: question.id, optionKey: 'B', content: ''));
      final optC = question.options.firstWhere((o) => o.optionKey == 'C', orElse: () => QuestionOptionModel(id: 0, questionId: question.id, optionKey: 'C', content: ''));
      final optD = question.options.firstWhere((o) => o.optionKey == 'D', orElse: () => QuestionOptionModel(id: 0, questionId: question.id, optionKey: 'D', content: ''));

      _optAController.text = optA.content;
      _optBController.text = optB.content;
      _optCController.text = optC.content;
      _optDController.text = optD.content;
    });
  }

  Future<void> _saveGroup() async {
    if (_selectedGroup == null) return;

    setState(() => _isSavingGroup = true);
    try {
      await ApiService.updateQuestionGroup(
        id: _selectedGroup!.id,
        title: _groupTitleController.text.trim(),
        passageText: _passageTextController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật nhóm & đoạn văn thành công!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
      _loadExam();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingGroup = false);
    }
  }

  Future<void> _saveQuestion() async {
    if (_selectedQuestion == null) return;

    setState(() => _isSavingQuestion = true);
    try {
      // Find IDs for options
      int getId(String key) {
        return _selectedQuestion!.options.firstWhere((o) => o.optionKey == key, orElse: () => QuestionOptionModel(id: 0, questionId: _selectedQuestion!.id, optionKey: key, content: '')).id;
      }

      final options = [
        {'id': getId('A'), 'optionKey': 'A', 'content': _optAController.text.trim()},
        {'id': getId('B'), 'optionKey': 'B', 'content': _optBController.text.trim()},
        {'id': getId('C'), 'optionKey': 'C', 'content': _optCController.text.trim()},
        {'id': getId('D'), 'optionKey': 'D', 'content': _optDController.text.trim()},
      ];

      await ApiService.updateQuestion(
        id: _selectedQuestion!.id,
        content: _questionContentController.text.trim(),
        correctOption: _selectedCorrectKey,
        explanation: _explanationController.text.trim(),
        options: options,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật câu hỏi #${_selectedQuestion!.questionNumber} thành công!'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
      _loadExam();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingQuestion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _exam != null ? 'Chỉnh Sửa Đề: ${_exam!.title}' : 'Chỉnh Sửa Đề Thi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(icon: Icon(Icons.quiz, size: 18), text: 'Chỉnh Sửa Câu Hỏi & Đáp Án'),
            Tab(icon: Icon(Icons.article, size: 18), text: 'Chỉnh Sửa Đoạn Văn Đọc Hiểu'),
          ],
        ),
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuestionEditorTab(),
                    _buildPassageEditorTab(),
                  ],
                ),
    );
  }

  // --- TAB 1: QUESTION EDITOR ---
  Widget _buildQuestionEditorTab() {
    final allQuestions = _exam?.getAllQuestions() ?? [];

    return Row(
      children: [
        // Left Column: Question selector list
        Container(
          width: 220,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF1F5F9),
                child: Text(
                  'Danh sách (${allQuestions.length} câu)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allQuestions.length,
                  itemBuilder: (context, idx) {
                    final q = allQuestions[idx];
                    final isSelected = _selectedQuestion?.id == q.id;

                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFEFF6FF),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        child: Text(
                          '${q.questionNumber}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      title: Text(
                        'Câu ${q.questionNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          q.correctOption ?? '?',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                        ),
                      ),
                      onTap: () => _selectQuestion(q),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right Column: Edit Question Form
        Expanded(
          child: _selectedQuestion == null
              ? const Center(child: Text('Vui lòng chọn câu hỏi cần chỉnh sửa.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chỉnh Sửa Câu Hỏi #${_selectedQuestion!.questionNumber}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isSavingQuestion ? null : _saveQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: _isSavingQuestion
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save, size: 18),
                                label: const Text('Lưu Thay Đổi Câu Hỏi', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Question content
                          const Text('Nội dung câu hỏi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _questionContentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Correct Key Selector
                          const Text('Đáp án đúng (KEY):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: ['A', 'B', 'C', 'D'].map((k) {
                              final isSelected = _selectedCorrectKey == k;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ChoiceChip(
                                  label: Text('Đáp án $k', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedCorrectKey = k);
                                  },
                                  selectedColor: const Color(0xFF16A34A),
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF334155)),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // 4 Options TextFields
                          const Text('Chi tiết 4 phương án lựa chọn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          _buildOptionInput('A', _optAController),
                          _buildOptionInput('B', _optBController),
                          _buildOptionInput('C', _optCController),
                          _buildOptionInput('D', _optDController),

                          const SizedBox(height: 20),
                          const Text('Giải thích / Hướng dẫn giải (nếu có):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _explanationController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Nhập giải thích ngữ pháp hoặc từ vựng...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOptionInput(String key, TextEditingController ctrl) {
    final isCorrect = _selectedCorrectKey == key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
            child: Text(
              key,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCorrect ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Nội dung phương án $key...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1)),
                ),
                filled: true,
                fillColor: isCorrect ? const Color(0xFFF0FDF4) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PASSAGE EDITOR ---
  Widget _buildPassageEditorTab() {
    final passageGroups = _exam?.questionGroups.where((g) => g.partNumber > 5).toList() ?? [];

    return Row(
      children: [
        // Left Column: Passage groups selector list
        Container(
          width: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF1F5F9),
                child: Text(
                  'Nhóm Đoạn Văn (Phần 6 & 7) - ${passageGroups.length} nhóm',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: passageGroups.length,
                  itemBuilder: (context, idx) {
                    final g = passageGroups[idx];
                    final isSelected = _selectedGroup?.id == g.id;

                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFEFF6FF),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: g.partNumber == 6 ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'P${g.partNumber}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        g.title.isNotEmpty ? g.title : 'Nhóm #${g.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        '${g.questions.length} câu hỏi',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      onTap: () => _selectGroup(g),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right Column: Edit Passage Form
        Expanded(
          child: _selectedGroup == null
              ? const Center(child: Text('Vui lòng chọn nhóm đoạn văn cần chỉnh sửa.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chỉnh Sửa Nhóm Đoạn Văn Phần ${_selectedGroup!.partNumber}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    'Mã nhóm: #${_selectedGroup!.id} • Bao gồm ${_selectedGroup!.questions.length} câu hỏi con',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _isSavingGroup ? null : _saveGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: _isSavingGroup
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save, size: 18),
                                label: const Text('Lưu Thay Đổi Đoạn Văn', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Group Title
                          const Text('Tiêu đề / Hướng dẫn đoạn văn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _groupTitleController,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: Questions 131-134 refer to the following email.',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Passage Text
                          const Text('Nội dung đoạn văn (Passage Text):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passageTextController,
                            maxLines: 15,
                            style: const TextStyle(fontFamily: 'serif', fontSize: 14, height: 1.5),
                            decoration: InputDecoration(
                              hintText: 'Nhập nội dung bài đọc đọc hiểu ở đây...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
