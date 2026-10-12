/*
  Project: Parcel Delivery Database
  Platform: Microsoft SQL Server (SSMS)
  Purpose: Demonstrate basic joins, tracking history, summary, and payment checks.
*/

USE ParcelDeliveryDB;
GO

-- 1. Parcel list with sender, receiver, type, current status, and fee.
SELECT p.TrackingNumber,
       s.CustomerName AS SenderName,
       r.CustomerName AS ReceiverName,
       t.TypeName AS ParcelType,
       ps.StatusName AS CurrentStatus,
       p.WeightKg,
       p.ShippingFee,
       p.ReceivedAt
FROM dbo.Parcel AS p
JOIN dbo.Customer AS s ON s.CustomerID = p.SenderID
JOIN dbo.Customer AS r ON r.CustomerID = p.ReceiverID
JOIN dbo.ParcelType AS t ON t.ParcelTypeID = p.ParcelTypeID
JOIN dbo.ParcelStatus AS ps ON ps.StatusID = p.CurrentStatusID
ORDER BY p.ReceivedAt, p.TrackingNumber;
GO

-- 2. Full tracking timeline for one tracking number.
DECLARE @TrackingNumber VARCHAR(20) = 'TH123456789';
SELECT p.TrackingNumber,
       h.UpdateDate,
       ps.StatusName,
       e.EmployeeName AS UpdatedBy,
       h.Note
FROM dbo.Parcel AS p
JOIN dbo.TrackingHistory AS h ON h.ParcelID = p.ParcelID
JOIN dbo.ParcelStatus AS ps ON ps.StatusID = h.StatusID
JOIN dbo.Employee AS e ON e.EmployeeID = h.EmployeeID
WHERE p.TrackingNumber = @TrackingNumber
ORDER BY h.UpdateDate, h.HistoryID;
GO

-- 3. Parcel count and total shipping fees grouped by current status.
SELECT ps.StatusName,
       COUNT(*) AS ParcelCount,
       SUM(p.ShippingFee) AS TotalShippingFee
FROM dbo.Parcel AS p
JOIN dbo.ParcelStatus AS ps ON ps.StatusID = p.CurrentStatusID
GROUP BY ps.StatusName
ORDER BY ps.StatusName;
GO

-- 4. Payments that are pending or otherwise need review.
SELECT p.TrackingNumber,
       pay.Amount,
       pay.PaymentMethod,
       pay.PaymentStatus,
       pay.PaymentDate
FROM dbo.Payment AS pay
JOIN dbo.Parcel AS p ON p.ParcelID = pay.ParcelID
WHERE pay.PaymentStatus IN ('Pending', 'Failed')
ORDER BY p.TrackingNumber;
GO

-- 5. Compare current status with the latest tracking event for consistency.
WITH LatestHistory AS (
    SELECT h.ParcelID, h.StatusID,
           ROW_NUMBER() OVER (PARTITION BY h.ParcelID ORDER BY h.UpdateDate DESC, h.HistoryID DESC) AS RowNum
    FROM dbo.TrackingHistory AS h
)
SELECT p.TrackingNumber,
       currentStatus.StatusName AS CurrentStatus,
       latestStatus.StatusName AS LatestHistoryStatus,
       CASE WHEN p.CurrentStatusID = lh.StatusID THEN N'ตรงกัน' ELSE N'ไม่ตรงกัน' END AS Consistency
FROM dbo.Parcel AS p
JOIN dbo.ParcelStatus AS currentStatus ON currentStatus.StatusID = p.CurrentStatusID
LEFT JOIN LatestHistory AS lh ON lh.ParcelID = p.ParcelID AND lh.RowNum = 1
LEFT JOIN dbo.ParcelStatus AS latestStatus ON latestStatus.StatusID = lh.StatusID
ORDER BY p.TrackingNumber;
GO
