using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Domain.Repositories;
using Abp.UI;
using Microsoft.EntityFrameworkCore;
using ToeicExam.Toeic.Dto;

namespace ToeicExam.Toeic.Services
{
    public class ToeicExamAppService : ApplicationService, IToeicExamAppService
    {
        private readonly IRepository<Exam, int> _examRepository;
        private readonly IRepository<QuestionGroup, int> _groupRepository;
        private readonly IRepository<Question, int> _questionRepository;
        private readonly IRepository<QuestionOption, int> _optionRepository;
        private readonly IRepository<ExamSubmission, int> _submissionRepository;
        private readonly IRepository<SubmissionAnswer, int> _submissionAnswerRepository;

        public ToeicExamAppService(
            IRepository<Exam, int> examRepository,
            IRepository<QuestionGroup, int> groupRepository,
            IRepository<Question, int> questionRepository,
            IRepository<QuestionOption, int> optionRepository,
            IRepository<ExamSubmission, int> submissionRepository,
            IRepository<SubmissionAnswer, int> submissionAnswerRepository)
        {
            _examRepository = examRepository;
            _groupRepository = groupRepository;
            _questionRepository = questionRepository;
            _optionRepository = optionRepository;
            _submissionRepository = submissionRepository;
            _submissionAnswerRepository = submissionAnswerRepository;
        }

        public async Task<List<ExamDto>> GetAllExamsAsync()
        {
            var exams = await _examRepository.GetAll()
                .OrderByDescending(e => e.CreationTime)
                .ToListAsync();

            return exams.Select(e => new ExamDto
            {
                Id = e.Id,
                Title = e.Title,
                Description = e.Description,
                DurationMinutes = e.DurationMinutes,
                TotalQuestions = e.TotalQuestions,
                IsActive = e.IsActive,
                CreationTime = e.CreationTime
            }).ToList();
        }

        public async Task<ExamDetailDto> GetExamDetailAsync(int examId, bool forCandidate = false)
        {
            var exam = await _examRepository.FirstOrDefaultAsync(examId);
            if (exam == null)
            {
                throw new UserFriendlyException($"Không tìm thấy đề thi mã {examId}");
            }

            var groups = await _groupRepository.GetAll()
                .Where(g => g.ExamId == examId)
                .OrderBy(g => g.GroupOrder)
                .ToListAsync();

            var groupIds = groups.Select(g => g.Id).ToList();

            var questions = await _questionRepository.GetAll()
                .Where(q => groupIds.Contains(q.GroupId))
                .OrderBy(q => q.QuestionNumber)
                .ToListAsync();

            var questionIds = questions.Select(q => q.Id).ToList();

            var options = await _optionRepository.GetAll()
                .Where(o => questionIds.Contains(o.QuestionId))
                .OrderBy(o => o.OptionKey)
                .ToListAsync();

            var optionsLookup = options.ToLookup(o => o.QuestionId);
            var questionsLookup = questions.ToLookup(q => q.GroupId);

            var result = new ExamDetailDto
            {
                Id = exam.Id,
                Title = exam.Title,
                Description = exam.Description,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions,
                IsActive = exam.IsActive,
                CreationTime = exam.CreationTime,
                QuestionGroups = groups.Select(g => new QuestionGroupDto
                {
                    Id = g.Id,
                    ExamId = g.ExamId,
                    PartNumber = g.PartNumber,
                    GroupOrder = g.GroupOrder,
                    Title = g.Title,
                    PassageText = g.PassageText,
                    PassageImageUrl = g.PassageImageUrl,
                    Questions = questionsLookup[g.Id].Select(q => new QuestionDto
                    {
                        Id = q.Id,
                        GroupId = q.GroupId,
                        QuestionNumber = q.QuestionNumber,
                        Content = q.Content,
                        CorrectOption = forCandidate ? null : q.CorrectOption,
                        Explanation = forCandidate ? null : q.Explanation,
                        Options = optionsLookup[q.Id].Select(o => new QuestionOptionDto
                        {
                            Id = o.Id,
                            QuestionId = o.QuestionId,
                            OptionKey = o.OptionKey,
                            Content = o.Content
                        }).ToList()
                    }).ToList()
                }).ToList()
            };

            return result;
        }

        public async Task<ImportExamResultDto> ImportExamFromWordAsync(string fileName, byte[] fileBytes)
        {
            if (fileBytes == null || fileBytes.Length == 0)
            {
                return new ImportExamResultDto
                {
                    Success = false,
                    Message = "File rỗng hoặc không hợp lệ.",
                    ValidationErrors = new List<string> { "Dung lượng file bằng 0." }
                };
            }

            var title = Path.GetFileNameWithoutExtension(fileName);
            ParsedExamResult parsed;

            using (var ms = new MemoryStream(fileBytes))
            {
                parsed = WordExamParser.ParseDocx(ms, title);
            }

            if (!parsed.IsValid || parsed.ValidationErrors.Any())
            {
                return new ImportExamResultDto
                {
                    Success = false,
                    Message = "Hủy bỏ toàn bộ do phát hiện lỗi định dạng trong file Word!",
                    ValidationErrors = parsed.ValidationErrors,
                    TotalQuestionsParsed = parsed.TotalQuestions
                };
            }

            // Save to database
            var exam = new Exam
            {
                Title = parsed.ExamTitle,
                Description = parsed.Description,
                DurationMinutes = parsed.DurationMinutes,
                TotalQuestions = parsed.TotalQuestions,
                IsActive = true
            };

            var examId = await _examRepository.InsertAndGetIdAsync(exam);
            await CurrentUnitOfWork.SaveChangesAsync();

            foreach (var g in parsed.Groups)
            {
                var group = new QuestionGroup
                {
                    ExamId = examId,
                    PartNumber = g.PartNumber,
                    GroupOrder = g.GroupOrder,
                    Title = g.Title,
                    PassageText = g.PassageText,
                    PassageImageUrl = g.PassageImageUrl
                };

                var groupId = await _groupRepository.InsertAndGetIdAsync(group);
                await CurrentUnitOfWork.SaveChangesAsync();

                foreach (var q in g.Questions)
                {
                    var question = new Question
                    {
                        GroupId = groupId,
                        QuestionNumber = q.QuestionNumber,
                        Content = q.Content,
                        CorrectOption = q.CorrectOption,
                        Explanation = q.Explanation
                    };

                    var questionId = await _questionRepository.InsertAndGetIdAsync(question);
                    await CurrentUnitOfWork.SaveChangesAsync();

                    foreach (var opt in q.Options)
                    {
                        var option = new QuestionOption
                        {
                            QuestionId = questionId,
                            OptionKey = opt.OptionKey,
                            Content = opt.Content
                        };
                        await _optionRepository.InsertAsync(option);
                    }
                }
            }

            await CurrentUnitOfWork.SaveChangesAsync();

            return new ImportExamResultDto
            {
                Success = true,
                ExamId = examId,
                Message = $"Tạo đề thi '{exam.Title}' thành công với {parsed.TotalQuestions} câu hỏi chuẩn 100%!",
                TotalQuestionsParsed = parsed.TotalQuestions
            };
        }

        public async Task<ExamResultDto> SubmitExamAsync(SubmitExamInput input)
        {
            var exam = await _examRepository.FirstOrDefaultAsync(input.ExamId);
            if (exam == null)
            {
                throw new UserFriendlyException($"Đề thi không tồn tại (ID: {input.ExamId})");
            }

            var groups = await _groupRepository.GetAll()
                .Where(g => g.ExamId == input.ExamId)
                .ToListAsync();
            var groupPartDict = groups.ToDictionary(g => g.Id, g => g.PartNumber);

            var questions = await _questionRepository.GetAll()
                .Where(q => groups.Select(g => g.Id).Contains(q.GroupId))
                .OrderBy(q => q.QuestionNumber)
                .ToListAsync();

            var answerDict = input.Answers.ToDictionary(a => a.QuestionId, a => a.SelectedOption?.Trim().ToUpper());

            int correctCount = 0;
            int wrongCount = 0;
            int skippedCount = 0;

            var details = new List<SubmissionAnswerResultDto>();

            var submission = new ExamSubmission
            {
                ExamId = input.ExamId,
                CandidateName = string.IsNullOrWhiteSpace(input.CandidateName) ? "Thí sinh" : input.CandidateName.Trim(),
                TimeSpentSeconds = input.TimeSpentSeconds,
                SubmittedAt = DateTime.Now
            };

            var submissionId = await _submissionRepository.InsertAndGetIdAsync(submission);
            await CurrentUnitOfWork.SaveChangesAsync();

            foreach (var q in questions)
            {
                answerDict.TryGetValue(q.Id, out var selected);
                bool isSkipped = string.IsNullOrWhiteSpace(selected);
                bool isCorrect = !isSkipped && string.Equals(selected, q.CorrectOption, StringComparison.OrdinalIgnoreCase);

                if (isSkipped)
                {
                    skippedCount++;
                }
                else if (isCorrect)
                {
                    correctCount++;
                }
                else
                {
                    wrongCount++;
                }

                var subAns = new SubmissionAnswer
                {
                    ExamSubmissionId = submissionId,
                    QuestionId = q.Id,
                    QuestionNumber = q.QuestionNumber,
                    SelectedOption = selected,
                    IsCorrect = isCorrect
                };
                await _submissionAnswerRepository.InsertAsync(subAns);

                groupPartDict.TryGetValue(q.GroupId, out var partNum);
                details.Add(new SubmissionAnswerResultDto
                {
                    QuestionNumber = q.QuestionNumber,
                    QuestionContent = q.Content,
                    SelectedOption = selected,
                    CorrectOption = q.CorrectOption,
                    IsCorrect = isCorrect,
                    PartNumber = partNum
                });
            }

            // TOEIC Reading 100 questions = max 495 points
            int total = questions.Count > 0 ? questions.Count : 100;
            int score = (int)Math.Round(((double)correctCount / total) * 495.0);

            submission.CorrectCount = correctCount;
            submission.WrongCount = wrongCount;
            submission.SkippedCount = skippedCount;
            submission.Score = score;
            await _submissionRepository.UpdateAsync(submission);
            await CurrentUnitOfWork.SaveChangesAsync();

            return new ExamResultDto
            {
                SubmissionId = submissionId,
                ExamId = exam.Id,
                ExamTitle = exam.Title,
                CandidateName = submission.CandidateName,
                TotalQuestions = total,
                CorrectCount = correctCount,
                WrongCount = wrongCount,
                SkippedCount = skippedCount,
                Score = score,
                TimeSpentSeconds = input.TimeSpentSeconds,
                SubmittedAt = submission.SubmittedAt,
                Details = details
            };
        }

        public async Task<ExamResultDto> GetSubmissionResultAsync(int submissionId)
        {
            var submission = await _submissionRepository.FirstOrDefaultAsync(submissionId);
            if (submission == null)
            {
                throw new UserFriendlyException($"Không tìm thấy bài thi nộp mã {submissionId}");
            }

            var exam = await _examRepository.FirstOrDefaultAsync(submission.ExamId);
            var subAnswers = await _submissionAnswerRepository.GetAll()
                .Where(a => a.ExamSubmissionId == submissionId)
                .OrderBy(a => a.QuestionNumber)
                .ToListAsync();

            var qIds = subAnswers.Select(a => a.QuestionId).ToList();
            var questions = await _questionRepository.GetAll()
                .Where(q => qIds.Contains(q.Id))
                .ToDictionaryAsync(q => q.Id);

            var groups = await _groupRepository.GetAll()
                .Where(g => g.ExamId == submission.ExamId)
                .ToDictionaryAsync(g => g.Id);

            var details = subAnswers.Select(a =>
            {
                questions.TryGetValue(a.QuestionId, out var q);
                int partNum = 5;
                if (q != null && groups.TryGetValue(q.GroupId, out var g))
                {
                    partNum = g.PartNumber;
                }

                return new SubmissionAnswerResultDto
                {
                    QuestionNumber = a.QuestionNumber,
                    QuestionContent = q?.Content ?? "",
                    SelectedOption = a.SelectedOption,
                    CorrectOption = q?.CorrectOption ?? "",
                    IsCorrect = a.IsCorrect,
                    PartNumber = partNum
                };
            }).ToList();

            return new ExamResultDto
            {
                SubmissionId = submission.Id,
                ExamId = submission.ExamId,
                ExamTitle = exam?.Title ?? "Đề thi TOEIC Reading",
                CandidateName = submission.CandidateName,
                TotalQuestions = details.Count,
                CorrectCount = submission.CorrectCount,
                WrongCount = submission.WrongCount,
                SkippedCount = submission.SkippedCount,
                Score = submission.Score,
                TimeSpentSeconds = submission.TimeSpentSeconds,
                SubmittedAt = submission.SubmittedAt,
                Details = details
            };
        }

        public async Task<List<ExamSubmissionDto>> GetSubmissionsByExamIdAsync(int examId)
        {
            var subs = await _submissionRepository.GetAll()
                .Where(s => s.ExamId == examId)
                .OrderByDescending(s => s.SubmittedAt)
                .ToListAsync();

            return subs.Select(s => new ExamSubmissionDto
            {
                Id = s.Id,
                ExamId = s.ExamId,
                CandidateName = s.CandidateName,
                CorrectCount = s.CorrectCount,
                WrongCount = s.WrongCount,
                SkippedCount = s.SkippedCount,
                Score = s.Score,
                TimeSpentSeconds = s.TimeSpentSeconds,
                SubmittedAt = s.SubmittedAt
            }).ToList();
        }

        public async Task<ExamDto> CreateOrUpdateExamAsync(CreateOrUpdateExamDto input)
        {
            if (input.Id.HasValue && input.Id.Value > 0)
            {
                var exam = await _examRepository.GetAsync(input.Id.Value);
                exam.Title = input.Title;
                exam.Description = input.Description;
                exam.DurationMinutes = input.DurationMinutes;
                exam.TotalQuestions = input.TotalQuestions;
                exam.IsActive = input.IsActive;
                await _examRepository.UpdateAsync(exam);
                return new ExamDto
                {
                    Id = exam.Id,
                    Title = exam.Title,
                    Description = exam.Description,
                    DurationMinutes = exam.DurationMinutes,
                    TotalQuestions = exam.TotalQuestions,
                    IsActive = exam.IsActive,
                    CreationTime = exam.CreationTime
                };
            }
            else
            {
                var exam = new Exam
                {
                    Title = input.Title,
                    Description = input.Description,
                    DurationMinutes = input.DurationMinutes,
                    TotalQuestions = input.TotalQuestions,
                    IsActive = input.IsActive
                };
                var id = await _examRepository.InsertAndGetIdAsync(exam);
                return new ExamDto
                {
                    Id = id,
                    Title = exam.Title,
                    Description = exam.Description,
                    DurationMinutes = exam.DurationMinutes,
                    TotalQuestions = exam.TotalQuestions,
                    IsActive = exam.IsActive,
                    CreationTime = DateTime.Now
                };
            }
        }

        public async Task UpdateQuestionAsync(UpdateQuestionInput input)
        {
            var question = await _questionRepository.GetAsync(input.Id);
            question.Content = input.Content;
            question.CorrectOption = input.CorrectOption?.ToUpper();
            question.Explanation = input.Explanation;
            await _questionRepository.UpdateAsync(question);

            if (input.Options != null)
            {
                foreach (var optInput in input.Options)
                {
                    var opt = await _optionRepository.FirstOrDefaultAsync(optInput.Id);
                    if (opt != null)
                    {
                        opt.Content = optInput.Content;
                        opt.OptionKey = optInput.OptionKey?.ToUpper();
                        await _optionRepository.UpdateAsync(opt);
                    }
                }
            }
        }

        public async Task UpdateQuestionGroupAsync(UpdateQuestionGroupInput input)
        {
            var group = await _groupRepository.GetAsync(input.Id);
            group.Title = input.Title;
            group.PassageText = input.PassageText;
            group.PassageImageUrl = input.PassageImageUrl;
            await _groupRepository.UpdateAsync(group);
        }

        public async Task DeleteExamAsync(int id)
        {
            await _examRepository.DeleteAsync(id);
        }
    }
}
