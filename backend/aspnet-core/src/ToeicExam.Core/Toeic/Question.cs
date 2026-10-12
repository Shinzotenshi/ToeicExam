using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities;

namespace ToeicExam.Toeic
{
    [Table("AppQuestions")]
    public class Question : Entity<int>
    {
        public int GroupId { get; set; }

        [ForeignKey("GroupId")]
        public virtual QuestionGroup Group { get; set; }

        /// <summary>
        /// 101 to 200
        /// </summary>
        public int QuestionNumber { get; set; }

        public string Content { get; set; }

        [StringLength(10)]
        public string CorrectOption { get; set; }

        public string Explanation { get; set; }

        public virtual ICollection<QuestionOption> Options { get; set; } = new List<QuestionOption>();
    }
}
