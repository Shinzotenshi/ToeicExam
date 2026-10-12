using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using ToeicExam.Controllers;
using ToeicExam.Toeic.Dto;
using ToeicExam.Toeic.Services;

namespace ToeicExam.Web.Controllers
{
    public class ExamsController : ToeicExamControllerBase
    {
        private readonly IToeicExamAppService _toeicExamAppService;

        public ExamsController(IToeicExamAppService toeicExamAppService)
        {
            _toeicExamAppService = toeicExamAppService;
        }

        public async Task<IActionResult> Index()
        {
            var exams = await _toeicExamAppService.GetAllExamsAsync();
            return View(exams);
        }

        [HttpPost]
        public async Task<IActionResult> UploadWord(IFormFile wordFile, string customTitle)
        {
            if (wordFile == null || wordFile.Length == 0)
            {
                TempData["ErrorMessage"] = "Vui lòng chọn file Word (.docx) hợp lệ.";
                return RedirectToAction(nameof(Index));
            }

            var extension = Path.GetExtension(wordFile.FileName).ToLower();
            if (extension != ".docx")
            {
                TempData["ErrorMessage"] = "Chỉ chấp nhận định dạng file Word .docx!";
                return RedirectToAction(nameof(Index));
            }

            byte[] fileBytes;
            using (var memoryStream = new MemoryStream())
            {
                await wordFile.CopyToAsync(memoryStream);
                fileBytes = memoryStream.ToArray();
            }

            var fileName = !string.IsNullOrWhiteSpace(customTitle) ? customTitle : wordFile.FileName;
            var result = await _toeicExamAppService.ImportExamFromWordAsync(fileName, fileBytes);

            if (!result.Success)
            {
                TempData["ErrorMessage"] = result.Message;
                TempData["ValidationErrors"] = JsonConvert.SerializeObject(result.ValidationErrors);
                return RedirectToAction(nameof(Index));
            }

            TempData["SuccessMessage"] = result.Message;
            return RedirectToAction(nameof(Details), new { id = result.ExamId });
        }

        public async Task<IActionResult> Details(int id)
        {
            var exam = await _toeicExamAppService.GetExamDetailAsync(id, forCandidate: false);
            return View(exam);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var exam = await _toeicExamAppService.GetExamDetailAsync(id, forCandidate: false);
            return View(exam);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateQuestion([FromBody] UpdateQuestionInput input)
        {
            if (input == null || input.Id <= 0)
            {
                return Json(new { success = false, message = "Dữ liệu không hợp lệ." });
            }

            await _toeicExamAppService.UpdateQuestionAsync(input);
            return Json(new { success = true, message = "Cập nhật câu hỏi thành công!" });
        }

        [HttpPost]
        public async Task<IActionResult> UpdateGroup([FromBody] UpdateQuestionGroupInput input)
        {
            if (input == null || input.Id <= 0)
            {
                return Json(new { success = false, message = "Dữ liệu không hợp lệ." });
            }

            await _toeicExamAppService.UpdateQuestionGroupAsync(input);
            return Json(new { success = true, message = "Cập nhật nhóm câu hỏi thành công!" });
        }

        public async Task<IActionResult> Submissions(int id)
        {
            var exam = await _toeicExamAppService.GetExamDetailAsync(id, forCandidate: false);
            var submissions = await _toeicExamAppService.GetSubmissionsByExamIdAsync(id);
            ViewBag.Exam = exam;
            return View(submissions);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            await _toeicExamAppService.DeleteExamAsync(id);
            TempData["SuccessMessage"] = $"Đã xóa đề thi mã {id} thành công.";
            return RedirectToAction(nameof(Index));
        }
    }
}
