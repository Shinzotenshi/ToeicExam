using Abp.Zero.EntityFrameworkCore;
using ToeicExam.Authorization.Roles;
using ToeicExam.Authorization.Users;
using ToeicExam.MultiTenancy;
using ToeicExam.Toeic;
using Microsoft.EntityFrameworkCore;

namespace ToeicExam.EntityFrameworkCore;

public class ToeicExamDbContext : AbpZeroDbContext<Tenant, Role, User, ToeicExamDbContext>
{
    /* Define a DbSet for each entity of the application */
    public virtual DbSet<Exam> Exams { get; set; }
    public virtual DbSet<QuestionGroup> QuestionGroups { get; set; }
    public virtual DbSet<Question> Questions { get; set; }
    public virtual DbSet<QuestionOption> QuestionOptions { get; set; }
    public virtual DbSet<ExamSubmission> ExamSubmissions { get; set; }
    public virtual DbSet<SubmissionAnswer> SubmissionAnswers { get; set; }

    public ToeicExamDbContext(DbContextOptions<ToeicExamDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Exam>().ToTable("AppExams");
        modelBuilder.Entity<QuestionGroup>().ToTable("AppQuestionGroups");
        modelBuilder.Entity<Question>().ToTable("AppQuestions");
        modelBuilder.Entity<QuestionOption>().ToTable("AppQuestionOptions");
        modelBuilder.Entity<ExamSubmission>().ToTable("AppExamSubmissions");
        modelBuilder.Entity<SubmissionAnswer>().ToTable("AppSubmissionAnswers");
    }
}
