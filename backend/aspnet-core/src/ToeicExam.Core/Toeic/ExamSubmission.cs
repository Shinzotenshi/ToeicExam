using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace ToeicExam.Toeic
{
    [Table("AppExamSubmissions")]
    public class ExamSubmission : FullAuditedEntity<int>
    {
        public int ExamId { get; set; }

        [ForeignKey("ExamId")]
        public virtual Exam Exam { get; set; }

        public long? UserId { get; set; }

        [StringLength(256)]
        public string CandidateName { get; set; }

        public int CorrectCount { get; set; }

        public int WrongCount { get; set; }

        public int SkippedCount { get; set; }

        public int Score { get; set; }

        public int TimeSpentSeconds { get; set; }

        public DateTime SubmittedAt { get; set; } = DateTime.Now;

        public virtual ICollection<SubmissionAnswer> Answers { get; set; } = new List<SubmissionAnswer>();
    }
}
