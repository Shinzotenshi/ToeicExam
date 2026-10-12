using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ToeicExam.Controllers;
using ToeicExam.Toeic.Dto;
using ToeicExam.Toeic.Services;

namespace ToeicExam.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [IgnoreAntiforgeryToken]
    [Abp.Web.Models.DontWrapResult]
    public class ToeicApiController : ToeicExamControllerBase
    {
        private readonly IToeicExamAppService _toeicExamAppService;

        public ToeicApiController(IToeicExamAppService toeicExamAppService)
        {
            _toeicExamAppService = toeicExamAppService;
        }

        [HttpGet("exams")]
        public async Task<ActionResult<List<ExamDto>>> GetExams()
        {
            var exams = await _toeicExamAppService.GetAllExamsAsync();
            return Ok(exams);
        }

        [HttpGet("exams/{id}")]
        public async Task<ActionResult<ExamDetailDto>> GetExamDetail(int id)
        {
            var exam = await _toeicExamAppService.GetExamDetailAsync(id, forCandidate: true);
            return Ok(exam);
        }

        [HttpGet("admin/exams/{id}")]
        public async Task<ActionResult<ExamDetailDto>> GetExamDetailForAdmin(int id)
        {
            var exam = await _toeicExamAppService.GetExamDetailAsync(id, forCandidate: false);
            return Ok(exam);
        }

        [HttpPost("submit")]
        public async Task<ActionResult<ExamResultDto>> SubmitExam([FromBody] SubmitExamInput input)
        {
            if (input == null || input.ExamId <= 0)
            {
                return BadRequest("Dữ liệu nộp bài không hợp lệ.");
            }

            var result = await _toeicExamAppService.SubmitExamAsync(input);
            return Ok(result);
        }

        [HttpGet("submission/{id}")]
        public async Task<ActionResult<ExamResultDto>> GetSubmissionResult(int id)
        {
            var result = await _toeicExamAppService.GetSubmissionResultAsync(id);
            return Ok(result);
        }

        [HttpPost("upload")]
        public async Task<ActionResult<ImportExamResultDto>> UploadWord(IFormFile file, [FromForm] string customTitle)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new ImportExamResultDto
                {
                    Success = false,
                    Message = "Vui lòng chọn file .docx hợp lệ.",
                    ValidationErrors = new List<string> { "Dung lượng file bằng 0." }
                });
            }

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            var title = !string.IsNullOrWhiteSpace(customTitle) ? customTitle : file.FileName;
            var result = await _toeicExamAppService.ImportExamFromWordAsync(title, ms.ToArray());
            return Ok(result);
        }

        public class UploadPathInput
        {
            public string FilePath { get; set; }
            public string CustomTitle { get; set; }
        }

        [HttpPost("upload-path")]
        public async Task<ActionResult<ImportExamResultDto>> UploadWordByPath([FromBody] UploadPathInput input)
        {
            if (string.IsNullOrWhiteSpace(input?.FilePath) || !System.IO.File.Exists(input.FilePath))
            {
                return BadRequest(new ImportExamResultDto
                {
                    Success = false,
                    Message = $"Không tìm thấy file tại đường dẫn: {input?.FilePath}",
                    ValidationErrors = new List<string> { "Đường dẫn file không hợp lệ hoặc file không tồn tại." }
                });
            }

            var bytes = await System.IO.File.ReadAllBytesAsync(input.FilePath);
            var title = !string.IsNullOrWhiteSpace(input.CustomTitle) ? input.CustomTitle : System.IO.Path.GetFileNameWithoutExtension(input.FilePath);
            var result = await _toeicExamAppService.ImportExamFromWordAsync(title, bytes);
            return Ok(result);
        }

        [HttpPost("update-question")]
        public async Task<ActionResult> UpdateQuestion([FromBody] UpdateQuestionInput input)
        {
            if (input == null || input.Id <= 0)
            {
                return BadRequest(new { success = false, message = "Dữ liệu câu hỏi không hợp lệ." });
            }

            await _toeicExamAppService.UpdateQuestionAsync(input);
            return Ok(new { success = true, message = "Cập nhật câu hỏi thành công!" });
        }

        [HttpPost("update-group")]
        public async Task<ActionResult> UpdateGroup([FromBody] UpdateQuestionGroupInput input)
        {
            if (input == null || input.Id <= 0)
            {
                return BadRequest(new { success = false, message = "Dữ liệu nhóm không hợp lệ." });
            }

            await _toeicExamAppService.UpdateQuestionGroupAsync(input);
            return Ok(new { success = true, message = "Cập nhật nhóm câu hỏi thành công!" });
        }

        [HttpDelete("exams/{id}")]
        public async Task<ActionResult> DeleteExam(int id)
        {
            await _toeicExamAppService.DeleteExamAsync(id);
            return Ok(new { success = true, message = $"Đã xóa đề thi mã {id} thành công!" });
        }

        [HttpGet("submissions/{examId}")]
        public async Task<ActionResult<List<ExamSubmissionDto>>> GetSubmissions(int examId)
        {
            var subs = await _toeicExamAppService.GetSubmissionsByExamIdAsync(examId);
            return Ok(subs);
        }
    }
}
