-- ========================================================
-- PHẦN 1: TÁI CẤU TRÚC DỮ LIỆU (DDL)
-- ========================================================
CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- Xóa bảng theo thứ tự để tránh lỗi khóa ngoại
DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;

-- Tạo bảng Patients
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- Tạo bảng Doctors
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- Tạo bảng Appointments (Đã tối ưu hóa theo Activity Diagram)
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    deposit_amount DECIMAL(10, 2) DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) DEFAULT 0.00,
    cancel_reason VARCHAR(255) NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
);

-- Tạo bảng Prescriptions (Bổ sung bảng Đơn thuốc)
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với Appointments
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- ========================================================
-- PHẦN 2: THÊM DỮ LIỆU MẪU & MÔ PHỎNG KỊCH BẢN (DML)
-- ========================================================

-- Thêm dữ liệu nền
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Le Van C', 'Noi khoa'),
('BS. Pham Thi D', 'Nhi khoa');

-- KỊCH BẢN 1: Luồng khám bệnh thành công (Happy Path)
-- 1. Insert lịch hẹn PENDING với tiền cọc 500,000đ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-10-01 09:00:00', 'PENDING', 500000.00);

-- 2. Cập nhật trạng thái sang CHECKED_IN khi bệnh nhân đến
UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;

-- 3. Cập nhật trạng thái sang COMPLETED khi hoàn tất khám
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

-- 4. Kê đơn thuốc cho lịch hẹn đã hoàn thành
INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (1, 'Paracetamol 500mg (20 viên), Amoxicillin 500mg (14 viên). Uong sau khi an.');


-- KỊCH BẢN 2: Luồng Hủy lịch và Phạt tiền cọc (Cancellation Path)
-- 1. Insert lịch hẹn CONFIRMED cọc 300,000đ
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-10-02 14:00:00', 'CONFIRMED', 300000.00);

-- 2. Bệnh nhân hủy lịch: Cập nhật trạng thái CANCELLED, lý do hủy và phí phạt 150,000đ
UPDATE Appointments 
SET status = 'CANCELLED', 
    cancel_reason = 'Ban viec dot xuat', 
    penalty_fee = 150000.00 
WHERE appointment_id = 2;

-- ========================================================
-- PHẦN 3: CÂU LỆNH TRUY VẤN KIỂM TRA (VERIFICATION)
-- ========================================================

-- Truy vấn 1: Danh sách bệnh nhân đã hoàn tất khám kèm chi tiết đơn thuốc
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    a.status,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';

-- Truy vấn 2: Báo cáo đối soát lịch hẹn hủy và doanh thu phí phạt
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    a.deposit_amount,
    a.penalty_fee,
    (a.deposit_amount - a.penalty_fee) AS refund_amount,
    a.cancel_reason
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.status = 'CANCELLED';
