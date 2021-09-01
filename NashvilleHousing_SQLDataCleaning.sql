-- Cleaning Daa with SQL Queries

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLDataCleaning.dbo.NashvilleHousing a
JOIN SQLDataCleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLDataCleaning.dbo.NashvilleHousing a
JOIN SQLDataCleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into individual columns (Address, City, State)

SELECT PropertyAddress
FROM SQLDataCleaning.dbo.NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM SQLDataCleaning.dbo.NashvilleHousing;

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD Address NVARCHAR(255);

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD City NVARCHAR(255);

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing;

-- Breaking out OwnerAddress into individual columns (Address, City, State)

SELECT OwnerAddress
FROM SQLDataCleaning.dbo.NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM SQLDataCleaning.dbo.NashvilleHousing;

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing;

-------------------------------------------------------------------------------------------

-- Standardize 'Sold As Vacant' Values to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLDataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM SQLDataCleaning.dbo.NashvilleHousing;

UPDATE SQLDataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLDataCleaning.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

-------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
	FROM SQLDataCleaning.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing;

-------------------------------------------------------------------------------------------

-- Remove Unused Columns : SaleDate, PropertyAddress, OwnerAddress and TaxDistrict

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT *
FROM SQLDataCleaning.dbo.NashvilleHousing;