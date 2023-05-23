/*

Cleaning Data in SQL Queries

*/

Select *
From master..NashvilleHousing

--Standardize Data Format

Select SaleDate, CONVERT(Date,SaleDate)
From master..NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


-- Populate Proprety Address data


Select *
From master..NashvilleHousing
--where PropertyAddress is null
order by parcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From master..NashvilleHousing a
JOIN master..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From master..NashvilleHousing a
JOIN master..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out address into individual columns (address, city, state) 


Select PropertyAddress
From master..NashvilleHousing
--where PropertyAddress is null
--order by parcelID

select
substring(propertyaddress, 1, charindex(',', PropertyAddress)-1) as address
, substring(propertyaddress, charindex(',', PropertyAddress) +1, len(propertyaddress)) as address
From master..NashvilleHousing


ALTER TABLE NashvilleHousing
add propertysplitaddress  nvarchar(255);

update NashvilleHousing
SET propertysplitaddress = substring(propertyaddress, 1, charindex(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
add propertysplitcity nvarchar (255);

update NashvilleHousing
SET propertysplitcity = substring(propertyaddress, charindex(',', PropertyAddress) +1, len(propertyaddress))

select *
From master..NashvilleHousing



select OwnerAddress
From master..NashvilleHousing

select
PARSENAME(REPLACE(owneraddress,',','.'), 3)
,PARSENAME(REPLACE(owneraddress,',','.'), 2)
,PARSENAME(REPLACE(owneraddress,',','.'), 1)
From master..NashvilleHousing

ALTER TABLE NashvilleHousing
add ownersplitaddress  nvarchar(255);

update NashvilleHousing
SET ownersplitaddress  = PARSENAME(REPLACE(owneraddress,',','.'), 3)

ALTER TABLE NashvilleHousing
add ownersplitcity nvarchar (255);

update NashvilleHousing
SET ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'), 2)

ALTER TABLE NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'), 1)

--Change Y and N to Yes and No in "sold as vacant" field

select distinct(soldasvacant), count(soldasvacant)
From master..NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant
,	case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		ELSE soldasvacant
		END
From master..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		ELSE soldasvacant
		END
From master..NashvilleHousing


-- Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
		PARTITION BY parcelID,
					propertyaddress,
					saleprice,
					saledate,
					legalreference
					order by 
					uniqueID
					) row_num
From master..NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
--order by propertyaddress 




-- Delete Unused Columns

select *
From master..NashvilleHousing

ALTER TABLE master..NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE master..NashvilleHousing
DROP COLUMN saledate