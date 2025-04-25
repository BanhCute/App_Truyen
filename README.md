
  📚 App_Truyen
  Ứng dụng đọc và quản lý truyện toàn diện với Flutter và NestJS
  
  
  
  
  
  
  



🚀 Tổng Quan Dự Án
App_Truyen là một nền tảng thân thiện với người dùng, hỗ trợ đọc và quản lý truyện một cách mượt mà. Dự án bao gồm:

Frontend: Ứng dụng di động đa nền tảng được xây dựng bằng Flutter.
Backend: API mạnh mẽ và có khả năng mở rộng với NestJS.
Cơ sở dữ liệu: Sử dụng Neon Console (PostgreSQL) để quản lý dữ liệu.


🛠️ Công Nghệ Sử Dụng



Thành Phần
Công Nghệ
Mô Tả



Frontend
Flutter (Dart)
Xây dựng ứng dụng di động đa nền tảng


Backend
NestJS (TypeScript)
API mạnh mẽ, dễ mở rộng


Cơ Sở Dữ Liệu
Neon Console (PostgreSQL)
Quản lý dữ liệu hiệu quả


Công Cụ Khác
Prisma, Cloudinary, Google Sign-In, JWT
ORM, lưu trữ hình ảnh, xác thực



📱 Frontend
Mô Tả
Dự án Flutter cho ứng dụng di động App_Truyen, mang lại trải nghiệm người dùng mượt mà và tương tác. Thư mục: frontend/.
Các Thư Viện Chính

🌟 flutter: SDK cho Flutter
🛠️ provider: ^6.1.1: Quản lý trạng thái
💾 shared_preferences: ^2.2.2: Lưu trữ cục bộ
🌐 http: ^1.2.0: Gửi yêu cầu HTTP
🎨 font_awesome_flutter: ^10.8.0: Thư viện biểu tượng
🧩 flutter_bloc: ^8.1.6: Mô hình BLoC để quản lý trạng thái
🔑 google_sign_in: ^6.2.2: Đăng nhập bằng Google
📸 image_picker: ^1.1.2: Chọn hình ảnh từ thiết bị

Cài Đặt

Chuyển đến thư mục frontend/.
Chạy lệnh:flutter pub get


Đảm bảo có tệp .env trong thư mục frontend/ để lưu biến môi trường.
Khởi động ứng dụng:flutter run




🌐 Backend
Mô Tả
Backend được xây dựng bằng NestJS, xử lý yêu cầu API, xác thực và quản lý dữ liệu. Thư mục: backend/.
Các Thư Viện Chính

🚀 @nestjs/core: ^10.4.13: Framework NestJS cốt lõi
🔒 @nestjs/jwt: ^10.2.0: Xác thực JWT
📜 @nestjs/swagger: ^8.1.0: Tài liệu API
🗄️ @prisma/client: ^5.22.0: Prisma ORM
🖼️ cloudinary: ^2.5.1: Lưu trữ hình ảnh
🛡️ helmet: ^8.0.0: Middleware bảo mật

Scripts Chính

🛠️ npm run build: Build dự án
▶️ npm run dev: Khởi động server ở chế độ phát triển
✅ npm run test: Chạy unit test
🧪 npm run test:e2e: Chạy end-to-end test

Cài Đặt

Chuyển đến thư mục backend/.
Cài đặt thư viện:npm install


Thiết lập biến môi trường trong tệp .env (URL cơ sở dữ liệu, Cloudinary, v.v.).
Khởi động server:npm run dev




🗄️ Cơ Sở Dữ Liệu
Mô Tả
Dự án sử dụng Neon Console, một dịch vụ PostgreSQL được quản lý.
Cài Đặt

Đăng ký tài khoản trên Neon Console.
Tạo một cơ sở dữ liệu PostgreSQL mới.
Lấy chuỗi kết nối và thêm vào tệp .env của backend.
Áp dụng migration với Prisma:npx prisma migrate dev




🔗 API Endpoint
Backend đã được deploy trên Render và có thể truy cập tại:Base URL: https://webtruyenfull.onrender.com/api/v1
Cấu hình URL này trong tệp .env của frontend để kết nối với backend.

⚙️ Hướng Dẫn Cài Đặt
1. Clone Repository
git clone https://github.com/BanhCute/App_Truyen.git
cd App_Truyen

2. Cài Đặt Frontend
Thực hiện các bước trong phần Frontend.
3. Cài Đặt Backend
Thực hiện các bước trong phần Backend.
4. Cài Đặt Cơ Sở Dữ Liệu
Thực hiện các bước trong phần Cơ Sở Dữ Liệu.
5. Kết Nối API
Cập nhật URL API (https://webtruyenfull.onrender.com/api/v1) trong tệp .env của frontend.

🤝 Đóng Góp
Chúng tôi hoan nghênh mọi đóng góp! Vui lòng làm theo các bước sau:

Fork repository.
Tạo nhánh mới:git checkout -b feature/tính-năng-của-bạn


Commit thay đổi:git commit -m "Thêm tính năng của bạn"


Push lên nhánh:git push origin feature/tính-năng-của-bạn


Mở một pull request.


📜 Giấy Phép
Dự án hiện không có giấy phép (UNLICENSED). Vui lòng liên hệ tác giả để được phép sử dụng.


  ✨ Cảm ơn bạn đã quan tâm đến App_Truyen! ✨
