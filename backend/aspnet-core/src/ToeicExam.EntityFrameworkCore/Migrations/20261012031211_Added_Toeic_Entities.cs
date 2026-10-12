using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ToeicExam.Migrations
{
    /// <inheritdoc />
    public partial class Added_Toeic_Entities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AppExams",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    TotalQuestions = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppExams", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AppExamSubmissions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExamId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<long>(type: "bigint", nullable: true),
                    CandidateName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    CorrectCount = table.Column<int>(type: "int", nullable: false),
                    WrongCount = table.Column<int>(type: "int", nullable: false),
                    SkippedCount = table.Column<int>(type: "int", nullable: false),
                    Score = table.Column<int>(type: "int", nullable: false),
                    TimeSpentSeconds = table.Column<int>(type: "int", nullable: false),
                    SubmittedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppExamSubmissions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppExamSubmissions_AppExams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "AppExams",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AppQuestionGroups",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExamId = table.Column<int>(type: "int", nullable: false),
                    PartNumber = table.Column<int>(type: "int", nullable: false),
                    GroupOrder = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    PassageText = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PassageImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppQuestionGroups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppQuestionGroups_AppExams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "AppExams",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AppQuestions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    GroupId = table.Column<int>(type: "int", nullable: false),
                    QuestionNumber = table.Column<int>(type: "int", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CorrectOption = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    Explanation = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppQuestions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppQuestions_AppQuestionGroups_GroupId",
                        column: x => x.GroupId,
                        principalTable: "AppQuestionGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AppQuestionOptions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    QuestionId = table.Column<int>(type: "int", nullable: false),
                    OptionKey = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppQuestionOptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppQuestionOptions_AppQuestions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "AppQuestions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AppSubmissionAnswers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExamSubmissionId = table.Column<int>(type: "int", nullable: false),
                    QuestionId = table.Column<int>(type: "int", nullable: false),
                    QuestionNumber = table.Column<int>(type: "int", nullable: false),
                    SelectedOption = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    IsCorrect = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppSubmissionAnswers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppSubmissionAnswers_AppExamSubmissions_ExamSubmissionId",
                        column: x => x.ExamSubmissionId,
                        principalTable: "AppExamSubmissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AppSubmissionAnswers_AppQuestions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "AppQuestions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppExamSubmissions_ExamId",
                table: "AppExamSubmissions",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_AppQuestionGroups_ExamId",
                table: "AppQuestionGroups",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_AppQuestionOptions_QuestionId",
                table: "AppQuestionOptions",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_AppQuestions_GroupId",
                table: "AppQuestions",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_AppSubmissionAnswers_ExamSubmissionId",
                table: "AppSubmissionAnswers",
                column: "ExamSubmissionId");

            migrationBuilder.CreateIndex(
                name: "IX_AppSubmissionAnswers_QuestionId",
                table: "AppSubmissionAnswers",
                column: "QuestionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppQuestionOptions");

            migrationBuilder.DropTable(
                name: "AppSubmissionAnswers");

            migrationBuilder.DropTable(
                name: "AppExamSubmissions");

            migrationBuilder.DropTable(
                name: "AppQuestions");

            migrationBuilder.DropTable(
                name: "AppQuestionGroups");

            migrationBuilder.DropTable(
                name: "AppExams");
        }
    }
}
