/*
  Project: Parcel Delivery Database
  Platform: Microsoft SQL Server (SSMS)
  Purpose: Add reference values and example records. Safe to run more than once.
*/

USE ParcelDeliveryDB;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ParcelType WHERE ParcelTypeID = 1)
    INSERT dbo.ParcelType (ParcelTypeID, TypeName, Description) VALUES
    (1, N'General', N'พัสดุทั่วไป'),
    (2, N'Fragile', N'พัสดุที่แตกหักง่าย'),
    (3, N'Document', N'เอกสาร');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ParcelStatus WHERE StatusID = 1)
    INSERT dbo.ParcelStatus (StatusID, StatusName, Description) VALUES
    (1, N'Received', N'รับพัสดุแล้ว'),
    (2, N'In Transit', N'กำลังจัดส่ง'),
    (3, N'Delivered', N'จัดส่งสำเร็จ'),
    (4, N'Delivery Failed', N'จัดส่งไม่สำเร็จ');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE CustomerID = 'CUS001')
    INSERT dbo.Customer (CustomerID, CustomerName, Phone, Address, Email) VALUES
    ('CUS001', N'สมชาย ใจดี', '0812345678', N'123 ถนนมิตรภาพ อุดรธานี', 'somchai@example.com'),
    ('CUS002', N'วรรณา สุขใจ', '0891234567', N'45 ถนนสุขุมวิท กรุงเทพฯ', 'wanna@example.com'),
    ('CUS003', N'ปรีชา แสงทอง', '0865551234', N'88 ถนนประชารักษา ขอนแก่น', NULL),
    ('CUS004', N'มาลี มีสุข', '0924446789', N'19 ถนนโพศรี อุดรธานี', 'malee@example.com');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 'EMP001')
    INSERT dbo.Employee (EmployeeID, EmployeeName, Phone, Position, HireDate) VALUES
    ('EMP001', N'อนันต์ สุขสันต์', '0891234567', N'พนักงานรับพัสดุ', '2025-01-15'),
    ('EMP002', N'กมลวรรณ ศรีดี', '0815552468', N'พนักงานนำจ่าย', '2025-03-01'),
    ('EMP003', N'ธนา พูนผล', '0863331478', N'หัวหน้าศูนย์', '2024-06-10');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Parcel WHERE ParcelID = 'PCL0001')
    INSERT dbo.Parcel (ParcelID, TrackingNumber, SenderID, ReceiverID, ReceivedByEmployeeID,
                       ParcelTypeID, WeightKg, ShippingFee, ReceivedAt,
                       SenderAddressSnapshot, ReceiverAddressSnapshot, CurrentStatusID) VALUES
    ('PCL0001', 'TH123456789', 'CUS001', 'CUS002', 'EMP001', 2, 2.50, 50.00,
     '2026-10-03T09:30:00', N'123 ถนนมิตรภาพ อุดรธานี', N'45 ถนนสุขุมวิท กรุงเทพฯ', 1),
    ('PCL0002', 'TH123456790', 'CUS002', 'CUS003', 'EMP001', 1, 5.20, 75.00,
     '2026-10-03T10:15:00', N'45 ถนนสุขุมวิท กรุงเทพฯ', N'88 ถนนประชารักษา ขอนแก่น', 1),
    ('PCL0003', 'TH123456791', 'CUS004', 'CUS001', 'EMP003', 3, 0.30, 80.00,
     '2026-10-03T11:00:00', N'19 ถนนโพศรี อุดรธานี', N'123 ถนนมิตรภาพ อุดรธานี', 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Payment WHERE PaymentID = 'PAY0001')
    INSERT dbo.Payment (PaymentID, ParcelID, PaymentMethod, Amount, PaymentDate, PaymentStatus) VALUES
    ('PAY0001', 'PCL0001', 'Cash', 50.00, '2026-10-03T09:35:00', 'Paid'),
    ('PAY0002', 'PCL0002', 'PromptPay', 75.00, '2026-10-03T10:20:00', 'Paid'),
    ('PAY0003', 'PCL0003', NULL, 80.00, NULL, 'Pending');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.TrackingHistory WHERE ParcelID = 'PCL0001' AND StatusID = 2)
BEGIN
    INSERT dbo.TrackingHistory (ParcelID, EmployeeID, StatusID, UpdateDate, Note) VALUES
    ('PCL0001', 'EMP002', 2, '2026-10-03T12:00:00', N'ออกจากศูนย์คัดแยก'),
    ('PCL0001', 'EMP002', 3, '2026-10-03T15:30:00', N'ส่งถึงผู้รับแล้ว'),
    ('PCL0002', 'EMP002', 2, '2026-10-03T13:10:00', N'กำลังนำจ่าย'),
    ('PCL0003', 'EMP002', 2, '2026-10-03T14:05:00', N'ออกนำจ่าย'),
    ('PCL0003', 'EMP002', 4, '2026-10-03T17:20:00', N'ไม่พบผู้รับ ติดต่อเพื่อนัดหมายอีกครั้ง');
END;
GO

PRINT N'Example records are ready. Run 07_TestQuery.sql to review them.';
GO
