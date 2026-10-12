using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Application.Services;
using ToeicExam.Toeic.Dto;

namespace ToeicExam.Toeic.Services
{
    public interface IToeicExamAppService : IApplicationService
    {
        Task<List<ExamDto>> GetAllExamsAsync();
        Task<ExamDetailDto> GetExamDetailAsync(int examId, bool forCandidate = false);
        Task<ImportExamResultDto> ImportExamFromWordAsync(string fileName, byte[] fileBytes);
        Task<ExamResultDto> SubmitExamAsync(SubmitExamInput input);
        Task<ExamResultDto> GetSubmissionResultAsync(int submissionId);
        Task<List<ExamSubmissionDto>> GetSubmissionsByExamIdAsync(int examId);
        Task<ExamDto> CreateOrUpdateExamAsync(CreateOrUpdateExamDto input);
        Task UpdateQuestionAsync(UpdateQuestionInput input);
        Task UpdateQuestionGroupAsync(UpdateQuestionGroupInput input);
        Task DeleteExamAsync(int id);
    }
}
