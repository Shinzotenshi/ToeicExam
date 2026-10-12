using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace ToeicExam.Toeic
{
    [Table("AppSubmissionAnswers")]
    public class SubmissionAnswer : Entity<int>
    {
        public int ExamSubmissionId { get; set; }

        [ForeignKey("ExamSubmissionId")]
        public virtual ExamSubmission ExamSubmission { get; set; }

        public int QuestionId { get; set; }

        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; }

        public int QuestionNumber { get; set; }

        [StringLength(10)]
        public string SelectedOption { get; set; }

        public bool IsCorrect { get; set; }
    }
}
