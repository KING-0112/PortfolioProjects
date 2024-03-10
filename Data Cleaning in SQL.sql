/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProjectV2..NashvilleHousing

===================================================

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProjectV2..NashvilleHousing

==================================================

-- Populate Property Address Data

Select *
From PortfolioProjectV2..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress),
b.ParcelID, b.PropertyAddress
From PortfolioProjectV2..NashvilleHousing a
JOIN PortfolioProjectV2..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectV2..NashvilleHousing a
JOIN PortfolioProjectV2..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- test to see if the Property Address NULLS are updated

Select *
From PortfolioProjectV2..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

===================================================

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjectV2..NashvilleHousing

Select
Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProjectV2..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProjectV2..NashvilleHousing


Select OwnerAddress
From PortfolioProjectV2..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.') ,3),
Parsename(Replace(OwnerAddress, ',', '.') ,2),
Parsename(Replace(OwnerAddress, ',', '.') ,1)
From PortfolioProjectV2..NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.') ,3)

Alter table NashvilleHousing
Add  OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.') ,2)

Alter table NashvilleHousing
Add  OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProjectV2..NashvilleHousing


===================================================

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjectV2..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProjectV2..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

===================================================

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) row_num
From PortfolioProjectV2..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1


Select *
From PortfolioProjectV2..NashvilleHousing

===================================================

-- Remove unused Columns

Select *
From PortfolioProjectV2..NashvilleHousing


Alter TABLE PortfolioProjectV2..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE PortfolioProjectV2..NashvilleHousing
DROP COLUMN SaleDate