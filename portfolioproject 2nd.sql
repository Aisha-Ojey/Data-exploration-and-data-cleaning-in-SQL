--cleaning data in SQL
Select * from portfolioproject1.dbo.NashvilleHousing

------------------------------------------------------------------------------

--formatting the saledate column into a standard date format
Select SaleDate, CONVERT (Date, SaleDate) As saledate2
from portfolioproject1.dbo.NashvilleHousing
 
Alter table portfolioproject1.dbo.NashvilleHousing 
Add SaleDateconverted Date;
UPDATE portfolioproject1.dbo.NashvilleHousing SET SaleDateconverted = CONVERT (Date, SaleDate) 
Select SaleDateconverted, CONVERT (Date, SaleDate) as saledate02
from portfolioproject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------
--Populate property address
Select * from portfolioproject1.dbo.NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

Select pa.ParcelID, pa.PropertyAddress, pa1.ParcelID, pa1.PropertyAddress, ISNULL(pa.PropertyAddress,pa1.PropertyAddress) as generate_pa
From portfolioproject1.dbo.NashvilleHousing pa
JOIN portfolioproject1.dbo.NashvilleHousing pa1
	on pa.ParcelID = pa1.ParcelID
	AND pa.UniqueID <> pa1.UniqueID
Where pa.PropertyAddress is null

UPDATE pa
Set PropertyAddress = ISNULL(pa.PropertyAddress,pa1.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing pa
JOIN PortfolioProject1.dbo.NashvilleHousing pa1
	on pa.ParcelID = pa1.ParcelID
	AND pa.[UniqueID ] <> pa1.[UniqueID ]
Where pa.PropertyAddress is null



Select * from portfolioproject1.dbo.NashvilleHousing
where PropertyAddress is Null
order by ParcelID
--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State) using a proper delimeter

Select PropertyAddress, ParcelID
From portfolioproject1.dbo.NashvilleHousing
order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as PropertySplitCity
From portfolioproject1.dbo.NashvilleHousing

Alter table portfolioproject1.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE portfolioproject1.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter table portfolioproject1.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE portfolioproject1.dbo.NashvilleHousing 
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From portfolioproject1.dbo.NashvilleHousing

Select OwnerAddress, PropertyAddress
From portfolioproject1.dbo.NashvilleHousing

Select
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS OwnerSplitAddress,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2) AS OwnerSplitCity,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 2, LEN(OwnerAddress)) AS OwnerSplitState
From
  portfolioproject1.dbo.NashvilleHousing

Alter table portfolioproject1.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update portfolioproject1.dbo.NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1)

ALTER TABLE portfolioproject1.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update portfolioproject1.dbo.NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2)

ALTER TABLE portfolioproject1.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update portfolioproject1.dbo.NashvilleHousing
SET OwnerSplitState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 2, LEN(OwnerAddress))

Select *
From portfolioproject1.dbo.NashvilleHousing

--Select
--PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
--From portfolioproject1.dbo.NashvilleHousing

--ALTER TABLE NashvilleHousing
--Add OwnerSplitAddress Nvarchar(255);

--Update NashvilleHousing
--SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


--ALTER TABLE NashvilleHousing
--Add OwnerSplitCity Nvarchar(255);

--Update NashvilleHousing
--SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--ALTER TABLE NashvilleHousing
--Add OwnerSplitState Nvarchar(255);

--Update NashvilleHousing
--SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Select *
--From PortfolioProject1.dbo.NashvilleHousing
--works well but i have decided to use SUBSTRING for both owner and property address but the parsename works fine too
--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolioproject1.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
  CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END as fixedcol
From portfolioproject1.dbo.NashvilleHousing

Update portfolioproject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

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
From PortfolioProject1.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by ParcelID

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
From PortfolioProject1.dbo.NashvilleHousing
)
delete
From RowNumCTE
Where row_num > 1

Select *
From portfolioproject1.dbo.NashvilleHousing



--DELETE FROM portfolioproject1.dbo.NashvilleHousing
--WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) NOT IN (
--  SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
--  FROM (
--    SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,
--           ROW_NUMBER() OVER (
--             PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
--             ORDER BY UniqueID
--           ) AS row_num
--    FROM portfolioproject1.dbo.NashvilleHousing
--  ) AS Subquery
--  WHERE row_num > 1
--)

---------------------------------------------------------------------------------------------------------

-- Delete Columns that has been refined

Select *
From portfolioproject1.dbo.NashvilleHousing


Alter table PortfolioProject1.dbo.NashvilleHousing
Drop column OwnerAddress, PropertyAddress, SaleDate