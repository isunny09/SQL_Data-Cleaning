--Cleaning data in SQL
--Taking an initial look at the data set
SELECT * 
FROM dbo.housing_data$

--Looking at the SaleDate column, it has a time stamp after the date which I want to get rid of. Adding a new column saledate which replaces the exisitng column

--Adding a new column which will hold the converted date type 
ALTER TABLE housing_data$
Add SaleDateConverted Date;

--Updating the newly created column 
UPDATE dbo.housing_data$
SET SaleDateConverted = CONVERT(Date, SaleDate)

--select * from housing_data$

--Checking if the above query worked
Select SaleDateConverted from housing_data$



--Populating the Property Address column

--First checking if there are any null values
Select PropertyAddress 
from dbo.housing_data$
where PropertyAddress is NULL
--The above query shows thereare 29 fields with null values

SELECT * from dbo.housing_data$
order by ParcelID

--Looking at the data, I've noticed that there are fields with similar parcel ID's but one of them was missing the property address. 
--Hence I can use the ParcelID to populate the null propert address values where ever possible

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from dbo.housing_data$ a
JOIN dbo.housing_data$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--The above query shows we have the addresses for all the NULL values in the property address column. We can now use this to
--populate the null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing_data$ a
JOIN dbo.housing_data$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housing_data$ a
JOIN dbo.housing_data$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--DONE

--Using the address column to break it down into Individual columns like address, city,state
select PropertyAddress from dbo.housing_data$

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from dbo.housing_data$

ALTER TABLE dbo.housing_data$
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE dbo.housing_data$
ADD PropertySplitCity nvarchar(255);

UPDATE housing_data$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

UPDATE housing_data$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * from dbo.housing_data$

ALTER TABLE dbo.housing_data$
DROP COLUMN PropertSplitCity

SELECT OwnerAddress FROM dbo.housing_data$ --
--Using the column OwnerAddress, I'm gonna split it and extract the address, city and the state from it
--using PARSENAME
--Looks for periods
--Replacing the delimeter into a period

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM dbo.housing_data$
--PARSENAME kinda works backwards, so the above code gives us the splits in required order.


ALTER TABLE dbo.housing_data$
ADD OwnerSplitAddress nvarchar(255)

UPDATE housing_data$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE dbo.housing_data$
ADD OwnerSplitCity nvarchar(255)

UPDATE housing_data$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE dbo.housing_data$
ADD OwnerSplitState nvarchar(255)

UPDATE housing_data$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT * FROM dbo.housing_data$
--------------------

Select DISTINCT(SoldAsVacant)
FROM dbo.housing_data$

--Replacing the Y and N to yes and no to have consistency within the column using CASE statement
Select SoldAsVacant,
	CASE	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
FROM dbo.housing_data$

UPDATE dbo.housing_data$
SET SoldAsVacant = CASE	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
			             ELSE SoldAsVacant
						 END
FROM dbo.housing_data$

---

select * from housing_data$
-- Removing duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From housing_data$
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




Select *
From housing_data$

---removing rows with null values using dynamic sql
---We declare two variables: @tableName to hold the table name and @sql to hold the dynamically generated DELETE statement.
---The SELECT statement concatenates the column names with the IS NULL OR condition using the QUOTENAME function. It fetches all the column names from the INFORMATION_SCHEMA.COLUMNS view for the specified table.
---After concatenating the column names with the IS NULL OR condition, we remove the trailing 'OR ' using LEFT function before executing the dynamic DELETE statement.

DECLARE @tableName NVARCHAR(100) = 'housing_data$';
DECLARE @sql NVARCHAR(MAX) = N'DELETE FROM ' + QUOTENAME(@tableName) + N' WHERE ';

SELECT @sql += QUOTENAME(COLUMN_NAME) + N' IS NULL OR '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName;

SET @sql = LEFT(@sql, LEN(@sql) - 3); -- Remove the trailing 'OR '

EXEC sp_executesql @sql;
---
select * from housing_data$
---the data is now clean and there are no null values. 