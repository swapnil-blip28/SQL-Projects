--Cleaning data in SQL

Select *
From HousingProject.dbo.NashvilleHousing


-- Date format with and without time

Select SaleDate
From HousingProject.dbo.NashvilleHousing

SELECT CONVERT(DATETIME, SaleDate) AS SaleDateWithTime
FROM HousingProject.dbo.NashvilleHousing


-- Populate property address data

Select *
From HousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From HousingProject.dbo.NashvilleHousing A
JOIN HousingProject.dbo.NashvilleHousing B
On A.ParcelID = B.ParcelID
And A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From HousingProject.dbo.NashvilleHousing A
JOIN HousingProject.dbo.NashvilleHousing B
On A.ParcelID = B.ParcelID
And A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null


--Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
From HousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From HousingProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM HousingProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From HousingProject.dbo.NashvilleHousing


--Or


Select OwnerAddress
From HousingProject.dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',','.'),3),
Parsename(Replace(OwnerAddress, ',','.'),2),
Parsename(Replace(OwnerAddress, ',','.'),1)
From HousingProject.dbo.NashvilleHousing


-- Comment


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'),1)


Select *
From HousingProject.dbo.NashvilleHousing


--Change 0 and 1 to No and Yes in "SoldAsVacant" field

ALTER TABLE HousingProject.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(10)

UPDATE HousingProject.dbo.NashvilleHousing
SET SoldAsVacant = 
  CASE 
    WHEN SoldAsVacant = '0' THEN 'No'
    WHEN SoldAsVacant = '1' THEN 'Yes'
    ELSE SoldAsVacant
  END

Select Distinct (SoldAsVacant), Count(SoldAsVacant) as Vacancy
From HousingProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



--Removing duplicates

With RowNumCTE AS(
Select *,
Row_Number() Over (
Partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by
UniqueID) As Row_num
From HousingProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where Row_num > 1
Order by PropertyAddress



-- Delete unused columns

Select *
From HousingProject.dbo.NashvilleHousing

Alter Table HousingProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress




Select *
From HousingProject.dbo.NashvilleHousing








