--Cleaning data in SQL

--Taking an initial look at the data set
SELECT * 
FROM dbo.Nashville_Housing

--Looking at the SaleDate column, it has a time stamp after the date which I want to get rid of. Adding a new column saledate which replaces the exisitng column
--UPDATE Nashville_Housing
--SET SaleDate = CONVERT(Date,SaleDate) -- This wasn't working for some reason

--select SaleDate from dbo.Nashville_Housing

--Adding a new column which will hold the converted date type 
ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

--Updating the newly created column 
UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Checking if the above query worked
Select SaleDateConverted from Nashville_Housing

------

--Populating the Property Address column

--First checking if there are any null values
Select PropertyAddress 
from dbo.Nashville_Housing
where PropertyAddress is NULL
--The above query shows thereare 29 fields with null values

SELECT * from dbo.Nashville_Housing
order by ParcelID

--Looking at the data, I've noticed that there are fields with similar parcel ID's but one of them was missing the property address. 
--Hence I can use the ParcelID to populate the null propert address values where ever possible

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from dbo.Nashville_Housing a
JOIN dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--The above query shows we have the addresses for all the NULL values in the property address column. We can now use this to
--populate the null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Nashville_Housing a
JOIN dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Nashville_Housing a
JOIN dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is NULL

--DONE

--Using the address column to break it down into Individual columns like address, city,state
select PropertyAddress from dbo.Nashville_Housing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from dbo.Nashville_Housing

ALTER TABLE dbo.Nashville_Housing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE dbo.Nashville_Housing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * from dbo.Nashville_Housing

ALTER TABLE dbo.Nashville_Housing
DROP COLUMN PropertSplitCity

SELECT OwnerAddress FROM dbo.Nashville_Housing --
--Using the column OwnerAddress, I'm gonna split it and extract the address, city and the state from it
--using PARSENAME
--Looks for periods
--Replacing the delimeter into a period

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM dbo.Nashville_Housing
--PARSENAME kinda works backwards, so the above code gives us the splits in required order.


ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitCity nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE dbo.Nashville_Housing
ADD OwnerSplitState nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT * FROM dbo.Nashville_Housing
--------------------

Select DISTINCT(SoldAsVacant)
FROM dbo.Nashville_Housing

--Replacing the Y and N to yes and no to have consistency within the column using CASE statement
Select SoldAsVacant,
	CASE	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
FROM dbo.Nashville_Housing

UPDATE dbo.Nashville_Housing
SET SoldAsVacant = CASE	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
			             ELSE SoldAsVacant
						 END
FROM dbo.Nashville_Housing

---
-- Removing duplicates
WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
					) row_num
FROM dbo.Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--This shows there are 104 duplicates.
--Now deleting them, Teh below chunk confirms that the duplicated have been deleted

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
					) row_num
FROM dbo.Nashville_Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT * FROM dbo.Nashville_Housing
ALTER TABLE dbo.Nashville_Housing
DROP COLUMN SaleDate

SELECT * FROM dbo.Nashville_Housing