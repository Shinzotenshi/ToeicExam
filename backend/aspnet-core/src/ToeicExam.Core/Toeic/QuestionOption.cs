using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace ToeicExam.Toeic
{
    [Table("AppQuestionOptions")]
    public class QuestionOption : Entity<int>
    {
        public int QuestionId { get; set; }

        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; }

        /// <summary>
        /// A, B, C, D
        /// </summary>
        [Required]
        [StringLength(10)]
        public string OptionKey { get; set; }

        [Required]
        public string Content { get; set; }
    }
}
