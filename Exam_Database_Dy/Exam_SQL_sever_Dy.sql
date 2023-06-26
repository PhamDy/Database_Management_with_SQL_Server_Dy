-- 1. Create a database as requested above.
USE Master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE Name='Exam_SQL_sever_Dy')
DROP DATABASE Exam_SQL_sever_Dy
GO
CREATE DATABASE Exam_SQL_sever_Dy
GO
USE Exam_SQL_sever_Dy
GO

-- 2. Create table based on the above design.
--Table Region_Planning 
CREATE TABLE Region_Planning (
	LocationID CHAR(6) NOT NULL UNIQUE,
	Name NVARCHAR(50) NOT NULL,
	Description NVARCHAR(100),
	PRIMARY KEY (LocationID)
);

--Table	Land
CREATE TABLE Zone_Planning (
	LandID INT IDENTITY(1,1) NOT NULL UNIQUE,
	Title NVARCHAR(100) NOT NULL,
	LocationID CHAR(6) NOT NULL,
	Detail NVARCHAR(1000),
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	PRIMARY KEY (LandID),
	CONSTRAINT LocationID_FK FOREIGN KEY(LocationID) REFERENCES Region_Planning(LocationID)
);

--Table Building 
CREATE TABLE Building (
	BuildingID INT IDENTITY(1,1) NOT NULL UNIQUE,
	LandID INT NOT NULL,
	BuildingType NVARCHAR(50),
	Area INT Default 50,
	Floors INT Default 1,
	Rooms INT Default 1,
	Cost MONEY,
	PRIMARY KEY (BuildingID),
	CONSTRAINT LandID_FK FOREIGN KEY(LandID) REFERENCES Zone_Planning(LandID)
);

-- 3. Insert into each table at least three records.
-- Region_Planning
INSERT INTO Region_Planning (LocationID, Name, Description)
	VALUES  ('100000', 'My Dinh', 'phan lo ban nen'),
			('118000', 'Ba Dinh', 'gan cong vien Thu Le'),
			('111700', 'Hoan Kiem', 'gan ho Guom, pho di bo');

-- Zone_Planning
INSERT INTO Zone_Planning (Title, LocationID, Detail, StartDate, EndDate)
	VALUES  ('A', '100000', 'dat tho cu', '2015-5-5', '2020-6-6'),
			('B', '118000', 'dat nha nuoc', '2018-2-1', '2022-4-1'),
			('C', '111700', 'dat xay dung', '2020-4-9', '2024-5-10');

-- Building
INSERT INTO Building (LandID, BuildingType, Area, Floors, Rooms, Cost)
	VALUES  (1, 'Biet thu', 100, 4, 12, 35000000),
			(2, 'Can ho', 70, 3, 6, 20000000),
			(3, 'Sieu thi', 1000, 3, 40, 100000000);
-- SELECT
SELECT * FROM Region_Planning;
SELECT * FROM Zone_Planning;
SELECT * FROM Building;

-- 4. List all the buildings with a floor area of 100m2 or more.
SELECT *  FROM Building WHERE Area >= 100;

-- 5. List the construction land will be completed before January 2013.
SELECT * FROM Zone_Planning WHERE EndDate < '2013-01-01';

-- 6. List all buildings to be built in the land of title "My Dinh”
SELECT b.BuildingType
FROM Building b
INNER JOIN Zone_Planning z ON b.LandID = z.LandID
INNER JOIN Region_Planning r ON r.LocationID = z.LocationID
WHERE r.Name = 'My Dinh';

-- 7. Create a view v_Buildings contains the following information (BuildingID, Title, Name,
-- BuildingType, Area, Floors) from table Building, Land and Location.
CREATE VIEW v_Buildings AS
SELECT b.BuildingID, z.Title, r.Name, b.BuildingType, b.Area, b.Floors
FROM Building b
INNER JOIN Zone_Planning z ON b.LandID = z.LandID
INNER JOIN Region_Planning r ON r.LocationID = z.LocationID;

-- TEST
SELECT * FROM v_Buildings;

-- 8. Create a view v_TopBuildings about 5 buildings with the most expensive price per m2.
CREATE VIEW v_TopBuildings AS
SELECT TOP 5 b.BuildingID, b.LandID, b.BuildingType, z.Detail
FROM Building b
INNER JOIN Zone_Planning z ON z.LandID = b.LandID
ORDER BY b.Cost DESC

-- TEST
SELECT * FROM v_TopBuildings;

-- 9. Create a store called sp_SearchLandByLocation with input parameter is the area code and retrieve planned land for this area.
CREATE PROCEDURE sp_SearchLandByLocation 
	@LocationID NVARCHAR(6) 
AS 
BEGIN
	IF EXISTS (
				SELECT *
				FROM Zone_Planning z
				WHERE LocationID = @LocationID
	)
	BEGIN
		SELECT *
		FROM Zone_Planning z
		WHERE LocationID = @LocationID
	END
	ELSE
	BEGIN
		PRINT 'The requested information could not be found'
	END
END;

-- TEST
SELECT * FROM Zone_Planning
EXEC sp_SearchLandByLocation @LocationID = '100000';
EXEC sp_SearchLandByLocation @LocationID = '123';

-- 10. Create a store called sp_SearchBuidingByLand procedure input parameter is the land code and retrieve the buildings built on that land.
CREATE PROCEDURE sp_SearchBuidingByLand 
	@LandID INT
AS 
BEGIN
	IF EXISTS (
				SELECT b.BuildingID, b.BuildingType
				FROM Building b
				WHERE LandID = @LandID
	)
	BEGIN
		SELECT b.BuildingID, b.BuildingType
		FROM Building b
		WHERE LandID = @LandID
	END
	ELSE
	BEGIN
		PRINT 'The requested information could not be found'
	END
END;
 
--TEST
SELECT * FROM Building
EXEC sp_SearchBuidingByLand @LandID = '2';
EXEC sp_SearchBuidingByLand @LandID = '6';

-- 11. Create a trigger tg_RemoveLand allows to delete only lands which have not any buildings built on it.
CREATE TRIGGER tg_RemoveLand
ON Zone_Planning
INSTEAD OF DELETE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Building WHERE LandID IN (SELECT LandID FROM deleted))
    BEGIN
        DELETE FROM Zone_Planning WHERE LandID IN (SELECT LandID FROM deleted);
    END
    ELSE
    BEGIN
        RAISERROR('Cannot delete lands with buildings built on them.', 16, 1);
    END
END;

-- TEST TRIGGER tg_RemoveLand
SELECT * FROM Zone_Planning;
DELETE FROM Zone_Planning WHERE LandID = 1;
DELETE FROM Zone_Planning WHERE LandID = 4;