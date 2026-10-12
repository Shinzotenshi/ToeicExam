import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/exam_models.dart';
import '../result_screen.dart';

class AdminSubmissionsScreen extends StatefulWidget {
  final int examId;
  final String examTitle;

  const AdminSubmissionsScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<AdminSubmissionsScreen> createState() => _AdminSubmissionsScreenState();
}

class _AdminSubmissionsScreenState extends State<AdminSubmissionsScreen> {
  List<ExamSubmissionSummary> _submissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getSubmissions(widget.examId);
      setState(() {
        _submissions = list;
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

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}p ${s.toString().padLeft(2, '0')}s';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSubs = _submissions.length;
    final avgScore = totalSubs > 0
        ? (_submissions.map((s) => s.score).reduce((a, b) => a + b) / totalSubs).round()
        : 0;
    final maxScore = totalSubs > 0
        ? _submissions.map((s) => s.score).reduce((a, b) => a > b ? a : b)
        : 0;
    final minScore = totalSubs > 0
        ? _submissions.map((s) => s.score).reduce((a, b) => a < b ? a : b)
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Kết Quả Thi: ${widget.examTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadSubmissions,
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
                      ElevatedButton(onPressed: _loadSubmissions, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Statistics Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Tổng bài nộp',
                                  '$totalSubs',
                                  Icons.people_alt,
                                  const Color(0xFF2563EB),
                                  const Color(0xFFEFF6FF),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  'Điểm trung bình',
                                  '$avgScore / 495',
                                  Icons.analytics,
                                  const Color(0xFF7C3AED),
                                  const Color(0xFFF5F3FF),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  'Điểm cao nhất',
                                  '$maxScore / 495',
                                  Icons.emoji_events,
                                  const Color(0xFF059669),
                                  const Color(0xFFECFDF5),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  'Điểm thấp nhất',
                                  '$minScore / 495',
                                  Icons.trending_down,
                                  const Color(0xFFDC2626),
                                  const Color(0xFFFEF2F2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Table / List of submissions
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Danh sách bài thi của thí sinh',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$totalSubs bài làm',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, color: Color(0xFFE2E8F0)),

                                  if (_submissions.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 40),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.inbox, size: 48, color: Color(0xFF94A3B8)),
                                            SizedBox(height: 12),
                                            Text(
                                              'Chưa có thí sinh nào nộp bài thi cho đề này.',
                                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _submissions.length,
                                      separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                      itemBuilder: (context, idx) {
                                        final sub = _submissions[idx];
                                        return _buildSubmissionRow(sub);
                                      },
                                    ),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionRow(ExamSubmissionSummary sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            radius: 20,
            child: Text(
              sub.candidateName.isNotEmpty ? sub.candidateName[0].toUpperCase() : 'T',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.candidateName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Nộp lúc: ${_formatDateTime(sub.submittedAt)} • Thời gian: ${_formatDuration(sub.timeSpentSeconds)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildBadge('${sub.correctCount} Đúng', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                const SizedBox(width: 6),
                _buildBadge('${sub.wrongCount} Sai', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                const SizedBox(width: 6),
                _buildBadge('${sub.skippedCount} Bỏ qua', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'ĐIỂM TOEIC',
                  style: TextStyle(fontSize: 9, color: Color(0xFF93C5FD), fontWeight: FontWeight.bold),
                ),
                Text(
                  '${sub.score}',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final result = await ApiService.getSubmissionResult(sub.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(result: result),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi tải bài làm: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              elevation: 0,
            ),
            icon: const Icon(Icons.remove_red_eye, size: 16),
            label: const Text('Xem Bài Làm'),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
