/*

Cleaning Data in SQL Queries

Skills used: Joins, CTE's, Temp Tables, Windows Functions, SQL Server String Functions, Creating Views, Altering Tables, CASE


*/


Select *
From [SQL Portfolio]..NashvilleHousing

-------------------------------------------------------------------------

-- Standardize Date Formate (Remove Time)

Update NashvilleHousing /*Doesn't work every time*/
SET SaleDate = Cast(SaleDate as date);

-- Alternative:
Alter table NashvilleHousing alter column SaleDate date; 

--------------------------------------------------------------------------

--Populate Property Address data

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [SQL Portfolio]..NashvilleHousing a
JOIN [SQL Portfolio]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null

Select *
From [SQL Portfolio]..NashvilleHousing
Where PropertyAddress is NUll

-------------------------------------------------------------------------

-- Breaking out Address into induvidual Columns (Address, City, State)

-- 1) Propertyaddress (Address + City)
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = LEFT(PropertyAddress,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))

--2) Owneraddress (Address, City, State)

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',','.'),1)


-------------------------------------------------------------------------

--Replace Y to Yes and N to No in "Sold as Vacant" field

Update NashvilleHousing
SET SoldAsVacant =
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End


-------------------------------------------------------------------------

--Remove Duplicates and save it in a Temp Table

Drop table if exists #NashvilleHousingClean
Create Table #NashvilleHousingClean (
[UniqueID ] float primary key 
      ,[ParcelID] nvarchar(255)
      ,[LandUse] nvarchar(255)
      ,[PropertyAddress] nvarchar(255)
      ,[SaleDate] date
      ,[SalePrice] float
      ,[LegalReference] nvarchar(255)
      ,[SoldAsVacant] nvarchar(255)
      ,[OwnerName] nvarchar(255)
      ,[OwnerAddress] nvarchar(255)
      ,[Acreage] float
      ,[TaxDistrict] nvarchar(255)
      ,[LandValue] float
      ,[BuildingValue] float
      ,[TotalValue] float
      ,[YearBuilt] float
      ,[Bedrooms] float
      ,[FullBath] float
      ,[HalfBath] float
      ,[PropertySplitAddress] nvarchar(255)
      ,[PropertySplitCity] nvarchar(255)
      ,[OwnerSplitAddress] nvarchar(255)
      ,[OwnerSplitCity] nvarchar(255)
      ,[OwnerSplitState] nvarchar(255)
	  ,[Row_Num] numeric
)

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by UniqueID) row_num
From NashvilleHousing
)

Insert Into #NashvilleHousingClean
Select *
From RowNumCTE
Where row_num = 1


-------------------------------------------------------------------------

-- Delete Unused Columns

Alter Table #NashvilleHousingClean
Drop Column OwnerAddress, TaxDistrict, PropertyAddress
