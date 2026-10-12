using System;
using System.Collections.Generic;
using Abp.Application.Services.Dto;
using Abp.AutoMapper;
using ToeicExam.Toeic;

namespace ToeicExam.Toeic.Dto
{
    [AutoMapFrom(typeof(Exam))]
    public class ExamDto : EntityDto<int>
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreationTime { get; set; }
    }

    public class ExamSubmissionDto : EntityDto<int>
    {
        public int ExamId { get; set; }
        public string CandidateName { get; set; }
        public int CorrectCount { get; set; }
        public int WrongCount { get; set; }
        public int SkippedCount { get; set; }
        public int Score { get; set; }
        public int TimeSpentSeconds { get; set; }
        public DateTime SubmittedAt { get; set; }
    }

    public class CreateOrUpdateExamDto
    {
        public int? Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; } = 75;
        public int TotalQuestions { get; set; } = 100;
        public bool IsActive { get; set; } = true;
    }

    [AutoMapFrom(typeof(QuestionOption))]
    public class QuestionOptionDto : EntityDto<int>
    {
        public int QuestionId { get; set; }
        public string OptionKey { get; set; }
        public string Content { get; set; }
    }

    [AutoMapFrom(typeof(Question))]
    public class QuestionDto : EntityDto<int>
    {
        public int GroupId { get; set; }
        public int QuestionNumber { get; set; }
        public string Content { get; set; }
        public string CorrectOption { get; set; }
        public string Explanation { get; set; }
        public List<QuestionOptionDto> Options { get; set; } = new List<QuestionOptionDto>();
    }

    [AutoMapFrom(typeof(QuestionGroup))]
    public class QuestionGroupDto : EntityDto<int>
    {
        public int ExamId { get; set; }
        public int PartNumber { get; set; }
        public int GroupOrder { get; set; }
        public string Title { get; set; }
        public string PassageText { get; set; }
        public string PassageImageUrl { get; set; }
        public List<QuestionDto> Questions { get; set; } = new List<QuestionDto>();
    }

    public class ExamDetailDto : ExamDto
    {
        public List<QuestionGroupDto> QuestionGroups { get; set; } = new List<QuestionGroupDto>();
    }

    public class SubmitExamAnswerInput
    {
        public int QuestionId { get; set; }
        public int QuestionNumber { get; set; }
        public string SelectedOption { get; set; }
    }

    public class SubmitExamInput
    {
        public int ExamId { get; set; }
        public string CandidateName { get; set; }
        public int TimeSpentSeconds { get; set; }
        public List<SubmitExamAnswerInput> Answers { get; set; } = new List<SubmitExamAnswerInput>();
    }

    public class SubmissionAnswerResultDto
    {
        public int QuestionNumber { get; set; }
        public string QuestionContent { get; set; }
        public string SelectedOption { get; set; }
        public string CorrectOption { get; set; }
        public bool IsCorrect { get; set; }
        public int PartNumber { get; set; }
    }

    public class ExamResultDto
    {
        public int SubmissionId { get; set; }
        public int ExamId { get; set; }
        public string ExamTitle { get; set; }
        public string CandidateName { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectCount { get; set; }
        public int WrongCount { get; set; }
        public int SkippedCount { get; set; }
        public int Score { get; set; }
        public int TimeSpentSeconds { get; set; }
        public DateTime SubmittedAt { get; set; }
        public List<SubmissionAnswerResultDto> Details { get; set; } = new List<SubmissionAnswerResultDto>();
    }

    public class ImportExamResultDto
    {
        public bool Success { get; set; }
        public int ExamId { get; set; }
        public string Message { get; set; }
        public int TotalQuestionsParsed { get; set; }
        public List<string> ValidationErrors { get; set; } = new List<string>();
    }

    public class UpdateQuestionInput
    {
        public int Id { get; set; }
        public string Content { get; set; }
        public string CorrectOption { get; set; }
        public string Explanation { get; set; }
        public List<UpdateOptionInput> Options { get; set; } = new List<UpdateOptionInput>();
    }

    public class UpdateOptionInput
    {
        public int Id { get; set; }
        public string OptionKey { get; set; }
        public string Content { get; set; }
    }

    public class UpdateQuestionGroupInput
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string PassageText { get; set; }
        public string PassageImageUrl { get; set; }
    }
}
