/*

Nashville Housing Data Cleansing

*/

SELECT *
FROM HousingProject.dbo.Housing




-- Date Formatting

SELECT SaleDate, CONVERT(date, SaleDate)
FROM HousingProject.dbo.Housing

ALTER TABLE Housing
ADD SaleDateFormatted date;

UPDATE Housing
SET SaleDateFormatted = CONVERT(date, SaleDate)




-- Populating Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingProject.dbo.Housing a
JOIN HousingProject.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingProject.dbo.Housing a
JOIN HousingProject.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Separating Address by Street Address, City, and State

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
FROM HousingProject.dbo.Housing

ALTER TABLE Housing
ADD PropertyStreetAddress nvarchar(255);

UPDATE Housing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Housing
ADD PropertyCity nvarchar(255);

UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))




SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingProject.dbo.Housing

ALTER TABLE Housing
ADD OwnerStreetAddress nvarchar(255);

UPDATE Housing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
ADD OwnerCity nvarchar(255);

UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD OwnerState nvarchar(255);

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





-- Standardizing Language for 'Yes' and 'No' in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingProject.dbo.Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingProject.dbo.Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END




-- Remove Duplicate Entries

WITH RowNumberCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				ORDER BY UniqueID
				) row_num
FROM HousingProject.dbo.Housing
)
DELETE
FROM RowNumberCTE
WHERE row_num >1



-- Remove Unused Columns

ALTER TABLE HousingProject.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingProject.dbo.Housing
DROP COLUMN SaleDate