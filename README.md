# Hệ Thống Khảo Thí Trắc Nghiệm TOEIC Reading (Đề thi giữa kỳ v01)

Dự án bài thi trắc nghiệm trực tuyến chuẩn cấu trúc đề thi **TOEIC Reading v01 (100 câu hỏi)** bao gồm:
- **Part 5:** Điền câu (Câu 101 - 130)
- **Part 6:** Điền đoạn văn (Câu 131 - 146)
- **Part 7:** Đọc hiểu văn bản (Câu 147 - 200)

Được phát triển với kiến trúc tách biệt:
1. **Backend:** ASP.NET Core & ASP.NET Boilerplate (.NET 9 / SQL Server), hỗ trợ API RESTful và trang quản trị giảng viên.
2. **Frontend:** Ứng dụng Flutter (hỗ trợ Web, Mobile, Desktop) thiết kế hiện đại, chia đôi màn hình đọc hiểu và làm bài trực quan.

---

## 🗄️ Cấu trúc Cơ sở dữ liệu (6 Bảng Chuẩn)

1. `exams`: Quản lý thông tin đề thi, thời gian làm bài (75 phút), tổng số câu (100 câu).
2. `questiongroups`: Nhóm câu hỏi chứa đoạn văn đọc hiểu, hình ảnh bài đọc minh họa (Part 6 & 7).
3. `questions`: Danh sách 100 câu hỏi trắc nghiệm kèm giải thích chi tiết.
4. `questionoptions`: Các phương án trả lời A, B, C, D và đáp án chính xác (`IsCorrect`).
5. `examsubmissions`: Lượt nộp bài của thí sinh, tính điểm chuẩn TOEIC thang điểm 495.
6. `submissionAnswers`: Chi tiết từng câu trả lời của thí sinh.

---

## 🚀 Hướng Dẫn Chạy Dự Án

### 1. Khởi động Backend (ASP.NET Core)
```bash
cd backend/aspnet-core
dotnet restore
dotnet run --project src/ToeicExam.Web.Mvc/ToeicExam.Web.Mvc.csproj --urls "http://localhost:5000"
```
- **Trang Quản trị & Giảng viên:** `http://localhost:5000` (Truy cập trực tiếp, không yêu cầu đăng nhập)
- **API Swagger / Endpoint:** `http://localhost:5000/api/ToeicApi`

### 2. Khởi động Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 8080
```
- **Giao diện Làm bài thi thí sinh:** `http://localhost:8080`

---

## ✨ Tính Năng Nổi Bật

- **Không yêu cầu đăng nhập:** Thí sinh và giảng viên có thể truy cập và sử dụng trực tiếp.
- **Upload File Word (.docx):** Bóc tách tự động 100 câu hỏi từ file Word vào cơ sở dữ liệu.
- **Giao diện Split-view:** Nửa màn hình hiển thị bài đọc/hình ảnh, nửa màn hình hiển thị câu hỏi và đáp án A-B-C-D.
- **Chấm điểm tự động:** Tự động tính điểm chuẩn TOEIC Reading (tối đa 495 điểm).
- **Xem lại & Đối soát:** Xem chi tiết câu làm đúng/sai kèm đáp án chuẩn.
