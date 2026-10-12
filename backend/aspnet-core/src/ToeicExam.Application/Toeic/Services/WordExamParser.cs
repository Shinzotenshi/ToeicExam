using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace ToeicExam.Toeic.Services
{
    public class ParsedQuestionOption
    {
        public string OptionKey { get; set; }
        public string Content { get; set; }
    }

    public class ParsedQuestion
    {
        public int QuestionNumber { get; set; }
        public string Content { get; set; }
        public string CorrectOption { get; set; }
        public string Explanation { get; set; }
        public List<ParsedQuestionOption> Options { get; set; } = new List<ParsedQuestionOption>();
    }

    public class ParsedQuestionGroup
    {
        public int PartNumber { get; set; }
        public int GroupOrder { get; set; }
        public string Title { get; set; }
        public string PassageText { get; set; }
        public string PassageImageUrl { get; set; }
        public List<ParsedQuestion> Questions { get; set; } = new List<ParsedQuestion>();
    }

    public class ParsedExamResult
    {
        public bool IsValid { get; set; }
        public List<string> ValidationErrors { get; set; } = new List<string>();
        public string ExamTitle { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; } = 75;
        public int TotalQuestions { get; set; }
        public List<ParsedQuestionGroup> Groups { get; set; } = new List<ParsedQuestionGroup>();
    }

    public static class WordExamParser
    {
        private static readonly XNamespace WNs = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

        public static ParsedExamResult ParseDocx(Stream docxStream, string defaultTitle = null)
        {
            var result = new ParsedExamResult();
            var paragraphs = new List<string>();

            try
            {
                using (var archive = new ZipArchive(docxStream, ZipArchiveMode.Read, true))
                {
                    var entry = archive.GetEntry("word/document.xml");
                    if (entry == null)
                    {
                        result.ValidationErrors.Add("File Word không hợp lệ (không tìm thấy word/document.xml).");
                        result.IsValid = false;
                        return result;
                    }

                    using (var reader = new StreamReader(entry.Open()))
                    {
                        var doc = XDocument.Load(reader);
                        var pElements = doc.Descendants(WNs + "p");
                        foreach (var p in pElements)
                        {
                            var texts = p.Descendants(WNs + "t").Select(t => t.Value);
                            var pText = string.Concat(texts).Trim();
                            paragraphs.Add(pText);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                result.ValidationErrors.Add($"Lỗi đọc file Word: {ex.Message}");
                result.IsValid = false;
                return result;
            }

            return ParseParagraphs(paragraphs, defaultTitle);
        }

        public static ParsedExamResult ParseParagraphs(List<string> rawParagraphs, string defaultTitle)
        {
            var result = new ParsedExamResult();
            result.ExamTitle = string.IsNullOrWhiteSpace(defaultTitle) ? "Đề thi TOEIC Reading (100 câu)" : defaultTitle;
            result.Description = "Đề thi TOEIC Reading chuẩn format gồm Part 5, 6, 7";
            result.DurationMinutes = 75;

            var nonBlankParas = rawParagraphs.Select(p => p.Trim()).Where(p => !string.IsNullOrEmpty(p)).ToList();

            if (!nonBlankParas.Any())
            {
                result.ValidationErrors.Add("File Word rỗng, không chứa nội dung.");
                result.IsValid = false;
                return result;
            }

            int currentPart = 5;
            int groupOrder = 1;
            ParsedQuestionGroup currentGroup = null;
            ParsedQuestion currentQuestion = null;

            bool inPassage = false;
            var currentPassageLines = new List<string>();

            var allQuestions = new List<ParsedQuestion>();
            var expectedNumber = 101;

            for (int i = 0; i < nonBlankParas.Count; i++)
            {
                var line = nonBlankParas[i];

                // Detect Part change
                var partMatch = Regex.Match(line, @"^\[PART:\s*(\d+)\]", RegexOptions.IgnoreCase);
                if (partMatch.Success)
                {
                    currentPart = int.Parse(partMatch.Groups[1].Value);
                    if (currentPart != 5 && currentPart != 6 && currentPart != 7)
                    {
                        result.ValidationErrors.Add($"Phần thi [PART: {currentPart}] không hợp lệ. Chỉ chấp nhận Part 5, 6, 7.");
                    }

                    if (currentPart == 5)
                    {
                        currentGroup = new ParsedQuestionGroup
                        {
                            PartNumber = 5,
                            GroupOrder = groupOrder++,
                            Title = "Part 5: Incomplete Sentences",
                            PassageText = null
                        };
                        result.Groups.Add(currentGroup);
                    }
                    else
                    {
                        currentGroup = null;
                    }
                    continue;
                }

                // Detect Passage Start
                if (line.StartsWith("[PASSAGE_START]", StringComparison.OrdinalIgnoreCase))
                {
                    if (inPassage)
                    {
                        result.ValidationErrors.Add($"Thẻ [PASSAGE_START] bị lặp mà chưa đóng [PASSAGE_END] tại dòng {i + 1}.");
                    }
                    inPassage = true;
                    currentPassageLines.Clear();
                    continue;
                }

                // Detect Passage End
                if (line.StartsWith("[PASSAGE_END]", StringComparison.OrdinalIgnoreCase))
                {
                    if (!inPassage)
                    {
                        result.ValidationErrors.Add($"Thẻ [PASSAGE_END] xuất hiện nhưng không có [PASSAGE_START] trước đó tại dòng {i + 1}.");
                    }
                    inPassage = false;

                    var passageFull = string.Join("\n\n", currentPassageLines);
                    var titleLine = currentPassageLines.FirstOrDefault() ?? $"Part {currentPart} Questions";

                    currentGroup = new ParsedQuestionGroup
                    {
                        PartNumber = currentPart,
                        GroupOrder = groupOrder++,
                        Title = titleLine,
                        PassageText = passageFull
                    };
                    result.Groups.Add(currentGroup);
                    continue;
                }

                if (inPassage)
                {
                    currentPassageLines.Add(line);
                    continue;
                }

                // Detect Question
                var qMatch = Regex.Match(line, @"^\[Q:\s*(\d+)\]\s*(.*)", RegexOptions.IgnoreCase);
                if (qMatch.Success)
                {
                    int qNum = int.Parse(qMatch.Groups[1].Value);
                    string qContent = qMatch.Groups[2].Value.Trim();

                    if (currentGroup == null)
                    {
                        currentGroup = new ParsedQuestionGroup
                        {
                            PartNumber = currentPart,
                            GroupOrder = groupOrder++,
                            Title = $"Part {currentPart} Group",
                            PassageText = null
                        };
                        result.Groups.Add(currentGroup);
                    }

                    currentQuestion = new ParsedQuestion
                    {
                        QuestionNumber = qNum,
                        Content = qContent,
                        Options = new List<ParsedQuestionOption>()
                    };
                    currentGroup.Questions.Add(currentQuestion);
                    allQuestions.Add(currentQuestion);
                    continue;
                }

                // Detect Options [A], [B], [C], [D]
                var optMatch = Regex.Match(line, @"^\[([A-D])\]\s*(.*)", RegexOptions.IgnoreCase);
                if (optMatch.Success)
                {
                    if (currentQuestion == null)
                    {
                        result.ValidationErrors.Add($"Đáp án [{optMatch.Groups[1].Value}] xuất hiện trước khi bắt đầu câu hỏi tại dòng {i + 1}.");
                    }
                    else
                    {
                        var key = optMatch.Groups[1].Value.ToUpper();
                        var optContent = optMatch.Groups[2].Value.Trim();
                        currentQuestion.Options.Add(new ParsedQuestionOption
                        {
                            OptionKey = key,
                            Content = optContent
                        });
                    }
                    continue;
                }

                // Detect Key [KEY: X]
                var keyMatch = Regex.Match(line, @"^\[KEY:\s*([A-D])\]", RegexOptions.IgnoreCase);
                if (keyMatch.Success)
                {
                    if (currentQuestion == null)
                    {
                        result.ValidationErrors.Add($"Đáp án đúng [KEY] xuất hiện ngoài câu hỏi tại dòng {i + 1}.");
                    }
                    else
                    {
                        currentQuestion.CorrectOption = keyMatch.Groups[1].Value.ToUpper();
                    }
                    continue;
                }
            }

            if (inPassage)
            {
                result.ValidationErrors.Add("Thiếu thẻ đóng [PASSAGE_END] ở cuối file.");
            }

            // Validate all questions
            if (!allQuestions.Any())
            {
                result.ValidationErrors.Add("Không tìm thấy câu hỏi nào trong file.");
            }

            for (int i = 0; i < allQuestions.Count; i++)
            {
                var q = allQuestions[i];
                var expected = expectedNumber + i;
                if (q.QuestionNumber != expected)
                {
                    result.ValidationErrors.Add($"Thứ tự câu hỏi không chuẩn: Đang mong đợi câu {expected} nhưng tìm thấy câu {q.QuestionNumber}.");
                }

                var optionKeys = q.Options.Select(o => o.OptionKey).ToList();
                if (optionKeys.Count != 4 || !optionKeys.Contains("A") || !optionKeys.Contains("B") || !optionKeys.Contains("C") || !optionKeys.Contains("D"))
                {
                    result.ValidationErrors.Add($"Câu {q.QuestionNumber} không đủ 4 đáp án [A], [B], [C], [D]. Hiện có: {string.Join(", ", optionKeys)}.");
                }

                if (string.IsNullOrWhiteSpace(q.CorrectOption))
                {
                    result.ValidationErrors.Add($"Câu {q.QuestionNumber} thiếu đáp án đúng [KEY: X].");
                }
            }

            result.TotalQuestions = allQuestions.Count;
            result.IsValid = !result.ValidationErrors.Any();
            return result;
        }
    }
}
