-- EDIT DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot6_Assignment_MSSQL_1')
DROP DATABASE Slot6_Assignment_MSSQL_1
GO
-- CREATE DATABASE
CREATE DATABASE Slot6_Assignment_MSSQL_1
GO
USE Slot6_Assignment_MSSQL_1
GO
-- 2) CREATE TABLE
-- TABLE Customers
CREATE TABLE Customers (
	Customer_ID INT NOT NULL UNIQUE,
	Phone VARCHAR(20) NOT NULL,
	Customer_name NVARCHAR(50) NOT NULL,
	Address NVARCHAR(255) NOT NULL,
	PRIMARY KEY (Customer_ID)
);

-- TABLE Orders
CREATE TABLE Orders (
	Order_ID INT NOT NULL UNIQUE,
	Customer_ID INT NOT NULL,
	Order_Date DATE NOT NULL,
	PRIMARY KEY (Order_ID),
	CONSTRAINT FK_Customer_ID FOREIGN KEY(Customer_ID) REFERENCES Customers(Customer_ID)
);

-- TABLE Products
CREATE TABLE Products (
	Product_ID INT NOT NULL UNIQUE,
	Product_name NVARCHAR(50) NOT NULL,
	UnitPrice MONEY NOT NULL,
	Unit NVARCHAR(20) NOT NULL,
	Description NVARCHAR(500) NOT NULL,
	PRIMARY KEY (Product_ID)
);

-- TABLE Orders Details
CREATE TABLE OrderDetails (
	Order_ID INT NOT NULL,
	Product_ID INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	Quantity INT NOT NULL,
	PRIMARY KEY (Order_ID, Product_ID),
	CONSTRAINT Order_ID FOREIGN KEY(Order_ID) REFERENCES Orders(Order_ID),
	CONSTRAINT FK_Product_ID FOREIGN KEY(Product_ID) REFERENCES Products(Product_ID)
);
-- 3) INSERT INTO
--Customers
INSERT INTO Customers(Customer_ID, Phone, Customer_name, Address)
	VALUES (1, '987654321', 'Nguyễn Văn An', '111 Nguyễn Trãi, Thanh Xuân, Hà Nội');

-- Orders
INSERT INTO Orders(Order_ID, Customer_ID, Order_Date)
	VALUES (123, 1, '2009-11-18');

-- Products
INSERT INTO Products(Product_ID, Product_name, UnitPrice, Unit, Description)
	VALUES  (1, 'Máy Tính T450', 1000, 'Chiếc', 'Máy nhập mới'),
			(2, 'Điện Thoại Nokia5670', 200, 'Chiếc', 'Điện thoại đang hot'),
			(3, ' Máy In Samsung 450', 100, 'Chiếc', 'Máy in đang ế');

-- OrderDetails
INSERT INTO OrderDetails (Order_ID, Product_ID, UnitPrice, Quantity)
	VALUES  (123, 1, 1000, 1),	
			(123, 2, 200, 2),
			(123, 3, 100, 1);
-- 4. Viết các câu lênh truy vấn để
--a) Liệt kê danh sách khách hàng đã mua hàng ở cửa hàng.
SELECT o.Order_ID, c.Customer_ID, c.Customer_name, c.Phone, c.Address
FROM Customers c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID;

--b) Liệt kê danh sách sản phẩm của của hàng.
SELECT *
FROM Products 

--c) Liệt kê danh sách các đơn đặt hàng của cửa hàng.
SELECT *
FROM Orders 

-- 5. Viết các câu lệnh truy vấn để
--a) Liệt kê danh sách khách hàng theo thứ thự alphabet.
SELECT Customers.Customer_name
FROM Customers
ORDER BY Customers.Customer_name ASC;

--b) Liệt kê danh sách sản phẩm của cửa hàng theo thứ thự giá giảm dần.
SELECT p.Product_ID, p.Product_name, p.Unit, p.UnitPrice
FROM Products p
ORDER BY p.Product_ID DESC;

--c) Liệt kê các sản phẩm mà khách hàng Nguyễn Văn An đã mua.
SELECT p.Product_ID, c.Customer_name, p.Product_name, p.Unit, p.UnitPrice, p.Description
FROM Products p
INNER JOIN OrderDetails od ON p.Product_ID = od.Product_ID 
INNER JOIN Orders o ON o.Order_ID = od.Order_ID
INNER JOIN Customers c ON c.Customer_ID = o.Customer_ID
WHERE C.Customer_name = 'Nguyễn Văn An';

-- 6. Viết các câu lệnh truy vấn để
--a) Số khách hàng đã mua ở cửa hàng.
SELECT COUNT(DISTINCT o.Customer_ID) AS TotalCustomer
FROM Orders o

--b) Số mặt hàng mà cửa hàng bán.
SELECT COUNT(DISTINCT p.Product_ID) AS TotalProducts
FROM Products p;

--c) Tổng tiền của từng đơn hàng.
SELECT p.Product_ID AS STT, p.Product_name, p.Description, p.Unit, p.UnitPrice, od.Quantity, (p.UnitPrice*od.Quantity) AS AMOUNT
FROM OrderDetails od
INNER JOIN Products p ON p.Product_ID = od.Product_ID;

-- 7. Thay đổi những thông tin sau từ cơ sở dữ liệu
--a) Viết câu lệnh để thay đổi trường giá tiền của từng mặt hàng là dương(>0).
UPDATE Products
SET UnitPrice = ABS(UnitPrice)
WHERE UnitPrice < 0;

--b) Viết câu lệnh để thay đổi ngày đặt hàng của khách hàng phải nhỏ hơn ngày hiện tại.
UPDATE Orders
SET Order_Date = DATEADD(day, -1, GETDATE())
WHERE Order_Date > GETDATE();

--c) Viết câu lệnh để thêm trường ngày xuất hiện trên thị trường của sản phẩm.
ALTER TABLE Products
ADD MarketDate DATE; 

-- 8. Thực hiện các yêu cầu sau
--a) Đặt chỉ mục (index) cho cột Tên hàng và Người đặt hàng để tăng tốc độ truy vấn dữ liệu trên các cột này
CREATE INDEX idx_Product_name
ON Products (Product_name);

CREATE INDEX idx_Customer_name
ON Customers (Customer_name);

--b) Xây dựng các view sau đây:
-- View_KhachHang với các cột: Tên khách hàng, Địa chỉ, Điện thoại.
CREATE VIEW View_KhachHang AS
SELECT c.Customer_name, c.Address, c.Phone
FROM Customers c;

SELECT * FROM View_KhachHang;

-- View_SanPham với các cột: Tên sản phẩm, Giá bán.
CREATE VIEW View_SanPham AS
SELECT p.Product_name, p.UnitPrice
FROM Products p;

SELECT * FROM View_SanPham;

-- View_KhachHang_SanPham với các cột: Tên khách hàng, Số điện thoại, Tên sản phẩm, Số lượng, Ngày mua.
CREATE VIEW View_KhachHang_SanPham AS
SELECT c.Customer_name, c.Phone, p.Product_name, od.Quantity, o.Order_Date
FROM Customers c
INNER JOIN Orders o ON c.Customer_ID = o.Customer_ID
INNER JOIN OrderDetails od ON o.Order_ID = od.Order_ID
INNER JOIN Products p ON od.Product_ID = p.Product_ID;

SELECT * FROM View_KhachHang_SanPham;

--c) Viết các Store Procedure (Thủ tục lưu trữ) sau:
-- SP_TimKH_MaKH: Tìm khách hàng theo mã khách hàng
CREATE PROCEDURE SP_TimKH_MaKH
    @MaKH INT
AS
BEGIN
    SELECT *
    FROM Customers
    WHERE Customer_ID = @MaKH;
END;

EXEC SP_TimKH_MaKH @MaKH = 1;

-- SP_TimKH_MaHD: Tìm thông tin khách hàng theo mã hóa đơn
CREATE PROCEDURE SP_TimKH_MaHD
	@MaHD INT
AS
BEGIN
	SELECT c.*
	FROM Customers c
	INNER JOIN Orders o ON o.Customer_ID = c.Customer_ID
	WHERE  o.Order_ID = @MaHD;
END;

EXEC SP_TimKH_MaHD @MaHD = 123;

-- SP_SanPham_MaKH: Liệt kê các sản phẩm được mua bởi khách hàng có mã được truyền vào Store.
CREATE PROCEDURE SP_SanPham_MaKH
	@MaKH INT
AS
BEGIN
	SELECT p.*
	FROM Products p
	INNER JOIN OrderDetails od ON p.Product_ID = od.Product_ID
	INNER JOIN Orders o ON od.Order_ID = o.Order_ID
	WHERE o.Customer_ID = @MaKH;
END;

EXEC SP_SanPham_MaKH @MaKH = 1;