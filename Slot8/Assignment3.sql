-- CREATE AND RESET: DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot8_Assignment_03')
DROP DATABASE Slot8_Assignment_03
GO
CREATE DATABASE Slot8_Assignment_03
GO
USE Slot8_Assignment_03
GO

-- 2) CREATE TABLE
-- TABLE Customers
CREATE TABLE Customers (
	Customer_ID INT NOT NULL UNIQUE,
	Customer_name NVARCHAR(50) NOT NULL,
	ID_CardNumber INT NOT NULL,
	Address NVARCHAR(255) NOT NULL,
	PRIMARY KEY (Customer_ID)
);

-- TABLE Phone_numbers
CREATE TABLE Phone_numbers (
	PhoneNumber_ID INT NOT NULL UNIQUE,
	Customer_ID INT NOT NULL,
	Numbers NVARCHAR(20) NOT NULL,
	Subscriber_type NVARCHAR(255) NOT NULL,
	Registration_Date DATE NOT NULL,
	PRIMARY KEY (PhoneNumber_ID),
	CONSTRAINT Customer_ID_FK FOREIGN KEY(Customer_ID) REFERENCES Customers(Customer_ID)
);

-- 3) INSERT INTO DATA
-- INSERT INTO TABLE Customers
INSERT INTO Customers (Customer_ID, Customer_name, ID_CardNumber, Address)
	VALUES (1, 'Nguyễn Nguyệt Nga', 123456789, 'Hà Nội');

-- INSERT INTO TABLE Phone_numbers
INSERT INTO Phone_numbers (PhoneNumber_ID, Customer_ID, Numbers, Subscriber_type, Registration_Date)
	VALUES (1, 1, '123456789', 'Trả trước', '2002-12-12');

-- 4) Viết các câu lênh truy vấn để
--a) Hiển thị toàn bộ thông tin của các khách hàng của công ty.
SELECT * FROM Customers;

--b) Hiển thị toàn bộ thông tin của các số thuê bao của công ty.
SELECT * FROM Phone_numbers;

-- 5) Viết các câu lệnh truy vấn để lấy
--a) Hiển thị toàn bộ thông tin của thuê bao có số: 0123456789
SELECT c.*
FROM Customers c
INNER JOIN Phone_numbers pn ON pn.Customer_ID = c.Customer_ID
WHERE pn.Numbers = '123456789';

--b) Hiển thị thông tin về khách hàng có số CMTND: 123456789
SELECT *
FROM Customers c
WHERE c.ID_CardNumber = 123456789;

--c) Hiển thị các số thuê bao của khách hàng có số CMTND:123456789
SELECT c.Customer_name, pn.Numbers, c.ID_CardNumber
FROM Phone_numbers pn
INNER JOIN Customers c ON c.Customer_ID = pn.PhoneNumber_ID
WHERE c.ID_CardNumber = 123456789;

--d) Liệt kê các thuê bao đăng ký vào ngày 12/12/09
SELECT *
FROM Phone_numbers pn
WHERE pn.Registration_Date = '2009-12-12';

--e) Liệt kê các thuê bao có địa chỉ tại Hà Nội
SELECT pn.*
FROM Phone_numbers pn
INNER JOIN Customers c ON c.Customer_ID = pn.Customer_ID
WHERE c.Address = 'Hà Nội';

-- 6) Viết các câu lệnh truy vấn để lấy
--a) Tổng số khách hàng của công ty.
SELECT COUNT(c.Customer_ID) AS TotalCustomer
FROM Customers c;

--b) Tổng số thuê bao của công ty.
SELECT COUNT(pn.PhoneNumber_ID) AS TotalPhoneNumber
FROM Phone_numbers pn;

--c) Tổng số thuê bào đăng ký ngày 12/12/09.
SELECT COUNT(pn.PhoneNumber_ID) AS TotalPhoneNumber
FROM Phone_numbers pn
WHERE pn.Registration_Date = '2009-12-12';

--d) Hiển thị toàn bộ thông tin về khách hàng và thuê bao của tất cả các số thuê bao.
SELECT *
FROM Customers c
INNER JOIN Phone_numbers pn ON pn.Customer_ID = c.Customer_ID;

--7) Thay đổi những thay đổi sau trên cơ sở dữ liệu
--a) Viết câu lệnh để thay đổi trường ngày đăng ký là not null.
ALTER TABLE Phone_numbers
ALTER COLUMN Registration_Date DATE NOT NULL;

--b) Viết câu lệnh để thay đổi trường ngày đăng ký là trước hoặc bằng ngày hiện tại.
ALTER TABLE Phone_numbers
ADD CONSTRAINT Check_Registration_Date
CHECK (Registration_Date <= GETDATE());

--c) Viết câu lệnh để thay đổi số điện thoại phải bắt đầu 09
UPDATE Phone_numbers
SET Numbers = '09' + RIGHT(Numbers, LEN(Numbers) - 2)
WHERE LEFT(Numbers, 2) != '09';

-- Test
SELECT * FROM Phone_numbers;

--d) Viết câu lệnh để thêm trường số điểm thưởng cho mỗi số thuê bao.

ALTER TABLE Phone_numbers
ADD RewardPoints INT DEFAULT 0;

UPDATE Phone_numbers
SET RewardPoints = 1;
 
--8. Thực hiện các yêu cầu sau
--a) Đặt chỉ mục (Index) cho cột Tên khách hàng của bảng chứa thông tin khách hàng
CREATE INDEX idx_Customer_name
ON Customers (Customer_name);

--b) Viết các View sau:
-- View_KhachHang: Hiển thị các thông tin Mã khách hàng, Tên khách hàng, địa chỉ
CREATE VIEW View_KhachHang AS
SELECT c.Customer_ID, c.Customer_name, c.Address
FROM Customers c;

SELECT * FROM View_KhachHang;

-- View_KhachHang_ThueBao: Hiển thị thông tin Mã khách hàng, Tên khách hàng, Số thuê bao
CREATE VIEW View_KhachHang_ThueBao AS
SELECT c.Customer_ID, c.Customer_name, pn.Numbers
FROM Customers c
INNER JOIN Phone_numbers pn ON pn.Customer_ID = c.Customer_ID;

SELECT * FROM View_KhachHang_ThueBao;

--c) Viết các Store Procedure sau:
-- SP_TimKH_ThueBao: Hiển thị thông tin của khách hàng với số thuê bao nhập vào
CREATE PROCEDURE SP_TimKH_ThueBao 
	@SoTB NVARCHAR(20) 
AS 
BEGIN
	SELECT c.*
	FROM Customers c
	INNER JOIN Phone_numbers pn ON c.Customer_ID = pn.PhoneNumber_ID
	WHERE @SoTB = pn.Numbers
END;

EXEC SP_TimKH_ThueBao @SoTB = '093456789';

-- SP_TimTB_KhachHang: Liệt kê các số điện thoại của khách hàng theo tên truyền vào
CREATE PROCEDURE SP_TimTB_KhachHang
	@Cus_name NVARCHAR(50)
AS
BEGIN
	SELECT pn.Numbers
	FROM Phone_numbers pn
	INNER JOIN Customers c ON c.Customer_ID = pn.Customer_ID
	WHERE @Cus_name = c.Customer_name
END;

EXEC SP_TimTB_KhachHang @Cus_name = 'Nguyễn Nguyệt Nga';

-- SP_ThemTB: Thêm mới một thuê bao cho khách hàng
CREATE PROCEDURE SP_ThemTB
	@PhoneNumber_ID INT,
	@Customer_ID INT,
	@Numbers NVARCHAR(20),
	@Subscriber_type NVARCHAR(255),
	@Registration_Date DATE
AS
BEGIN
	IF EXISTS ( SELECT * FROM Phone_numbers WHERE Customer_ID LIKE @Customer_ID)
		INSERT INTO Phone_numbers
			VALUES (@PhoneNumber_ID, @Customer_ID, @Numbers, @Subscriber_type, @Registration_Date);
	ELSE
	BEGIN
		PRINT 'CANNOT ADD A Subscriber NUMBER';
	END
END;

--RUN
EXEC SP_ThemTB 2, 1, '0123456', 'aasd', '2023-6-10';

SELECT * FROM Phone_numbers;

-- SP_HuyTB_MaKH: Xóa bỏ thuê bao của khách hàng theo Mã khách hàng
CREATE PROCEDURE SP_HuyTB_MaKH
	@MaKH INT
AS
BEGIN
	DELETE FROM Phone_numbers
	WHERE Customer_ID = @MaKH;
END;

EXEC SP_HuyTB_MaKH @MaKH = 1;
-- Test
SELECT * FROM Phone_numbers;



