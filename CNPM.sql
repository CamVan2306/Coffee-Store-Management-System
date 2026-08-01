CREATE DATABASE QL_QUANCAFE;

USE QL_QUANCAFE;
GO

------------------------------------------------------
-- I. NGHIỆP VỤ 3: QUẢN LÝ NHÂN VIÊN & CA LÀM VIỆC (Có Đăng nhập)
------------------------------------------------------

-- 1. Bảng NHANVIEN (Bổ sung Đăng nhập và Quyền)
CREATE TABLE NHANVIEN (
    MANV VARCHAR(10) PRIMARY KEY,
    HOTENNV NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15),
    CHUCVU NVARCHAR(50) NOT NULL, 
    LUONG_COBAN DECIMAL(18, 0),

    -- Cột đăng nhập và phân quyền
    TAIKHOAN VARCHAR(50) UNIQUE NOT NULL, 
    MATKHAU VARCHAR(255) NOT NULL,       -- Lưu mật khẩu đã mã hóa (Hash)
    QUYEN NVARCHAR(20) NOT NULL,        -- Ví dụ: 'Admin', 'User', 'Thu ngân'
    TRANGTHAI_TK NVARCHAR(20) DEFAULT N'Hoạt động'
);

-- 2. Bảng CALAM (Ca làm việc cố định)
CREATE TABLE CALAM (
    MACA VARCHAR(10) PRIMARY KEY,
    TENCA NVARCHAR(50) NOT NULL,
    THOIGIAN_BATDAU TIME,
    THOIGIAN_KETTHUC TIME
);

-- 3. Bảng CHITIET_CALAM_NV (Ca làm việc thực tế)
CREATE TABLE CHITIET_CALAM_NV (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MANV VARCHAR(10) NOT NULL,
    MACA VARCHAR(10) NOT NULL,
    NGAYLAM DATE NOT NULL,
    GIO_VAO TIME,
    GIO_RA TIME,
    DOANHTHU_BANHANG DECIMAL(18, 0) DEFAULT 0,
    FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV),
    FOREIGN KEY (MACA) REFERENCES CALAM(MACA)
);

------------------------------------------------------
-- II. NGHIỆP VỤ 2: QUẢN LÝ DANH MỤC SẢN PHẨM (Có Hình ảnh)
------------------------------------------------------

-- 4. Bảng LOAIMON 
CREATE TABLE LOAIMON (
    MALOAI VARCHAR(10) PRIMARY KEY,
    TENLOAI NVARCHAR(50) NOT NULL
);

-- 5. Bảng SANPHAM 
CREATE TABLE SANPHAM (
    MAMON VARCHAR(10) PRIMARY KEY,
    TENMON NVARCHAR(100) NOT NULL,
    MALOAI VARCHAR(10) NOT NULL,
    GIA DECIMAL(18, 0) NOT NULL,
    DONVITINH NVARCHAR(20),
    TRANGTHAI NVARCHAR(50) DEFAULT N'Đang phục vụ',
    HINHANH_URL VARCHAR(255), -- Đường dẫn file .jpg cho giao diện POS
    FOREIGN KEY (MALOAI) REFERENCES LOAIMON(MALOAI)
);

------------------------------------------------------
-- III. NGHIỆP VỤ 1: QUẢN LÝ BÁN HÀNG & THANH TOÁN (Counter Service)
------------------------------------------------------

-- 6. Bảng HOADON 
CREATE TABLE HOADON (
    MAHD VARCHAR(10) PRIMARY KEY,
    NGAYLAP DATETIME DEFAULT GETDATE(),
    MANV_LAP VARCHAR(10) NOT NULL,
    TONGTIEN DECIMAL(18, 0) NOT NULL,
    PHUONGTHUC_THANHTOAN NVARCHAR(50),
    TRANGTHAI NVARCHAR(50), -- Đang mở, Đã thanh toán, Đã hủy
    -- Cột BAN đã được loại bỏ ở phiên bản này
    FOREIGN KEY (MANV_LAP) REFERENCES NHANVIEN(MANV)
);

-- 7. Bảng CHITIET_HOADON
CREATE TABLE CHITIET_HOADON (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MAHD VARCHAR(10) NOT NULL,
    MAMON VARCHAR(10) NOT NULL,
    SOLUONG INT NOT NULL,
    DONGIA_BAN DECIMAL(18, 0) NOT NULL,
    THANHTIEN AS SOLUONG * DONGIA_BAN,
    TRANGTHAI_MON NVARCHAR(50) DEFAULT N'Chờ làm',
    FOREIGN KEY (MAHD) REFERENCES HOADON(MAHD),
    FOREIGN KEY (MAMON) REFERENCES SANPHAM(MAMON)
);

GO

------------------------------------------------------
-- 1. DỮ LIỆU BẢNG NHANVIEN (Có Tài khoản Đăng nhập)
------------------------------------------------------
-- Mật khẩu mặc định: 123 (Chưa mã hóa)

INSERT INTO NHANVIEN (MANV, HOTENNV, SDT, CHUCVU, LUONG_COBAN, TAIKHOAN, MATKHAU, QUYEN) VALUES
('NV01', N'Nguyễn Văn An', '0901123456', N'Phục vụ', 25000, 'admin', '123', N'Admin'),
('NV02', N'Lê Thị Bình', '0902456789', N'Pha chế', 28000, 'binhlt', '123', N'Pha chế'),
('NV03', N'Trần Minh Quang', '0903344556', N'Thu ngân', 30000, 'quangtm', '123', N'Thu ngân'),
('NV04', N'Phạm Hoài Nam', '0909988776', N'Quản lý', 35000, 'namph', '123', N'Admin');


------------------------------------------------------
-- 2. DỮ LIỆU BẢNG CALAM
------------------------------------------------------

INSERT INTO CALAM (MACA, TENCA, THOIGIAN_BATDAU, THOIGIAN_KETTHUC) VALUES
('CA1', N'Ca sáng', '06:00', '12:00'),
('CA2', N'Ca chiều', '12:00', '18:00'),
('CA3', N'Ca tối', '18:00', '23:00');


------------------------------------------------------
-- 3. DỮ LIỆU BẢNG CHITIET_CALAM_NV (Phục vụ báo cáo lương)
------------------------------------------------------

INSERT INTO CHITIET_CALAM_NV (MANV, MACA, NGAYLAM, GIO_VAO, GIO_RA, DOANHTHU_BANHANG) VALUES
('NV01', 'CA1', '2025-01-10', '06:00', '12:00', 1200000),
('NV02', 'CA1', '2025-01-10', '06:15', '12:05', 950000),
('NV03', 'CA2', '2025-01-10', '12:00', '18:00', 1600000),
('NV01', 'CA3', '2025-01-11', '18:00', '23:00', 800000);


------------------------------------------------------
-- 4. DỮ LIỆU BẢNG LOAIMON
------------------------------------------------------

INSERT INTO LOAIMON (MALOAI, TENLOAI) VALUES
('L01', N'Cà phê'),
('L02', N'Sinh tố'),
('L03', N'Trà'),
('L04', N'Bánh ngọt'),
('L05', N'Đồ ăn nhẹ');


------------------------------------------------------
-- 5. DỮ LIỆU BẢNG SANPHAM (Có Hình ảnh)
------------------------------------------------------
-- Giả định các file ảnh được lưu trong thư mục ~/Images/
INSERT INTO SANPHAM (MAMON, TENMON, MALOAI, GIA, DONVITINH, TRANGTHAI, HINHANH_URL) VALUES
('M01', N'Cà phê đen', 'L01', 25000, N'Ly', N'Đang phục vụ', '/Content/Images/coffee_black.jpg'),
('M02', N'Cà phê sữa', 'L01', 30000, N'Ly', N'Đang phục vụ', '/Content/Images/coffee_milk.jpg'),
('M03', N'Espresso', 'L01', 35000, N'Ly', N'Đang phục vụ', '/Content/Images/espresso.jpg'),
('M04', N'Sinh tố xoài', 'L02', 45000, N'Ly', N'Đang phục vụ', '/Content/Images/smoothie_mango.jpg'),
('M05', N'Sinh tố dâu', 'L02', 45000, N'Ly', N'Đang phục vụ', '/Content/Images/smoothie_strawberry.jpg'),
('M06', N'Trà đào cam sả', 'L03', 40000, N'Ly', N'Đang phục vụ', '/Content/Images/tea_peach.jpg'),
('M07', N'Trà sữa trân châu', 'L03', 35000, N'Ly', N'Đang phục vụ', '/Content/Images/milktea.jpg'),
('M08', N'Bánh tiramisu', 'L04', 55000, N'Cái', N'Đang phục vụ', '/Content/Images/tiramisu.jpg'),
('M09', N'Bánh phô mai', 'L04', 60000, N'Cái', N'Đang phục vụ', '/Content/Images/cheesecake.jpg'),
('M10', N'Bánh mì bơ tỏi', 'L05', 30000, N'Phần', N'Đang phục vụ', '/Content/Images/garlic_bread.jpg');


------------------------------------------------------
-- 6. DỮ LIỆU BẢNG HOADON (Order đã hoàn tất)
------------------------------------------------------
-- Dùng ngày 2025-01-10 cho các giao dịch mẫu
INSERT INTO HOADON (MAHD, NGAYLAP, MANV_LAP, TONGTIEN, PHUONGTHUC_THANHTOAN, TRANGTHAI) VALUES
('HD01', '2025-01-10 08:30:00', 'NV01', 55000, N'Tiền mặt', N'Đã thanh toán'),
('HD02', '2025-01-10 09:45:00', 'NV03', 90000, N'Thẻ', N'Đã thanh toán'),
('HD03', '2025-01-11 19:10:00', 'NV01', 115000, N'Chuyển khoản', N'Đã thanh toán');


------------------------------------------------------
-- 7. DỮ LIỆU BẢNG CHITIET_HOADON
------------------------------------------------------

INSERT INTO CHITIET_HOADON (MAHD, MAMON, SOLUONG, DONGIA_BAN, TRANGTHAI_MON) VALUES
-- Hóa đơn 1 (Tổng 55000)
('HD01', 'M01', 1, 25000, N'Hoàn thành'),
('HD01', 'M10', 1, 30000, N'Hoàn thành'),

-- Hóa đơn 2 (Tổng 90000)
('HD02', 'M04', 2, 45000, N'Hoàn thành'),

-- Hóa đơn 3 (Tổng 115000)
('HD03', 'M08', 1, 55000, N'Hoàn thành'),
('HD03', 'M02', 2, 30000, N'Hoàn thành');


SELECT * FROM CALAM;
SELECT * FROM CHITIET_CALAM_NV;
SELECT * FROM CHITIET_HOADON;
SELECT * FROM HOADON;
SELECT * FROM LOAIMON;
SELECT * FROM NHANVIEN;
SELECT * FROM SANPHAM;

