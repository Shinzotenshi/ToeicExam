class ExamSummary {
  final int id;
  final String title;
  final String description;
  final int durationMinutes;
  final int totalQuestions;
  final bool isActive;

  ExamSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.isActive,
  });

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    return ExamSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 100,
      isActive: json['isActive'] ?? true,
    );
  }
}

class QuestionOptionModel {
  final int id;
  final int questionId;
  final String optionKey;
  final String content;

  QuestionOptionModel({
    required this.id,
    required this.questionId,
    required this.optionKey,
    required this.content,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] ?? 0,
      questionId: json['questionId'] ?? 0,
      optionKey: json['optionKey'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class QuestionModel {
  final int id;
  final int groupId;
  final int questionNumber;
  final String content;
  final String? correctOption;
  final String? explanation;
  final List<QuestionOptionModel> options;

  QuestionModel({
    required this.id,
    required this.groupId,
    required this.questionNumber,
    required this.content,
    this.correctOption,
    this.explanation,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List? ?? [];
    return QuestionModel(
      id: json['id'] ?? 0,
      groupId: json['groupId'] ?? 0,
      questionNumber: json['questionNumber'] ?? 0,
      content: json['content'] ?? '',
      correctOption: json['correctOption'],
      explanation: json['explanation'],
      options: rawOptions.map((o) => QuestionOptionModel.fromJson(o)).toList(),
    );
  }
}

class QuestionGroupModel {
  final int id;
  final int examId;
  final int partNumber;
  final int groupOrder;
  final String title;
  final String? passageText;
  final String? passageImageUrl;
  final List<QuestionModel> questions;

  QuestionGroupModel({
    required this.id,
    required this.examId,
    required this.partNumber,
    required this.groupOrder,
    required this.title,
    this.passageText,
    this.passageImageUrl,
    required this.questions,
  });

  factory QuestionGroupModel.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    return QuestionGroupModel(
      id: json['id'] ?? 0,
      examId: json['examId'] ?? 0,
      partNumber: json['partNumber'] ?? 5,
      groupOrder: json['groupOrder'] ?? 0,
      title: json['title'] ?? '',
      passageText: json['passageText'],
      passageImageUrl: json['passageImageUrl'],
      questions: rawQuestions.map((q) => QuestionModel.fromJson(q)).toList(),
    );
  }
}

class ExamDetailModel {
  final int id;
  final String title;
  final String description;
  final int durationMinutes;
  final int totalQuestions;
  final List<QuestionGroupModel> questionGroups;

  ExamDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.questionGroups,
  });

  factory ExamDetailModel.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['questionGroups'] as List? ?? [];
    return ExamDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 75,
      totalQuestions: json['totalQuestions'] ?? 100,
      questionGroups: rawGroups.map((g) => QuestionGroupModel.fromJson(g)).toList(),
    );
  }

  List<QuestionModel> getAllQuestions() {
    final list = <QuestionModel>[];
    for (var g in questionGroups) {
      list.addAll(g.questions);
    }
    list.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return list;
  }
}

class SubmitAnswerItem {
  final int questionId;
  final int questionNumber;
  final String? selectedOption;

  SubmitAnswerItem({
    required this.questionId,
    required this.questionNumber,
    this.selectedOption,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'questionNumber': questionNumber,
    'selectedOption': selectedOption,
  };
}

class SubmissionAnswerDetail {
  final int questionNumber;
  final String questionContent;
  final String? selectedOption;
  final String correctOption;
  final bool isCorrect;
  final int partNumber;

  SubmissionAnswerDetail({
    required this.questionNumber,
    required this.questionContent,
    this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    required this.partNumber,
  });

  factory SubmissionAnswerDetail.fromJson(Map<String, dynamic> json) {
    return SubmissionAnswerDetail(
      questionNumber: json['questionNumber'] ?? 0,
      questionContent: json['questionContent'] ?? '',
      selectedOption: json['selectedOption'],
      correctOption: json['correctOption'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      partNumber: json['partNumber'] ?? 5,
    );
  }
}

class ExamResultModel {
  final int submissionId;
  final int examId;
  final String examTitle;
  final String candidateName;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int score;
  final int timeSpentSeconds;
  final DateTime submittedAt;
  final List<SubmissionAnswerDetail> details;

  ExamResultModel({
    required this.submissionId,
    required this.examId,
    required this.examTitle,
    required this.candidateName,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.score,
    required this.timeSpentSeconds,
    required this.submittedAt,
    required this.details,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    var rawDetails = json['details'] as List? ?? [];
    return ExamResultModel(
      submissionId: json['submissionId'] ?? 0,
      examId: json['examId'] ?? 0,
      examTitle: json['examTitle'] ?? '',
      candidateName: json['candidateName'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      skippedCount: json['skippedCount'] ?? 0,
      score: json['score'] ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      details: rawDetails.map((d) => SubmissionAnswerDetail.fromJson(d)).toList(),
    );
  }
}

class ExamSubmissionSummary {
  final int id;
  final int examId;
  final String candidateName;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int score;
  final int timeSpentSeconds;
  final DateTime submittedAt;

  ExamSubmissionSummary({
    required this.id,
    required this.examId,
    required this.candidateName,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.score,
    required this.timeSpentSeconds,
    required this.submittedAt,
  });

  factory ExamSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return ExamSubmissionSummary(
      id: json['id'] ?? 0,
      examId: json['examId'] ?? 0,
      candidateName: json['candidateName'] ?? 'Thí sinh',
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      skippedCount: json['skippedCount'] ?? 0,
      score: json['score'] ?? 0,
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      submittedAt: DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ImportExamResultModel {
  final bool success;
  final int examId;
  final String message;
  final int totalQuestionsParsed;
  final List<String> validationErrors;

  ImportExamResultModel({
    required this.success,
    required this.examId,
    required this.message,
    required this.totalQuestionsParsed,
    required this.validationErrors,
  });

  factory ImportExamResultModel.fromJson(Map<String, dynamic> json) {
    var rawErrors = json['validationErrors'] as List? ?? [];
    return ImportExamResultModel(
      success: json['success'] ?? false,
      examId: json['examId'] ?? 0,
      message: json['message'] ?? '',
      totalQuestionsParsed: json['totalQuestionsParsed'] ?? 0,
      validationErrors: rawErrors.map((e) => e.toString()).toList(),
    );
  }
}

