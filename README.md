App_Truyen
App_Truyen là một ứng dụng full-stack được thiết kế để mang lại trải nghiệm đọc và quản lý truyện mượt mà. Dự án bao gồm frontend được xây dựng bằng Flutter, backend sử dụng NestJS và cơ sở dữ liệu được quản lý bởi Neon Console.
Mục Lục

Tổng Quan Dự Án
Công Nghệ Sử Dụng
Frontend
Backend
Cơ Sở Dữ Liệu
Hướng Dẫn Cài Đặt
API Endpoint
Đóng Góp
Giấy Phép

Tổng Quan Dự Án
App_Truyen là một nền tảng thân thiện với người dùng, hỗ trợ đọc và quản lý truyện. Frontend được xây dựng bằng Flutter để hỗ trợ đa nền tảng trên thiết bị di động, backend được phát triển bằng NestJS để cung cấp API mạnh mẽ và có khả năng mở rộng. Cơ sở dữ liệu sử dụng Neon Console, một giải pháp dựa trên PostgreSQL.
Công Nghệ Sử Dụng

Frontend: Flutter (Dart)
Backend: NestJS (TypeScript)
Cơ Sở Dữ Liệu: Neon Console (PostgreSQL)
Công Cụ Khác: Prisma (ORM), Cloudinary (lưu trữ hình ảnh), Google Sign-In, JWT Authentication

Frontend
Frontend là một dự án Flutter nằm trong thư mục frontend/.
Mô Tả
Dự án Flutter cho ứng dụng di động App_Truyen, được thiết kế để mang lại trải nghiệm người dùng mượt mà và tương tác.
Các Thư Viện Phụ Thuộc

flutter: SDK cho Flutter
provider: ^6.1.1: Quản lý trạng thái
shared_preferences: ^2.2.2: Lưu trữ cục bộ
http: ^1.2.0: Gửi yêu cầu HTTP
font_awesome_flutter: ^10.8.0: Thư viện biểu tượng
flutter_bloc: ^8.1.6: Mô hình BLoC để quản lý trạng thái
flutter_dotenv: ^5.2.1: Quản lý biến môi trường
google_sign_in: ^6.2.2: Đăng nhập bằng Google
image_picker: ^1.1.2: Chọn hình ảnh từ thiết bị
path_provider: ^2.1.5: Truy cập hệ thống tệp
smooth_page_indicator: ^1.2.0+3: Hiển thị chỉ báo trang
flutter_image_compress: ^2.3.0: Nén hình ảnh
dio: ^5.7.0: Client HTTP nâng cao

Cài Đặt

Chuyển đến thư mục frontend/.
Chạy flutter pub get để cài đặt các thư viện phụ thuộc.
Đảm bảo bạn có tệp .env trong thư mục frontend/ để lưu các biến môi trường.
Chạy flutter run để khởi động ứng dụng trên trình giả lập hoặc thiết bị.

Backend
Backend là một dự án NestJS nằm trong thư mục backend/.
Mô Tả
Backend được xây dựng bằng NestJS để xử lý các yêu cầu API, xác thực và quản lý dữ liệu cho ứng dụng App_Truyen.
Các Thư Viện Phụ Thuộc

@nestjs/core: ^10.4.13: Framework NestJS cốt lõi
@nestjs/jwt: ^10.2.0: Xác thực JWT
@nestjs/passport: ^10.0.3: Middleware xác thực
@nestjs/platform-express: ^10.4.13: Tích hợp Express
@nestjs/swagger: ^8.1.0: Tài liệu API
@prisma/client: ^5.22.0: Prisma ORM để quản lý cơ sở dữ liệu
cloudinary: ^2.5.1: Cloudinary để lưu trữ hình ảnh
google-auth-library: ^9.15.0: Xác thực Google
helmet: ^8.0.0: Middleware bảo mật
nestjs-form-data: ^1.9.92: Xử lý dữ liệu biểu mẫu

Scripts

npm run build: Build dự án
npm run start: Khởi động server
npm run dev: Khởi động server ở chế độ phát triển với watch
npm run start:prod: Khởi động server ở chế độ production
npm run test: Chạy unit test
npm run test:e2e: Chạy end-to-end test

Cài Đặt

Chuyển đến thư mục backend/.
Chạy npm install để cài đặt các thư viện phụ thuộc.
Thiết lập các biến môi trường (ví dụ: URL cơ sở dữ liệu, thông tin Cloudinary) trong tệp .env.
Chạy npm run dev để khởi động backend ở chế độ phát triển.

Cơ Sở Dữ Liệu
Dự án sử dụng Neon Console, một dịch vụ cơ sở dữ liệu PostgreSQL được quản lý.
Cài Đặt

Đăng ký tài khoản Neon Console nếu bạn chưa có.
Tạo một cơ sở dữ liệu PostgreSQL mới trên Neon Console.
Lấy chuỗi kết nối cơ sở dữ liệu và thêm vào tệp .env của backend.
Sử dụng Prisma để quản lý migration cơ sở dữ liệu:
Chạy npx prisma migrate dev trong thư mục backend/ để áp dụng migration.



API Endpoint
Backend đã được deploy lên Render và có thể truy cập thông qua endpoint sau:

Base URL: https://webtruyenfull.onrender.com/api/v1

Bạn có thể sử dụng endpoint này để gọi các API từ frontend hoặc các ứng dụng khác. Đảm bảo rằng bạn đã cấu hình đúng các biến môi trường liên quan đến API trong frontend.
Hướng Dẫn Cài Đặt

Clone Repository:git clone https://github.com/BanhCute/App_Truyen.git
cd App_Truyen


Cài Đặt Frontend:
Thực hiện các bước trong phần Frontend.


Cài Đặt Backend:
Thực hiện các bước trong phần Backend.


Cài Đặt Cơ Sở Dữ Liệu:
Thực hiện các bước trong phần Cơ Sở Dữ Liệu.


Đảm bảo cả frontend và backend đều đang chạy, và cơ sở dữ liệu được kết nối đúng cách.
Cập nhật URL API (https://webtruyenfull.onrender.com/api/v1) trong tệp .env của frontend để kết nối với backend đã deploy.

Đóng Góp
Chúng tôi hoan nghênh mọi đóng góp! Vui lòng làm theo các bước sau:

Fork repository.
Tạo một nhánh mới (git checkout -b feature/tính-năng-của-bạn).
Commit các thay đổi của bạn (git commit -m "Thêm tính năng của bạn").
Push lên nhánh (git push origin feature/tính-năng-của-bạn).
Mở một pull request.

Giấy Phép
Dự án này hiện không có giấy phép (UNLICENSED). Vui lòng liên hệ với tác giả để được phép sử dụng.
