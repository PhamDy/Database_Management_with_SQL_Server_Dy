-- CREATE AND RESET: DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot9_Assignment_04')
DROP DATABASE Slot9_Assignment_04
GO
CREATE DATABASE Slot9_Assignment_04
GO
USE Slot9_Assignment_04
GO

-- 2) CREATE TABLE
-- TABLE ResponsiblePerson
CREATE TABLE ResponsiblePerson(
	Person_ID INT NOT NULL UNIQUE,
	Person_name NVARCHAR(50) NOT NULL,
	PRIMARY KEY(Person_ID)
);

-- TABLE Categories
CREATE TABLE Categories(
	Categori_ID NVARCHAR(20) NOT NULL UNIQUE,
	Categori_name NVARCHAR(50) NOT NULL,
	PRIMARY KEY(Categori_ID)
);

-- TABLE Products
CREATE TABLE Products(
	Product_ID NVARCHAR(20) NOT NULL UNIQUE,
	Person_ID INT NOT NULL,
	Categori_ID NVARCHAR(20) NOT NULL,
	Product_name NVARCHAR(50),
	Product_date DATE NOT NULL,
	PRIMARY KEY(Product_ID),
	CONSTRAINT Person_ID_FK FOREIGN KEY(Person_ID) REFERENCES ResponsiblePerson(Person_ID),
	CONSTRAINT Categori_ID_FK FOREIGN KEY(Categori_ID) REFERENCES Categories(Categori_ID)
);

-- 3) INSERT INTO
--ResponsiblePerson
INSERT INTO ResponsiblePerson(Person_ID, Person_name)
	VALUES (987688, 'Nguyễn Văn An');

--Categories
INSERT INTO Categories(Categori_ID, Categori_name)
	VALUES ('Z37E', 'Máy tính sách tay Z37');

--Products
INSERT INTO Products(Product_ID, Person_ID, Categori_ID, Product_date)
	VALUES ('Z37 111111', 987688, 'Z37E', '2009-12-12');

-- 4. Viết các câu lênh truy vấn để
--a) Liệt kê danh sách loại sản phẩm của công ty.
SELECT * FROM Categories;
--b) Liệt kê danh sách sản phẩm của công ty.
SELECT * FROM Products;
--c) Liệt kê danh sách người chịu trách nhiệm của công ty.
SELECT * FROM ResponsiblePerson;

-- 5. Viết các câu lệnh truy vấn để lấy
--a) Liệt kê danh sách loại sản phẩm của công ty theo thứ tự tăng dần của tên
SELECT * FROM Categories
ORDER BY Categori_name ASC;

--b) Liệt kê danh sách người chịu trách nhiệm của công ty theo thứ tự tăng dần của tên.
SELECT * FROM ResponsiblePerson
ORDER BY Person_name ASC;

--c) Liệt kê các sản phẩm của loại sản phẩm có mã số là Z37E.
SELECT * FROM Products 
WHERE Categori_ID = 'Z37E';

--d) Liệt kê các sản phẩm Nguyễn Văn An chịu trách nhiệm theo thứ tự giảm đần của mã.
SELECT *
FROM Products WHERE Person_ID = (SELECT Person_ID FROM ResponsiblePerson WHERE Person_name = 'Nguyễn Văn An')
ORDER BY Product_ID DESC;

-- 6. Viết các câu lệnh truy vấn để
--a) Số sản phẩm của từng loại sản phẩm.
SELECT c.Categori_name, COUNT(*) AS TotalProduct
FROM Products p
INNER JOIN Categories c ON p.Categori_ID = c.Categori_ID
GROUP BY c.Categori_name;

--b) Số loại sản phẩm trung bình theo loại sản phẩm.
SELECT AVG(CountPerCategory) AS Average_Category_Count
FROM (
    SELECT Categori_ID, COUNT(*) AS CountPerCategory
    FROM Products
    GROUP BY Categori_ID
) AS Subquery;

--c) Hiển thị toàn bộ thông tin về sản phẩm và loại sản phẩm.
SELECT *
FROM Products p
FULL JOIN Categories c ON p.Categori_ID = c.Categori_ID;

--d) Hiển thị toàn bộ thông tin về người chịu trách nhiêm, loại sản phẩm và sản phẩm.
SELECT *
FROM Products p
FULL JOIN Categories c ON p.Categori_ID = c.Categori_ID
FULL JOIN ResponsiblePerson rb ON rb.Person_ID = p.Person_ID;

-- 7. Thay đổi những thứ sau từ cơ sở dữ liệu
--a) Viết câu lệnh để thay đổi trường ngày sản xuất là trước hoặc bằng ngày hiện tại.
UPDATE Products 
SET Product_date = DATEADD(day, -1, GETDATE()) 
WHERE Product_date > GETDATE();

--b) Viết câu lệnh để xác định các trường khóa chính và khóa ngoại của các bảng.
-- Xem thông tin các khóa chính của bảng ResponsiblePerson
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'ResponsiblePerson' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa chính của bảng Categories
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Categories' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa chính của bảng Products
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Products' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa ngoại của bảng Products
SELECT CONSTRAINT_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Products' AND CONSTRAINT_NAME LIKE '%FK';

--c) Viết câu lệnh để thêm trường phiên bản của sản phẩm.
ALTER TABLE Products
ADD version NVARCHAR(50);
SELECT * FROM Products;

--8. Thực hiện các yêu cầu sau
--a) Đặt chỉ mục (index) cho cột tên người chịu trách nhiệm
CREATE INDEX idx_personName
ON ResponsiblePerson(Person_name);

--b) Viết các View sau:
--◦ View_SanPham: Hiển thị các thông tin Mã sản phẩm, Ngày sản xuất, Loại sản phẩm
CREATE VIEW View_SanPham AS
SELECT p.Product_ID, p.Product_date, c.Categori_ID, c.Categori_name
FROM Products p
INNER JOIN Categories c ON p.Categori_ID = c.Categori_ID;

SELECT * FROM View_SanPham;

--◦ View_SanPham_NCTN: Hiển thị Mã sản phẩm, Ngày sản xuất, Người chịu trách nhiệm
CREATE VIEW View_SanPham_NCTN AS
SELECT p.Product_ID, p.Product_date, rb.Person_name
FROM Products p
INNER JOIN ResponsiblePerson rb ON rb.Person_ID = p.Person_ID;

SELECT * FROM View_SanPham_NCTN;

--◦ View_Top_SanPham: Hiển thị 5 sản phẩm mới nhất (mã sản phẩm, loại sản phẩm, ngày sản xuất)
CREATE VIEW View_Top_SanPham AS
SELECT TOP 5 p.Product_ID, p.Product_date, c.Categori_ID, c.Categori_name
FROM Products p
INNER JOIN Categories c ON p.Categori_ID = c.Categori_ID;

SELECT * FROM View_Top_SanPham;
--c) Viết các Store Procedure sau:
--◦ SP_Them_LoaiSP: Thêm mới một loại sản phẩm
CREATE PROCEDURE SP_Them_LoaiSP 
	@Categori_ID NVARCHAR(20),
	@Categori_name NVARCHAR(50)
AS
BEGIN
	INSERT INTO Categories(Categori_ID, Categori_name)
		VALUES (@Categori_ID, @Categori_name)
END;

EXEC SP_Them_LoaiSP 'A28B', 'Smart phone';

SELECT * FROM Categories;

--◦ SP_Them_NCTN: Thêm mới người chịu trách nhiệm
CREATE PROCEDURE SP_Them_NCTN 
	@Person_ID INT,
	@Person_name NVARCHAR(50)
AS
BEGIN
	INSERT INTO ResponsiblePerson(Person_ID , Person_name)
		VALUES (@Person_ID, @Person_name)
END;

EXEC SP_Them_NCTN 122235, 'Phạm Văn Nam';

SELECT * FROM ResponsiblePerson;

--◦ SP_Them_SanPham: Thêm mới một sản phẩm
CREATE PROCEDURE SP_Them_SanPham 
	@Product_ID NVARCHAR(20),
	@Person_ID INT,
	@Categori_ID NVARCHAR(20),
	@Product_name NVARCHAR(100),
	@Product_date DATE
AS
BEGIN
	IF EXISTS ( SELECT * FROM Products WHERE Categori_ID = @Categori_ID)
	INSERT INTO Products(Product_ID, Person_ID, Categori_ID, Product_name, Product_date)
		VALUES (@Product_ID, @Person_ID, @Categori_ID, @Product_name, @Product_date);
	ELSE
	BEGIN
		PRINT 'Khong them duoc san pham'
	END
END;
--RUN
EXEC SP_Them_SanPham '1', 987688, 'Z37E', 'Pham Van Nam', '12-06-2023';
SELECT * FROM Products;

--◦ SP_Xoa_SanPham: Xóa một sản phẩm theo mã sản phẩm
CREATE PROCEDURE SP_Xoa_SanPham 
	@Product_ID NVARCHAR(20)
AS
BEGIN
	IF EXISTS ( SELECT Product_ID FROM Products WHERE Product_ID = @Product_ID)
	DELETE FROM Products
	ELSE
	BEGIN
		PRINT 'Khong tim thay san pham hop le'
	END
END;
--RUN
EXEC SP_Xoa_SanPham '1';
SELECT * FROM Products;
--◦ SP_Xoa_SanPham_TheoLoai: Xóa các sản phẩm của một loại nào đó
CREATE PROCEDURE SP_Xoa_SanPham_TheoLoai 
	@Categori_ID NVARCHAR(20)
AS
BEGIN
	IF EXISTS ( SELECT Product_ID FROM Products WHERE Categori_ID = @Categori_ID)
	DELETE FROM Products
	ELSE
	BEGIN
		PRINT 'Khong tim thay loai san pham hop le'
	END
END;
--RUN
EXEC SP_Xoa_SanPham_TheoLoai 'Z37E';
SELECT * FROM Products;

