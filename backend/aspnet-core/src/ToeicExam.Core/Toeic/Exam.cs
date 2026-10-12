using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace ToeicExam.Toeic
{
    [Table("AppExams")]
    public class Exam : FullAuditedEntity<int>
    {
        [Required]
        [StringLength(500)]
        public string Title { get; set; }

        public string Description { get; set; }

        public int DurationMinutes { get; set; } = 75;

        public int TotalQuestions { get; set; } = 100;

        public bool IsActive { get; set; } = true;

        public virtual ICollection<QuestionGroup> QuestionGroups { get; set; } = new List<QuestionGroup>();

        public virtual ICollection<ExamSubmission> Submissions { get; set; } = new List<ExamSubmission>();
    }
}
