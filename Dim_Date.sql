------------------------------------------------------
-------------------OLAP TABLES-------------------------


------------------------------------------------------
--------------------Dim_Date--------------------------
-- TABLE CREATION

CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    DateFull Date,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    DayOfWeek INT,
    DayName nvarchar(10),
    MonthName nvarchar(10)
);
go

-- TABLE POPULATION

DECLARE @StartDate DATE = '2000-01-01';
DECLARE @EndDate DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (
        DateKey,
        DateFull,
        Year,
        Quarter,
        Month,
        Day,
        DayOfWeek,
        DayName,
        MonthName
    )
    VALUES (
        CONVERT (char(8),@StartDate,112),
        CONVERT(VARCHAR(10), @StartDate, 120),
        YEAR(@StartDate),
        DATEPART(QUARTER, @StartDate),
        MONTH(@StartDate),
        DAY(@StartDate),
        DATEPART(WEEKDAY, @StartDate),
        DATENAME(WEEKDAY, @StartDate),
        DATENAME(MONTH, @StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;


