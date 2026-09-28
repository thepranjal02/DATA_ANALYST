/*

Cleaning Data in SQL Queries

*/


Select *
From PORTFOLIO_PROJECT.NashvilleHousing;

-- Standardize Date Format


SELECT 
    SaleDate
FROM PORTFOLIO_PROJECT.NashvilleHousing;

set sql_safe_updates=0;
UPDATE PORTFOLIO_PROJECT.NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');


-- If it doesn't Update properly

-- ALTER TABLE NashvilleHousing
-- Add SaleDateConverted Date;

-- Update NashvilleHousing
-- SET SaleDateConverted = CONVERT(Date,SaleDate) ;


-- Populate Property Address data

Select *
From PORTFOLIO_PROJECT.NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID ;



SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM PORTFOLIO_PROJECT.NashvilleHousing a
JOIN PORTFOLIO_PROJECT.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';


UPDATE PORTFOLIO_PROJECT.NashvilleHousing a
JOIN PORTFOLIO_PROJECT.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = ''
  AND b.PropertyAddress IS NOT NULL;


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PORTFOLIO_PROJECT.NashvilleHousing
-- Where PropertyAddress is null
-- order by ParcelID
;

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(
        PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)
    ) AS City
FROM PORTFOLIO_PROJECT.NashvilleHousing;

ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE PORTFOLIO_PROJECT.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(
    PropertyAddress,
    1,
    LOCATE(',', PropertyAddress) - 1
);

ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE PORTFOLIO_PROJECT.NashvilleHousing
SET PropertySplitCity = SUBSTRING(
    PropertyAddress,
    LOCATE(',', PropertyAddress) + 1,
    LENGTH(PropertyAddress)
);




Select *
From PORTFOLIO_PROJECT.NashvilleHousing;





Select OwnerAddress
From PORTFOLIO_PROJECT.NashvilleHousing;


SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerSplitCity,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerSplitState
FROM PORTFOLIO_PROJECT.NashvilleHousing;



ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE PORTFOLIO_PROJECT.NashvilleHousing
SET
    OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
    OwnerSplitCity = TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            -1
        )
    ),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));


Select *
From PORTFOLIO_PROJECT.NashvilleHousing;



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PORTFOLIO_PROJECT.NashvilleHousing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PORTFOLIO_PROJECT.NashvilleHousing;


Update PORTFOLIO_PROJECT.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END ;



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PORTFOLIO_PROJECT.NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;



Select *
From PORTFOLIO_PROJECT.NashvilleHousing;


-- Delete Unused Columns

Select *
From PORTFOLIO_PROJECT.NashvilleHousing;


ALTER TABLE PORTFOLIO_PROJECT.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;













-- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- USE PortfolioProject 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

-- GO 


-- Using BULK INSERT

-- USE PortfolioProject;
-- GO
-- BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
-- );
-- GO


-- Using OPENROWSET
-- USE PortfolioProject;
-- GO
-- SELECT * INTO nashvilleHousing
-- FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
-- GO