import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  final String candidateName;

  const ExamScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.candidateName,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with SingleTickerProviderStateMixin {
  late Future<ExamDetailModel> _examFuture;
  ExamDetailModel? _examData;
  List<QuestionModel> _allQuestions = [];

  // Selected Answers: Map<questionId, optionKey>
  final Map<int, String> _userAnswers = {};

  // Timer: 75 minutes = 4500 seconds
  int _remainingSeconds = 75 * 60;
  Timer? _countdownTimer;
  bool _isSubmitting = false;
  bool _isLocked = false;
  DateTime _startTime = DateTime.now();

  // Part filter: 0 = All, 5 = Part 5, 6 = Part 6, 7 = Part 7
  int _selectedPart = 5;

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  void _loadExam() {
    _examFuture = ApiService.getExamDetail(widget.examId);
    _examFuture.then((data) {
      if (!mounted) return;
      setState(() {
        _examData = data;
        _remainingSeconds = data.durationMinutes * 60;
        _allQuestions = data.getAllQuestions();
        for (var q in _allQuestions) {
          _questionKeys[q.questionNumber] = GlobalKey();
        }
      });
      _startTimer();
    }).catchError((_) {});
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // 3 minutes alert
        if (_remainingSeconds == 180) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Chú ý: Thời gian làm bài chỉ còn 3 phút!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (_isSubmitting || _isLocked) return;
    setState(() {
      _isLocked = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Hết giờ làm bài!'),
          ],
        ),
        content: const Text(
          'Thời gian thi đã kết thúc. Hệ thống đang tiến hành tự động thu bài và khóa quyền chọn đáp án...',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitExamNow();
            },
            child: const Text('Xem kết quả ngay'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _submitExamNow();
    });
  }

  void _toggleOption(int questionId, String optionKey) {
    if (_isLocked || _isSubmitting) return;
    setState(() {
      if (_userAnswers[questionId] == optionKey) {
        // Uncheck / cancel selection
        _userAnswers.remove(questionId);
      } else {
        // Change selection
        _userAnswers[questionId] = optionKey;
      }
    });
  }

  void _confirmSubmit() {
    if (_isLocked || _isSubmitting) return;

    final total = _allQuestions.length;
    final answered = _userAnswers.length;
    final unAnswered = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              unAnswered > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: unAnswered > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            const Text('Xác nhận nộp bài thi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng số câu hỏi: $total'),
            const SizedBox(height: 4),
            Text(
              'Số câu đã làm: $answered',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              'Số câu chưa làm: $unAnswered',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unAnswered > 0 ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            if (unAnswered > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'Cảnh báo: Bạn vẫn còn câu hỏi chưa chọn đáp án! Bạn có chắc chắn muốn nộp bài thi ngay bây giờ không?',
                  style: TextStyle(fontSize: 13, color: Colors.deepOrange),
                ),
              )
            else
              const Text('Bạn đã trả lời đầy đủ tất cả câu hỏi! Nhấn "Nộp bài" để hoàn tất.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục làm bài'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _submitExamNow();
            },
            child: const Text('Xác nhận nộp bài'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExamNow() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _isLocked = true;
    });
    _countdownTimer?.cancel();

    final timeSpent = DateTime.now().difference(_startTime).inSeconds;

    final answerItems = _allQuestions.map((q) {
      return SubmitAnswerItem(
        questionId: q.id,
        questionNumber: q.questionNumber,
        selectedOption: _userAnswers[q.id],
      );
    }).toList();

    try {
      final result = await ApiService.submitExam(
        examId: widget.examId,
        candidateName: widget.candidateName,
        timeSpentSeconds: timeSpent,
        answers: answerItems,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isLocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi nộp bài: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToQuestion(int questionNumber) {
    // Find part of this question
    final q = _allQuestions.firstWhere(
      (element) => element.questionNumber == questionNumber,
      orElse: () => _allQuestions.first,
    );
    int part = 5;
    if (_examData != null) {
      for (var g in _examData!.questionGroups) {
        if (g.questions.any((x) => x.id == q.id)) {
          part = g.partNumber;
          break;
        }
      }
    }

    setState(() {
      _selectedPart = part;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _questionKeys[questionNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _openQuestionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollCtrl) {
            final answeredCount = _userAnswers.length;
            final total = _allQuestions.length;

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bảng danh sách câu hỏi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Đã làm: $answeredCount',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.radio_button_unchecked, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Chưa làm: ${total - answeredCount}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollCtrl,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _allQuestions.length,
                      itemBuilder: (context, idx) {
                        final q = _allQuestions[idx];
                        final selectedOpt = _userAnswers[q.id];
                        final isAnswered = selectedOpt != null;

                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _scrollToQuestion(q.questionNumber);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isAnswered ? const Color(0xFF2563EB) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isAnswered ? const Color(0xFF1D4ED8) : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${q.questionNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isAnswered ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (isAnswered)
                                  Text(
                                    '[$selectedOpt]',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimer(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 180) return Colors.red;
    if (_remainingSeconds <= 600) return Colors.orange;
    return const Color(0xFF10B981);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Thoát bài thi?'),
            content: const Text('Bạn có chắc chắn muốn rời khỏi bài thi? Bài làm của bạn sẽ không được lưu.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ở lại')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Rời khỏi')),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 1,
          titleSpacing: 0,
          title: Row(
            children: [
              // Timer Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getTimerColor()),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18, color: _getTimerColor()),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimer(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTimerColor(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Progress text
              Text(
                '${_userAnswers.length}/${_allQuestions.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view, color: Color(0xFF2563EB)),
              tooltip: 'Bảng câu hỏi',
              onPressed: _openQuestionSheet,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSubmitting ? null : _confirmSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Nộp bài',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<ExamDetailModel>(
          future: _examFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải đề thi: ${snapshot.error}'));
            }

            final exam = snapshot.data!;
            final filteredGroups = exam.questionGroups.where((g) {
              if (_selectedPart == 0) return true;
              return g.partNumber == _selectedPart;
            }).toList();

            return Column(
              children: [
                // Part Filter Segmented Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildPartButton(5, 'Phần 5', 'Câu 101 - 130'),
                      const SizedBox(width: 8),
                      _buildPartButton(6, 'Phần 6', 'Câu 131 - 146'),
                      const SizedBox(width: 8),
                      _buildPartButton(7, 'Phần 7', 'Câu 147 - 200'),
                    ],
                  ),
                ),

                // Question List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, gIndex) {
                      final group = filteredGroups[gIndex];
                      return _buildGroupCard(group);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _openQuestionSheet,
                icon: const Icon(Icons.checklist),
                label: Text('Tiến độ: ${_userAnswers.length}/${_allQuestions.length} câu'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _confirmSubmit,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Nộp bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartButton(int part, String label, String sub) {
    final isSelected = _selectedPart == part;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPart = part),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white.withOpacity(0.85) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(QuestionGroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (group.partNumber != 5) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Phần ${group.partNumber}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            if (group.passageText != null && group.passageText!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  group.passageText!,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF1E293B)),
                ),
              ),
          ],

          // Questions List
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: group.questions.map((q) => _buildQuestionItem(q)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(QuestionModel q) {
    final selectedOption = _userAnswers[q.id];

    return Container(
      key: _questionKeys[q.questionNumber],
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selectedOption != null ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedOption != null ? Colors.green.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedOption != null ? Colors.green : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${q.questionNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.content.isNotEmpty ? q.content : 'Chọn đáp án thích hợp:',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: q.options.map((opt) {
              final isChosen = selectedOption == opt.optionKey;
              return InkWell(
                onTap: () => _toggleOption(q.id, opt.optionKey),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isChosen ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChosen ? const Color(0xFF1D4ED8) : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChosen ? Colors.white : Colors.transparent,
                          border: Border.all(
                            color: isChosen ? Colors.white : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          opt.optionKey,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isChosen ? const Color(0xFF2563EB) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: isChosen ? Colors.white : const Color(0xFF1E293B),
                            fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
