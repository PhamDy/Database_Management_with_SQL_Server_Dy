-- CREATE AND RESET DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot7_Assignment_MSSQL_2')
DROP DATABASE Slot7_Assignment_MSSQL_2
GO
CREATE DATABASE Slot7_Assignment_MSSQL_2
GO
USE Slot7_Assignment_MSSQL_2
GO

-- 2) CREATE TABLE
-- TABLE Suppliers
CREATE TABLE Suppliers (
	Supplier_ID INT NOT NULL UNIQUE,
	Company_name NVARCHAR(50) NOT NULL,
	Address NVARCHAR(255) NOT NULL,
	Phone NVARCHAR(20) NOT NULL,
	PRIMARY KEY (Supplier_ID)
);

-- TABLE Products
CREATE TABLE Products (
	Product_ID INT NOT NULL UNIQUE,
	Supplier_ID INT NOT NULL,
	Product_name NVARCHAR(200) NOT NULL,
	Description NVARCHAR(500) NOT NULL,
	Unit NVARCHAR(20) NOT NULL,
	UnitPrice MONEY NOT NULL,
	Quantity INT NOT NULL,
	PRIMARY KEY (Product_ID),
	CONSTRAINT Supplier_ID_FK FOREIGN KEY(Supplier_ID) REFERENCES Suppliers(Supplier_ID)
);

-- 3) INSERT INTO
--Suppliers
INSERT INTO Suppliers (Supplier_ID, Company_name, Address, Phone)
	VALUES (123, 'Asus', 'USA', '983232');

--Products
INSERT INTO Products (Product_ID, Supplier_ID, Product_name, Description, Unit, UnitPrice, Quantity)
	VALUES  (1, 123, 'Máy Tính T450', 'Máy nhập cũ', 'Chiếc', 1000, 10),
			(2, 123, 'Điện Thoại Nokia5670', 'Điện Thoại đang hot', 'Chiếc', 200, 200),
			(3, 123, 'Máy In Samsung 450', 'Máy in đang loại bình', 'Chiếc', 100, 10);

-- 4) Viết các câu lênh truy vấn để
--a) Hiển thị tất cả các hãng sản xuất.
SELECT *
FROM Suppliers;

--b) Hiển thị tất cả các sản phẩm.
SELECT *
FROM Products;

-- 5) Viết các câu lệnh truy vấn để
--a) Liệt kê danh sách hãng theo thứ thự ngược với alphabet của tên.
SELECT Company_name
FROM Suppliers s
ORDER BY Company_name DESC;

--b) Liệt kê danh sách sản phẩm của cửa hàng theo thứ thự giá giảm dần.
SELECT *
FROM Products p
ORDER BY Product_ID DESC;

--c) Hiển thị thông tin của hãng Asus.
SELECT *
FROM Suppliers s
WHERE S.Company_name = 'Asus';

--d) Liệt kê danh sách sản phẩm còn ít hơn 11 chiếc trong kho.
SELECT *
FROM 
WHERE p.Quantity < 11;

--e) Liệt kê danh sách sản phẩm của hãng Asus.
SELECT p.*
FROM  
INNER JOIN Suppliers s ON S.Supplier_ID = p.Supplier_ID
WHERE s.Company_name = 'Asus';

-- 6) Viết các câu lệnh truy vấn để lấy
--a) Số hãng sản phẩm mà cửa hàng có.
SELECT COUNT(DISTINCT Supplier_ID) AS TotalCategories
FROM Products;

--b) Số mặt hàng mà cửa hàng bán.
SELECT COUNT(Product_ID) AS TotalProduct
FROM Products;

--c) Tổng số loại sản phẩm của mỗi hãng có trong cửa hàng.
SELECT s.Company_name, COUNT(*) AS TotalProductCategories
FROM Suppliers s
JOIN Products p ON s.Supplier_ID = p.Supplier_ID
GROUP BY s.Company_name;

--d) Tổng số đầu sản phẩm của toàn cửa hàng
SELECT SUM(Quantity) AS TotalProduct
FROM Products

-- 7) Thay đổi những thay đổi sau trên cơ sở dữ liệu
--a) Viết câu lệnh để thay đổi trường giá tiền của từng mặt hàng là dương(>0).
UPDATE Products
SET UnitPrice = ABS(UnitPrice)
WHERE UnitPrice < 0;

--b) Viết câu lệnh để thay đổi số điện thoại phải bắt đầu bằng 0.
UPDATE Suppliers
SET Phone = '0' + RIGHT(Phone, LEN(Phone))
WHERE LEFT(Phone,1) != '0';

--TEST
SELECT * FROM Suppliers

--c) Viết các câu lệnh để xác định các khóa ngoại và khóa chính của các bảng

-- Xem thông tin các khóa chính của bảng Suppliers
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Suppliers' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa chính của bảng Products
SELECT COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Products' AND CONSTRAINT_NAME LIKE 'PK_%';

-- Xem thông tin các khóa ngoại của bảng Products
SELECT CONSTRAINT_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'Products' AND CONSTRAINT_NAME = 'Supplier_ID_FK';

-- 8) Thực hiện các yêu cầu sau
--a) Thiết lập chỉ mục (Index) cho các cột sau: Tên hàng và Mô tả hàng để tăng hiệu suất truy vấn dữ liệu từ 2 cột này
CREATE INDEX idx_pName_pDesc
ON Products (Product_name, Description);

--b) Viết các View sau:
-- View_SanPham: với các cột Mã sản phẩm, Tên sản phẩm, Giá bán
CREATE VIEW View_SanPham AS
SELECT p.Product_ID, p.Product_name, p.UnitPrice
FROM Products p;

SELECT * FROM View_SanPham;

-- View_SanPham_Hang: với các cột Mã SP, Tên sản phẩm, Hãng sản xuất
CREATE VIEW View_SanPham_Hang AS
SELECT p.Product_ID, p.Product_name, p.UnitPrice, s.Company_name
FROM Products p
INNER JOIN Suppliers s ON p.Supplier_ID = s.Supplier_ID;

SELECT * FROM View_SanPham_Hang;

--c) Viết các Store Procedure sau:
-- SP_SanPham_TenHang: Liệt kê các sản phẩm với tên hãng truyền vào store
CREATE PROCEDURE SP_SanPham_TenHang
@Company_name NVARCHAR(50)
AS
BEGIN
	SELECT p.*
	FROM Products p
	INNER JOIN Suppliers s ON p.Supplier_ID = s.Supplier_ID
	WHERE @Company_name = s.Company_name
END;
-- RUN
EXEC SP_SanPham_TenHang @Company_name = 'Asus';

-- SP_SanPham_Gia: Liệt kê các sản phẩm có giá bán lớn hơn hoặc bằng giá bán truyền vào
CREATE PROCEDURE SP_SanPham_Gia
@UnitPrice MONEY
AS
BEGIN
	SELECT p.Product_name
	FROM Products p
	WHERE p.UnitPrice >= @UnitPrice;
END;
-- RUN
EXEC SP_SanPham_Gia @UnitPrice = 500;

-- SP_SanPham_HetHang: Liệt kê các sản phẩm đã hết hàng (số lượng = 0)
CREATE PROCEDURE SP_SanPham_HetHang
AS
BEGIN
	SELECT p.*
	FROM Products p
	WHERE p.Quantity = 0;
END;

-- RUN
EXEC SP_SanPham_HetHang;

--d) Viết Trigger sau:
-- TG_Xoa_Hang: Ngăn không cho xóa hãng
CREATE TRIGGER TG_Xoa_Hang
ON Suppliers AFTER DELETE
AS
	BEGIN
		RAISERROR('It is not allowed to delete the company', 16, 1)
		ROLLBACK TRANSACTION
	END;

-- TEST TRIGGER TG_Xoa_Hang
DELETE FROM Products WHERE Supplier_ID = 123;
DELETE FROM Suppliers WHERE Supplier_ID = 123;
SELECT *  FROM Suppliers
SELECT *  FROM Products

-- TG_Xoa_SanPham: Chỉ cho phép xóa các sản phẩm đã hết hàng (số lượng = 0)
CREATE TRIGGER TG_Xoa_SanPham
ON Products AFTER DELETE
AS
	BEGIN
		IF EXISTS(SELECT * FROM deleted WHERE Quantity !=0)
		BEGIN
			RAISERROR('Only products that are out of stock are allowed to be deleted.', 16, 1)
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			DELETE FROM Products 
			WHERE Product_ID IN (SELECT Product_ID FROM deleted);
		END
	END;
-- TEST TRIGGER TG_Xoa_SanPham
UPDATE Products
SET Quantity = 0
WHERE Product_ID = 2;

DELETE FROM Products WHERE Product_ID = 1;
DELETE FROM Products WHERE Product_ID = 2;
DELETE FROM Products WHERE Product_ID = 3;

SELECT * FROM Products;

