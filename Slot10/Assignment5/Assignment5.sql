-- CREATE AND RESET: DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot10_Assignment_05')
DROP DATABASE Slot10_Assignment_05
GO
CREATE DATABASE Slot10_Assignment_05
GO
USE Slot10_Assignment_05
GO

-- 2) CREATE TABLE
-- TABLE Customers
CREATE TABLE Customers (
	Customer_ID INT IDENTITY(1,1) NOT NULL UNIQUE,
	Customer_name NVARCHAR(50) NOT NULL,
	Address NVARCHAR(255) NOT NULL,
	Birthday DATE NOT NULL,
	PRIMARY KEY (Customer_ID)
);

-- TABLE PhoneNumbers
CREATE TABLE PhoneNumbers (
	Phone_ID INT IDENTITY(1,1) NOT NULL UNIQUE,
	Customer_ID INT NOT NULL,
	Numbers INT NOT NULL,
	PRIMARY KEY (Phone_ID),
	CONSTRAINT Customer_ID_FK FOREIGN KEY(Customer_ID) REFERENCES Customers(Customer_ID)
);
-- 3) INSERT INTO
--Customers
INSERT INTO Customers
	VALUES ('Nguyễn Văn An', '111 Nguyễn Trãi, Thanh Xuân, Hà Nội', '1987-11-18');
SELECT * FROM Customers;

--PhoneNumbers
INSERT INTO PhoneNumbers
	VALUES  (1, 987654321),
			(1, 09873452),
			(1, 09832323),
			(1, 09434343);
SELECT * FROM PhoneNumbers;

--4. Viết các câu lênh truy vấn để
--a) Liệt kê danh sách những người trong danh bạ
SELECT * FROM Customers;
--b) Liệt kê danh sách số điện thoại có trong danh bạ
SELECT * FROM PhoneNumbers;

--5. Viết các câu lệnh truy vấn để lấy
--a) Liệt kê danh sách người trong danh bạ theo thứ thự alphabet.
SELECT * FROM Customers
ORDER BY Customer_name ASC;
--b) Liệt kê các số điện thoại của người có tên là Nguyễn Văn An.
SELECT pn.* 
FROM PhoneNumbers pn
INNER JOIN Customers c ON c.Customer_ID = pn.Customer_ID
WHERE c.Customer_name = 'Nguyễn Văn An';

--c) Liệt kê những người có ngày sinh là 12/12/09
SELECT * 
FROM Customers
WHERE Birthday = '12-12-2009';

--6. Viết các câu lệnh truy vấn để
--a) Tìm số lượng số điện thoại của mỗi người trong danh bạ.
SELECT c.Customer_name, COUNT(pn.Phone_ID) AS TotalPhoneNumbers
FROM PhoneNumbers pn
INNER JOIN Customers c ON c.Customer_ID = pn.Customer_ID
GROUP BY c.Customer_name;

--b) Tìm tổng số người trong danh bạ sinh vào thang 12.
SELECT COUNT(*) AS TotalBirthday12
FROM Customers
WHERE MONTH(Birthday) = 12;

--c) Hiển thị toàn bộ thông tin về người, của từng số điện thoại.
SELECT * 
FROM PhoneNumbers pn
FULL JOIN Customers c ON c.Customer_ID = pn.Customer_ID;

--d) Hiển thị toàn bộ thông tin về người, của số điện thoại 123456789.
SELECT c.*
FROM PhoneNumbers pn
INNER JOIN Customers c ON c.Customer_ID = pn.Customer_ID
WHERE pn.Numbers = 123456789;

--7. Thay đổi những thứ sau từ cơ sở dữ liệu
--a) Viết câu lệnh để thay đổi trường ngày sinh là trước ngày hiện tại.
UPDATE Customers
SET Birthday = DATEADD(day, -1, GETDATE())
WHERE Birthday > GETDATE();

--b) Viết câu lệnh để xác định các trường khóa chính và khóa ngoại của các bảng.
-- Xem thông tin các khóa chính của bảng Customers
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Customers' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa chính của bảng PhoneNumbers
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'PhoneNumbers' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa ngoại của bảng PhoneNumbers
SELECT CONSTRAINT_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'PhoneNumbers' AND CONSTRAINT_NAME LIKE '%FK';

--c) Viết câu lệnh để thêm trường ngày bắt đầu liên lạc
ALTER TABLE Customers
ADD StartDate DATE;
SELECT * FROM Customers;

--8. Thực hiện các yêu cầu sau
--a) Thực hiện các chỉ mục sau(Index)
--◦ IX_HoTen : đặt chỉ mục cho cột Họ và tên
CREATE INDEX IX_HoTen
ON Customers (Customer_name);

--◦ IX_SoDienThoai: đặt chỉ mục cho cột Số điện thoại
CREATE INDEX IX_SoDienThoai
ON PhoneNumbers (Numbers);

--b) Viết các View sau:
--◦ View_SoDienThoai: hiển thị các thông tin gồm Họ tên, Số điện thoại
CREATE VIEW View_SoDienThoai AS
SELECT c.Customer_name, pn.Numbers
FROM Customers c
INNER JOIN PhoneNumbers pn ON c.Customer_ID = pn.Customer_ID;
--RUN
SELECT * FROM View_SoDienThoai;

--◦ View_SinhNhat: Hiển thị những người có sinh nhật trong tháng hiện tại (Họ tên, Ngày sinh, Số điện thoại)
CREATE VIEW View_SinhNhat AS
SELECT c.Customer_name, c.Birthday ,pn.Numbers
FROM Customers c
INNER JOIN PhoneNumbers pn ON c.Customer_ID = pn.Customer_ID
WHERE MONTH(Birthday) = GETDATE();
--RUN
SELECT * FROM View_SinhNhat;

--c) Viết các Store Procedure sau:
--◦ SP_Them_DanhBa: Thêm một người mới vào danh bạ
CREATE Procedure SP_Them_DanhBa
	@Customer_name NVARCHAR(50),
	@Address NVARCHAR(255),
	@Birthday DATE
AS
BEGIN
	INSERT INTO Customers(Customer_name, Address, Birthday)
		VALUES (@Customer_name, @Address, @Birthday)
	BEGIN
	PRINT 'ADD NEW SUCCESS';
	END
END;

--RUN
EXEC SP_Them_DanhBa 'Phạm Văn Nam', '8A Tôn Thất Thuyết, Cầu Giấy, Hà Nội', '2002-5-9';
EXEC SP_Them_DanhBa 'Phạm Bao Cuong', 'Đống Đa, Hà Nội', '2002-5-9';
EXEC SP_Them_DanhBa 'Phạm Văn Nam', '8A Tôn Thất Thuyết, Cầu Giấy, Hà Nội', '2002-5-9';
SELECT * FROM Customers;

--◦ SP_Tim_DanhBa: Tìm thông tin liên hệ của một người theo tên (gần đúng)
CREATE Procedure SP_Tim_DanhBa
	@Customer_name NVARCHAR(50)
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM Customers
		WHERE Customer_name LIKE '%' + @Customer_name + '%'
	)
	BEGIN
		SELECT *
		FROM Customers
		WHERE Customer_name LIKE '%' + @Customer_name + '%';
	END
	ELSE
	BEGIN
		PRINT 'Không tìm được tên nào phù hợp'
	END
END;
--TEST
SELECT * FROM Customers;
EXEC SP_Tim_DanhBa 'AN';
EXEC SP_Tim_DanhBa 'NAM';
EXEC SP_Tim_DanhBa 'TRẦN';
EXEC SP_Tim_DanhBa 'PHẠM';