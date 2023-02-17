--CLEANING DATA IN SQL QUERIES USING THE NASHVILLE HOUSING DATA

select * from NashvilleHousing

select SaleDate from [dbo].[NashvilleHousing]

--Standardize Date Format
select saledate, CONVERT(date,saledate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--Populate Property Address data
select * from NashvilleHousing
--where PropertyAddress is null
order by parcelid

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Spliting PropertyAddress into Into Individual Columns (Address, City)
select PropertyAddress from NashvilleHousing

select  
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress) -1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress)) as city
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1,CHARINDEX(',',propertyaddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress))

--Splitting Owner Address into individual columns (Address,City,State)
select OwnerAddress from NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3) as address,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state 
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "SoldAsVacant" column
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from NashvilleHousing

UPDATE NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--REMOVE DUPLICATES

WITH RowNumCTE as(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by UniqueID
				) row_num
			
from NashvilleHousing
--order by ParcelID
)

select * from RowNumCTE
where row_num >1
order by PropertyAddress

--DELETE UNUSED COLUMNS
select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate