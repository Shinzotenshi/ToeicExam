import 'package:flutter/material.dart';
import '../models/exam_models.dart';

class ResultScreen extends StatefulWidget {
  final ExamResultModel result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Filter: 'all', 'correct', 'wrong', 'skipped'
  String _filter = 'all';

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m phút $s giây';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    final filteredDetails = r.details.where((d) {
      if (_filter == 'correct') return d.isCorrect;
      if (_filter == 'wrong') return !d.isCorrect && (d.selectedOption != null && d.selectedOption!.isNotEmpty);
      if (_filter == 'skipped') return d.selectedOption == null || d.selectedOption!.isEmpty;
      return true;
    }).toList();

    final percentage = r.totalQuestions > 0 ? (r.correctCount / r.totalQuestions) * 100 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kết Quả Bài Thi TOEIC', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    r.examTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.candidateName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Score badge
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${r.score}',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const Text(
                          '/ 495 điểm',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Tỷ lệ chính xác: ${percentage.toStringAsFixed(1)}% • Thời gian: ${_formatDuration(r.timeSpentSeconds)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stat Cards Row
            Row(
              children: [
                _buildStatCard(
                  'Đúng',
                  '${r.correctCount}',
                  Colors.green,
                  Icons.check_circle,
                  _filter == 'correct',
                  () => setState(() => _filter = _filter == 'correct' ? 'all' : 'correct'),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Sai',
                  '${r.wrongCount}',
                  Colors.red,
                  Icons.cancel,
                  _filter == 'wrong',
                  () => setState(() => _filter = _filter == 'wrong' ? 'all' : 'wrong'),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Bỏ qua',
                  '${r.skippedCount}',
                  Colors.amber.shade800,
                  Icons.help_outline,
                  _filter == 'skipped',
                  () => setState(() => _filter = _filter == 'skipped' ? 'all' : 'skipped'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Filter Chips
            Row(
              children: [
                const Text('Lọc kết quả: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                _buildFilterChip('Tất cả (${r.totalQuestions})', 'all'),
                const SizedBox(width: 6),
                _buildFilterChip('Đúng (${r.correctCount})', 'correct'),
                const SizedBox(width: 6),
                _buildFilterChip('Sai (${r.wrongCount})', 'wrong'),
                const SizedBox(width: 6),
                _buildFilterChip('Bỏ qua (${r.skippedCount})', 'skipped'),
              ],
            ),

            const SizedBox(height: 16),

            // Detailed Answers List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDetails.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final d = filteredDetails[index];
                final isSkipped = d.selectedOption == null || d.selectedOption!.isEmpty;

                Color statusColor;
                IconData statusIcon;
                String statusLabel;

                if (isSkipped) {
                  statusColor = Colors.orange;
                  statusIcon = Icons.remove_circle_outline;
                  statusLabel = 'Chưa làm';
                } else if (d.isCorrect) {
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusLabel = 'Đúng';
                } else {
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusLabel = 'Sai';
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Câu ${d.questionNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.questionContent.isNotEmpty) ...[
                              Text(
                                d.questionContent,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Row(
                              children: [
                                Text(
                                  'Đã chọn: ${isSkipped ? "--" : d.selectedOption}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSkipped ? Colors.grey : (d.isCorrect ? Colors.green : Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Đáp án đúng: ${d.correctOption}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Return Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text('Về danh sách đề thi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    Color color,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
