USE AdventureWorksDW2022;
GO
/*
SELECT * FROM DimCustomer;

GO

SELECT * FROM DimProduct;
GO

SELECT * FROM FactInternetSales;
GO
*/


---------------------------------------------------------------------------------------------
CREATE VIEW vw_Dim_Customer AS
SELECT 
    c.CustomerKey,
    c.FirstName + ' ' + ISNULL(c.LastName, '') AS [Full_Name],
    DATEDIFF(YEAR, c.BirthDate, GETDATE()) AS [Age],
    CASE 
        WHEN DATEDIFF(YEAR, c.BirthDate, GETDATE()) >= 60 THEN 'Seniors'
        WHEN DATEDIFF(YEAR, c.BirthDate, GETDATE()) BETWEEN 40 AND 59 THEN 'Gen X'
        WHEN DATEDIFF(YEAR, c.BirthDate, GETDATE()) BETWEEN 25 AND 39 THEN 'Millennials'
        ELSE 'Gen Z'
    END AS [Age_Segment],
    CASE WHEN c.Gender = 'M' THEN 'Male' ELSE 'Female' END AS [Gender],
    g.City,
    g.EnglishCountryRegionName AS [Country]
FROM DimCustomer c
JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
GO

---------------------------------------------------------------------------------------------
CREATE VIEW vw_Dim_Product AS
SELECT 
    p.ProductKey,
    p.EnglishProductName AS [Product],
    p.Color,
    p.Size,
    ps.EnglishProductSubcategoryName AS [Subcategory],
    pc.EnglishProductCategoryName AS [Category]
FROM DimProduct p
LEFT JOIN DimProductSubcategory ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN DimProductCategory pc ON ps.ProductCategoryKey = pc.ProductCategoryKey;
GO

---------------------------------------------------------------------------------------------
CREATE VIEW vw_Fact_Sales AS
SELECT 
    SalesOrderNumber AS [Order_Id],
    OrderDate,
    CustomerKey,
    ProductKey,
    OrderQuantity AS [Quantity],
    SalesAmount AS [Revenue],
    TotalProductCost AS [Cost],
    (SalesAmount - TotalProductCost) AS [Profit]
FROM FactInternetSales;
GO


--Crear la tabla física
CREATE TABLE Dim_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Month_Number INT,
    Month_Name VARCHAR(15),
    Quarter VARCHAR(2),
    Week_Number INT,
    Day_Name VARCHAR(15),
    Day_Type VARCHAR(10)
);
GO

--Llenar la tabla con un script (Loop)
DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2030-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (DateKey, FullDate, Year, Month_Number, Month_Name, Quarter, Week_Number, Day_Name, Day_Type)
    SELECT 
        CAST(CONVERT(VARCHAR(8), @StartDate, 112) AS INT),
        @StartDate,
        YEAR(@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate),
        'Q' + CAST(DATEPART(QUARTER, @StartDate) AS VARCHAR),
        DATEPART(WEEK, @StartDate),
        DATENAME(WEEKDAY, @StartDate),
        CASE WHEN DATEPART(WEEKDAY, @StartDate) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END;

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
GO

--Consulta de prueba para verificar que la tabla se ha llenado correctamente.
SELECT TOP 5 * FROM Dim_Date ORDER BY FullDate DESC;

---------------------------------------------------------------------------------------------





