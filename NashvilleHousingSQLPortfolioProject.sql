/* Nashville Housing Data Cleaning Project */

SELECT *
FROM PortfolioProjectSQL02..NashvilleHousing

/* Standardize Date Format */
SELECT SaleDate
--, CONVERT(Date, SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date
SELECT SaleDate FROM NashvilleHousing

/* Populate Property Address Data */
SELECT *
FROM PortfolioProjectSQL02..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProjectSQL02..NashvilleHousing a
	JOIN PortfolioProjectSQL02..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProjectSQL02..NashvilleHousing a
	JOIN PortfolioProjectSQL02..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/* Split PropertyAddress into columns (Address, City) */
SELECT PropertyAddress
FROM PortfolioProjectSQL02..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address -- Get all the characters from position 1 up to specified charindex.
	--,CHARINDEX(',', PropertyAddress)		-- Check the number of character position
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 -- New column starting character position
	,LEN(PropertyAddress)) AS Address2		-- Get all the characters from this new position
FROM PortfolioProjectSQL02..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255) 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 
	,LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255) 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing

/* Update Splitted Owner's Address Columns with NULL values and TRIM OwnerSplitState */
UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
WHERE OwnerSplitAddress IS NULL

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 
	,LEN(PropertyAddress))
WHERE OwnerSplitCity IS NULL

SELECT DISTINCT(OwnerSplitCity), OwnerSplitState
FROM NashvilleHousing
--WHERE OwnerSplitState IS NULL
ORDER BY 1

UPDATE NashvilleHousing
SET OwnerSplitState = 'TN'
WHERE OwnerSplitState IS NULL

--SELECT 
--TRIM(OwnerSplitState)
--FROM NashvilleHousing

UPDATE NashvilleHousing
SET OwnerSplitState = 
	TRIM(OwnerSplitState)
	FROM NashvilleHousing

/* Change Y to Yes and N to No in 'Sold as Vacant' Column */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 	
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

/* Remove Duplicates */

WITH CTERowNum AS (
SELECT *,
	ROW_NUMBER() 
	OVER (PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY
		UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM CTERowNum
WHERE row_num > 1
--ORDER BY PropertyAddress

/* Delete unused columns */
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDateConverted