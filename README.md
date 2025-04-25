
  📖 App_Truyen
  Ứng dụng đọc và quản lý truyện với Flutter và NestJS
  
  
  
  
  
  



📋 Tổng Quan Dự Án
App_Truyen là một ứng dụng đọc và quản lý truyện, cung cấp trải nghiệm mượt mà cho người dùng. Ứng dụng được xây dựng với Flutter cho phần giao diện (frontend), NestJS cho phần server (backend), và sử dụng Neon (dịch vụ PostgreSQL) làm cơ sở dữ liệu.
Tính năng chính

Tìm kiếm truyện: Tìm truyện theo tên hoặc thể loại.
Xem chi tiết truyện: Hiển thị thông tin chi tiết (mô tả, tác giả, thể loại, v.v.).
Đọc truyện online: Truy cập nội dung truyện trực tiếp.
Quản lý truyện yêu thích: Lưu và quản lý danh sách truyện yêu thích (yêu cầu đăng nhập).
Đăng nhập/Đăng ký: Hỗ trợ đăng nhập bằng Google và tài khoản thông thường.

Cấu trúc dự án

frontend/: Mã nguồn giao diện người dùng (Flutter).
backend/: Mã nguồn server (NestJS).
.gitignore: Định nghĩa các tệp/thư mục bỏ qua khi đẩy lên Git.


🛠️ Công Nghệ Sử Dụng



Phần
Công Nghệ



Frontend
Flutter, Provider, Flutter BLoC


Backend
NestJS, Prisma, Cloudinary


Database
Neon (PostgreSQL)


Quản lý Dependencies
npm (backend), pub (frontend)



📦 Yêu Cầu Hệ Thống
Trước khi bắt đầu, hãy đảm bảo bạn đã cài đặt:

Flutter (phiên bản 3.0.0 hoặc cao hơn) và Dart (phiên bản 3.5.0 hoặc cao hơn).
Node.js (phiên bản 16.x hoặc cao hơn).
npm (thường đi kèm với Node.js).
Tài khoản Neon để quản lý cơ sở dữ liệu PostgreSQL.
(Tùy chọn) pgAdmin hoặc công cụ quản lý PostgreSQL để kiểm tra cơ sở dữ liệu.


🚀 Hướng Dẫn Cài Đặt
Dưới đây là các bước chi tiết để thiết lập dự án sau khi clone từ repository:
1. Clone Dự Án
git clone https://github.com/BanhCute/App_Truyen.git
cd App_Truyen

2. Cài Đặt Dependencies
Dự án có hai phần chính: frontend và backend. Bạn cần cài đặt dependencies cho cả hai.
Frontend

Di chuyển vào thư mục frontend:cd frontend


Cài đặt các thư viện:flutter pub get


Nếu gặp lỗi, hãy đảm bảo cài các thư viện chính:
provider, flutter_bloc, http, google_sign_in, image_picker.


Tạo tệp .env trong thư mục frontend và cấu hình các biến môi trường:API_URL=https://webtruyenfull.onrender.com/api/v1



Backend

Di chuyển vào thư mục backend:cd ../backend


Cài đặt các thư viện:npm install


Nếu npm install không cài đầy đủ, hãy đảm bảo cài thêm các thư viện sau:npm install @nestjs/jwt @prisma/client cloudinary helmet


@nestjs/jwt: Xử lý xác thực JWT.
@prisma/client: ORM cho PostgreSQL.
cloudinary: Lưu trữ hình ảnh.
helmet: Tăng cường bảo mật API.


Tạo tệp .env trong thư mục backend và cấu hình các biến môi trường:PORT=5000
DATABASE_URL=<your-neon-postgresql-url>
CLOUDINARY_URL=<your-cloudinary-url>



3. Cấu Hình Cơ Sở Dữ Liệu

Neon (PostgreSQL):
Đăng nhập vào tài khoản Neon, tạo một dự án và lấy chuỗi kết nối (connection string).
Cập nhật chuỗi kết nối vào tệp .env của backend.
Chạy migration để tạo bảng:npx prisma migrate dev





4. Chạy Ứng Dụng
Backend
Trong thư mục backend, khởi động server:
npm run dev

Server sẽ chạy tại http://localhost:5000. API đã được deploy tại:Base URL: https://webtruyenfull.onrender.com/api/v1
Frontend
Trong thư mục frontend, chạy ứng dụng Flutter:
flutter run

Ứng dụng sẽ chạy trên trình giả lập hoặc thiết bị di động.
5. Kiểm Tra Cơ Sở Dữ Liệu

Neon: Sử dụng bảng điều khiển Neon hoặc pgAdmin để kiểm tra kết nối và dữ liệu.


🛠️ Các Lệnh Thường Dùng



Lệnh
Mô Tả



flutter pub get
Cài đặt dependencies cho frontend.


npm install
Cài đặt dependencies cho backend.


npm run dev (backend)
Khởi động server backend ở chế độ phát triển.


flutter run (frontend)
Khởi động ứng dụng Flutter.


npx prisma migrate dev
Áp dụng migration cho cơ sở dữ liệu.



⚠️ Lưu Ý Khi Clone Dự Án

Thiếu Dependencies:
Nếu flutter pub get hoặc npm install không cài hết thư viện, kiểm tra các thư viện chính và cài thủ công (xem bước 2).


Tệp .env:
Tệp này không được đẩy lên Git. Bạn phải tạo lại .env với các biến môi trường cần thiết.


Kết Nối Cơ Sở Dữ Liệu:
Đảm bảo chuỗi kết nối database (Neon) chính xác.


Phiên Bản Flutter và Node.js:
Sử dụng Flutter 3.0.0+ và Node.js 16.x+ để tránh lỗi tương thích.




❓ Khắc Phục Sự Cố

Lỗi flutter pub get hoặc npm install:
Xóa thư mục pubspec.lock (frontend) hoặc node_modules và package-lock.json (backend), sau đó chạy lại lệnh cài đặt.


Lỗi Kết Nối Database:
Kiểm tra chuỗi kết nối trong .env.
Đảm bảo Neon đang hoạt động.


Lỗi Frontend Không Kết Nối Được API:
Kiểm tra API_URL trong .env của frontend.
Đảm bảo backend đang chạy hoặc API tại https://webtruyenfull.onrender.com/api/v1 hoạt động.




📢 Góp Ý
Nếu bạn có ý tưởng hoặc muốn báo lỗi, hãy tạo issue trên repository hoặc liên hệ trực tiếp với tôi.

👤 Đóng Góp
Dự án được phát triển bởi:  

BanhCute (Tác giả duy nhất)



  ✨ Cảm ơn bạn đã quan tâm đến App_Truyen! 📚
