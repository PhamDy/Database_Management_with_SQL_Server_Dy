-- CREATE AND RESET: DATABASE
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Slot10_Assignment_06')
DROP DATABASE Slot10_Assignment_06
GO
CREATE DATABASE Slot10_Assignment_06
GO
USE Slot10_Assignment_06
GO

-- 1) CREATE TABLE
-- TABLE PublishingCompany
CREATE TABLE PublishingCompany (
	Company_ID INT IDENTITY (1, 1) NOT NULL UNIQUE,
	Company_name NVARCHAR(50) NOT NULL,
	Address NVARCHAR(255) NOT NULL,
	Quantity INT NOT NULL,
	PRIMARY KEY (Company_ID)
);

-- TABLE Catalogies
CREATE TABLE Catalogies (
	Catalogi_ID INT IDENTITY (1, 1) NOT NULL UNIQUE,
	Catalogi_name NVARCHAR(50) NOT NULL,
	PRIMARY KEY (Catalogi_ID)
);

-- TABLE Author
CREATE TABLE Author (
	Author_ID INT IDENTITY (1, 1) NOT NULL UNIQUE,
	Author_name NVARCHAR(50) NOT NULL,
	PRIMARY KEY (Author_ID)
);

-- TABLE Book
CREATE TABLE Book (
	Book_ID NVARCHAR(20) NOT NULL UNIQUE,
	Author_ID INT NOT NULL,
	Company_ID INT NOT NULL,
	Catalogi_ID INT NOT NULL,
	Book_name NVARCHAR(50) NOT NULL,
	Summary_content NVARCHAR(MAX) NOT NULL,
	Publishing_year INT NOT NULL,
	Publication_time INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	PRIMARY KEY (Book_ID),
	CONSTRAINT Author_ID_FK FOREIGN KEY(Author_ID) REFERENCES Author(Author_ID),
	CONSTRAINT Company_ID_FK FOREIGN KEY(Company_ID) REFERENCES PublishingCompany(Company_ID),
	CONSTRAINT Catalogi_ID_FK FOREIGN KEY(Catalogi_ID) REFERENCES Catalogies(Catalogi_ID)
);
-- TABLE AuthorBook
CREATE TABLE AuthorBook (
	Book_ID NVARCHAR(20) NOT NULL,
	Author_ID INT NOT NULL,
	PRIMARY KEY (Book_ID, Author_ID),
	FOREIGN KEY(Book_ID) REFERENCES Book(Book_ID),
	FOREIGN KEY(Author_ID) REFERENCES Author(Author_ID)
);
-- 2) INSERT INTO
--PublishingCompany
INSERT INTO PublishingCompany
	VALUES ('Tri Thức', '53 Nguyễn Du, Hai Bà Trưng, Hà Nội', 100);
SELECT * FROM PublishingCompany;

--Catalogies
INSERT INTO Catalogies 
	VALUES ('Khoa học xã hội');
SELECT * FROM Catalogies;
--Author
INSERT INTO Author 
	VALUES ('Eran Katz');
SELECT * FROM Author;
--Book
INSERT INTO Book (Book_ID, Author_ID, Company_ID, Catalogi_ID, Book_name, Summary_content, Publishing_year, Publication_time, UnitPrice) 
	VALUES ('B001', 1, 1, 1,'Trí tuệ Do Thái', 'Bạn có muốn biết: Người Do Thái sáng tạo ra cái gì và nguồn gốc
trí tuệ của họ xuất phát từ đâu không? Cuốn sách này sẽ dần hé lộ
những bí ẩn về sự thông thái của người Do Thái, của một dân tộc
thông tuệ với những phương pháp và kỹ thuật phát triển tầng lớp trí
thức đã được giữ kín hàng nghìn năm như một bí ẩn mật mang tính
văn hóa.', 2010, 1, 79000);
SELECT * FROM Book;

--3. Liệt kê các cuốn sách có năm xuất bản từ 2008 đến nay
SELECT * 
FROM Book
WHERE Publishing_year BETWEEN 2008 AND 2023; 

--4. Liệt kê 10 cuốn sách có giá bán cao nhất
SELECT MAX(UnitPrice) AS MaxUnitPrice
FROM Book

--5. Tìm những cuốn sách có tiêu đề chứa từ “tin học”
SELECT * FROM Book
WHERE Book_name Like '%tin học%';

SELECT * FROM Book
WHERE Book_name Like '%do%';

--6. Liệt kê các cuốn sách có tên bắt đầu với chữ “T” theo thứ tự giá giảm dần
SELECT * FROM Book
WHERE Book_name LIKE 'T%';

--7. Liệt kê các cuốn sách của nhà xuất bản Tri thức
SELECT b.*
FROM Book b
INNER JOIN PublishingCompany pc ON pc.Company_ID = b.Company_ID
WHERE pc.Company_name = 'Tri thức';

SELECT *
FROM Book
WHERE Company_ID IN (SELECT Company_ID FROM PublishingCompany WHERE Company_name LIKE 'Tri thức')

--8. Lấy thông tin chi tiết về nhà xuất bản xuất bản cuốn sách “Trí tuệ Do Thái”
SELECT *
FROM PublishingCompany
WHERE Company_ID IN (SELECT Company_ID FROM Book WHERE Book_name LIKE 'Trí tuệ Do Thái');

--9. Hiển thị các thông tin sau về các cuốn sách: Mã sách, Tên sách, Năm xuất bản, Nhà xuất bản, Loại sách
SELECT b.Book_ID, b.Book_name, b.Publishing_year, pc.Company_name, c.Catalogi_name
FROM Book b
INNER JOIN Catalogies c ON c.Catalogi_ID = b.Catalogi_ID
INNER JOIN PublishingCompany pc ON pc.Company_ID = b.Company_ID;

--10. Tìm cuốn sách có giá bán đắt nhất
SELECT TOP 1 Book_name, UnitPrice
FROM Book
ORDER BY UnitPrice DESC;
--11. Tìm cuốn sách có số lượng lớn nhất trong kho
SELECT Book_name
FROM Book
WHERE Company_ID IN (SELECT TOP 1 Company_ID FROM PublishingCompany ORDER BY Quantity DESC);

SELECT TOP 1 b.Book_name, Book_name
FROM Book b
INNER JOIN PublishingCompany pc ON pc.Company_ID = b.Company_ID
ORDER BY Quantity DESC;
 
--12. Tìm các cuốn sách của tác giả “Eran Katz”
SELECT Book_name
FROM Book
WHERE Author_ID IN (SELECT Author_ID FROM Author WHERE Author_name LIKE 'Eran Katz');

--13. Giảm giá bán 10% các cuốn sách xuất bản từ năm 2008 trở về trước
UPDATE Book 
SET UnitPrice = UnitPrice * 0.9
WHERE Publishing_year <= 2008;

--14. Thống kê số đầu sách của mỗi nhà xuất bản
SELECT pc.Company_name, COUNT(*) AS TotalBook
FROM Book b
INNER JOIN PublishingCompany pc ON pc.Company_ID = b.Company_ID
GROUP BY pc.Company_name;

--15. Thống kê số đầu sách của mỗi loại sách
SELECT c.Catalogi_name, COUNT(*) AS TotalBook
FROM Book b
INNER JOIN Catalogies c ON c.Catalogi_ID = b.Catalogi_ID
GROUP BY c.Catalogi_name;

--16. Đặt chỉ mục (Index) cho trường tên sách
CREATE INDEX idc_BookName
ON Book (Book_name);

--17. Viết view lấy thông tin gồm: Mã sách, tên sách, tác giả, nhà xb và giá bán
CREATE VIEW View_Infor_Book AS
SELECT b.Book_ID, b.Book_name, a.Author_name, pc.Company_name, b.UnitPrice
FROM Book b
INNER JOIN PublishingCompany pc ON pc.Company_ID = b.Company_ID
INNER JOIN Author a ON a.Author_ID = b.Author_ID;

SELECT * FROM View_Infor_Book;

--18. Viết Store Procedure:
--◦ SP_Them_Sach: thêm mới một cuốn sách
CREATE PROCEDURE SP_Them_Sach
	@Book_ID NVARCHAR(20),
	@Author_ID INT,
	@Company_ID INT ,
	@Catalogi_ID INT ,
	@Book_name NVARCHAR(50),
	@Summary_content NVARCHAR(MAX),
	@Publishing_year INT ,
	@Publication_time INT ,
	@UnitPrice MONEY
AS
BEGIN
	IF EXISTS( SELECT * FROM Book WHERE Book_ID != @Book_ID AND @Author_ID IN (SELECT Author_ID FROM Author) 
				AND @Company_ID IN (SELECT Company_ID FROM PublishingCompany) AND @Catalogi_ID  IN (SELECT Catalogi_ID FROM Catalogies) )
		INSERT INTO Book(Book_ID, Author_ID, Company_ID, Catalogi_ID, Book_name, Summary_content, Publishing_year, Publication_time, UnitPrice) 
			VALUES  (@Book_ID, @Author_ID, @Company_ID, @Catalogi_ID, @Book_name, @Summary_content, @Publishing_year, @Publication_time, @UnitPrice);
	ELSE
	BEGIN
		PRINT 'Du lieu dua vao khong hop le'
	END
END;
--RUN
EXEC SP_Them_Sach 'B002', 1, 1, 1, 'Đắc Nhân Tâm', 'giao tiếp', 2006, 10, 120000;
EXEC SP_Them_Sach 'B003', 2, 2, 3, 'Tấm cám', 'truyện cổ tích', 2001, 5, 100000;

--◦ SP_Tim_Sach: Tìm các cuốn sách theo từ khóa
CREATE PROCEDURE SP_Tim_Sach
	@Keywork NVARCHAR(50)
AS
BEGIN
	IF EXISTS (SELECT * FROM Book WHERE Book_name LIKE '%' + @Keywork + '%')
		SELECT * FROM Book WHERE Book_name LIKE '%' + @Keywork + '%'
	ELSE
	BEGIN
		PRINT 'Du lieu dua vao khong tim thay'
	END
END;

DROP PROCEDURE SP_Tim_Sach;

EXEC SP_Tim_Sach 'trí';
EXEC SP_Tim_Sach 'do';
EXEC SP_Tim_Sach 'z';

--◦ SP_Sach_ChuyenMuc: Liệt kê các cuốn sách theo mã chuyên mục
CREATE PROCEDURE SP_Sach_ChuyenMuc
	@Catalogi_ID INT
AS
BEGIN
	IF EXISTS (SELECT * FROM Book WHERE @Catalogi_ID IN ( SELECT Catalogi_ID FROM Catalogies))
		SELECT * FROM Book WHERE @Catalogi_ID IN ( SELECT Catalogi_ID FROM Catalogies)
	BEGIN
		PRINT 'Du lieu dua vao khong tim thay'
	END
END;

EXEC SP_Sach_ChuyenMuc 1;
EXEC SP_Sach_ChuyenMuc 2;

--19. Viết trigger không cho phép xóa các cuốn sách vẫn còn trong kho (số lượng > 0)
CREATE TRIGGER TG_Xoa_Sach
ON Book AFTER DELETE
AS
BEGIN
		IF EXISTS (SELECT * FROM PublishingCompany pc
					INNER JOIN deleted d ON d.Company_ID = pc.Company_ID
					WHERE pc.Quantity > 0
					)
	BEGIN
		RAISERROR('Not allowed to delete books', 16, 1)
		ROLLBACK TRANSACTION
	END
END;

SELECT * FROM PublishingCompany;
DELETE Book WHERE Company_ID IN ( SELECT Company_ID FROM PublishingCompany)

--20. Viết trigger chỉ cho phép xóa một danh mục sách khi không còn cuốn sách nào thuộc chuyên mục này.
CREATE TRIGGER TG_Xoa_Danh_Muc
ON Catalogies AFTER DELETE
AS
BEGIN
	IF EXISTS ( SELECT * FROM Book b
				INNER JOIN deleted d ON b.Catalogi_ID = d.Catalogi_ID 
				)
	BEGIN
		RAISERROR('It is not allowed to delete the list of books with books in this category', 16, 1)
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DELETE c
		FROM Catalogies c
		INNER JOIN deleted d ON C.Catalogi_ID = d.Catalogi_ID;
	END
END;


