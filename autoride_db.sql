-- ========================================================
-- PHẦN 1: TÁI CẤU TRÚC VÀ NÂNG CẤP CSDL (DDL)
-- ========================================================
CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

-- Xóa bảng cũ nếu tồn tại theo thứ tự khóa ngoại
DROP TABLE IF EXISTS Inspections;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Cars;

-- 1. Tạo bảng Cars
CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Tạo bảng Rentals với đầy đủ ràng buộc trạng thái và tài chính
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME NULL,
    status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    security_deposit DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    late_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    damage_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (car_id) REFERENCES Cars(car_id) ON DELETE RESTRICT
);

-- 3. Tạo bảng Inspections (Biên bản kiểm tra xe)
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL UNIQUE, -- Quan hệ 1-1: Mỗi lượt thuê có 1 biên bản kiểm tra chính khi trả xe
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
);

-- ========================================================
-- PHẦN 2: THÊM DỮ LIỆU MẪU VÀ MÔ PHỎNG NGHIỆP VỤ (DML)
-- ========================================================

-- Thêm xe mẫu
INSERT INTO Cars (model_name, license_plate) 
VALUES ('Toyota Camry 2023', '30F-123.45');

-- KỊCH BẢN THỰC TẾ:
-- Bước 1: Khách "Nguyen Van A" đặt thuê xe, đóng cọc 10.000.000 VNĐ. Chuyển trạng thái ACTIVE
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-09-01 08:00:00', 'ACTIVE', 10000000.00);

-- Bước 2: Khách trả xe. Nhân viên lập biên bản kiểm tra phát hiện "Vỡ đèn pha trái"
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-09-05 17:00:00', 'Vỡ đèn pha trái do va quệt', 'Tran Van Inspector');

-- Bước 3: Cập nhật hợp đồng Rentals khi hoàn tất: 
-- Trạng thái COMPLETED, late_fee = 0, damage_fee = 2.000.000 VNĐ
UPDATE Rentals 
SET return_date = '2026-09-05 17:00:00',
    status = 'COMPLETED',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- ========================================================
-- PHẦN 3: CÂU LỆNH TRUY VẤN KIỂM TRA & TÍNH TOÁN (VERIFICATION)
-- ========================================================

-- Lệnh SELECT tính toán chính xác tiền hoàn lại cho khách hàng
SELECT 
    r.rental_id,
    r.customer_name,
    c.model_name,
    c.license_plate,
    i.damage_description,
    r.security_deposit,
    r.late_fee,
    r.damage_fee,
    (r.security_deposit - r.late_fee - r.damage_fee) AS actual_refund_amount,
    r.status
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;
