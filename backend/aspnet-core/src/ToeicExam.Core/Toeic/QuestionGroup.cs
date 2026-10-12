using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace ToeicExam.Toeic
{
    [Table("AppQuestionGroups")]
    public class QuestionGroup : Entity<int>
    {
        public int ExamId { get; set; }

        [ForeignKey("ExamId")]
        public virtual Exam Exam { get; set; }

        /// <summary>
        /// Part 5, 6, 7
        /// </summary>
        public int PartNumber { get; set; }

        public int GroupOrder { get; set; }

        [StringLength(500)]
        public string Title { get; set; }

        public string PassageText { get; set; }

        [StringLength(1000)]
        public string PassageImageUrl { get; set; }

        public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
    }
}
