select * from Nashville_Housing

--standarize date formate
select SaleDateConverted , convert(Date,saledate) from Nashville_Housing

ALTER TABLE Nashville_Housing 
ADD SaleDateConverted Date;

update Nashville_Housing 
set SaleDateConverted = CONVERT(Date,saledate)

--populate property address data
select * from Nashville_Housing 
--where PropertyAddress is null 
order by parcelid

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress from Nashville_Housing

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Nashville_Housing

Alter table nashville_Housing
add PropertySplitAddress NVarchar(255)

update Nashville_Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

Alter table nashville_Housing
add PropertySplitCity NVarchar(255)

update Nashville_Housing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))

select OwnerAddress from Nashville_Housing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Nashville_Housing

Alter table Nashville_Housing
add OwnerSplitAddress NVarchar(255)

update Nashville_Housing
set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table Nashville_Housing
add OwnerSplitCity NVarchar(255)

update Nashville_Housing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter table Nashville_Housing
add OwnerSplitState NVarchar(255)

update Nashville_Housing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
select Distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2

update Nashville_Housing
set SoldAsVacant= case when SoldAsVacant= 'Y' then 'Yes'
when SoldAsVacant= 'N' then 'No'
else SoldAsVacant
end

-- Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by uniqueID
) row_num
from nashville_Housing
)Select * from RowNumCTE where row_num >1
order by PropertyAddress

DELETE from RowNumCTE where row_num > 1

-- Delete Unused Columns

Alter table nashville_Housing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * from Nashville_Housing











