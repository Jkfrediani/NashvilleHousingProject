--Cleaning data with SQL

SELECT *
FROM HousingProject.dbo.NashvilleHousing

--Standardize date format

--ALTER TABLE NashvilleHousing
--DROP COLUMN sale_date_converted
SELECT sale_date_converted, CONVERT(DATE,SaleDate)
FROM HousingProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD sale_date_converted DATE;

UPDATE NashvilleHousing
SET sale_date_converted = CONVERT(DATE,SaleDate)

--Populate property address data

SELECT * --PropertyAddress
FROM HousingProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
--Check for rows where property address did not populate
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Join table into itself to fill null values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Breaking out address into 2 individual columns(address, city) using substrings

SELECT PropertyAddress
FROM HousingProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) AS address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS address

FROM HousingProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address NVARCHAR(255);

UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD property_split_city NVARCHAR(255);

UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM HousingProject.dbo.NashvilleHousing


--Breaking out address into 3 individual columns(address, city, state) using PARSENAME
--PARSENAME only looks for periods, must change commas into periods

SELECT OwnerAddress
FROM HousingProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as owner_address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as owner_city
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as owner_state
FROM HousingProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD owner_address NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD owner_city NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD owner_state NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *

FROM HousingProject.dbo.NashvilleHousing


--CHANGE y and N to yes and no is "sold as vacant" field

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM HousingProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM HousingProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Removing Duplicates

SELECT *,
	ROW_NUMBER() OVER(PARTITION BY UniqueID
	ORDER BY UniqueID) row_num

FROM HousingProject.dbo.NashvilleHousing
ORDER BY UniqueID --Shows no duplicates according to UniqueID

--selecting duplicates using CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM HousingProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--deleting duplicates, should remove 104 rows

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM HousingProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--Delete unused columns


SELECT *
FROM HousingProject.dbo.NashvilleHousing

ALTER TABLE HousingProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE HousingProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
