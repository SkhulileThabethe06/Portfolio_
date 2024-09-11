

/*
Cleaning data
*/

SELECT * FROM PortfolioProject..NashvilleHousing;

-----------------------------------------------
--Standardize date format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing;

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate);

alter table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing  
SET SaleDateConverted = CONVERT(date,SaleDate)

------------------------------------------------

-- populate property address

SELECT * FROM PortfolioProject..NashvilleHousing
where PropertyAddress is null;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 where a.PropertyAddress is null;


update a
set PropertyAddress =  isnull(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 where a.PropertyAddress is null


----------------------------------------------------------
--Breaking out Address into individual columns (Address, City ,State)

select * from PortfolioProject..NashvilleHousing;

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing;


alter table NashvilleHousing
add PropertySplitAddress nvarchar(225);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(225);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress));


--easy way

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(225);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


alter table NashvilleHousing
add OwnerSplitCity nvarchar(225);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


alter table NashvilleHousing
add OwnerSplitState nvarchar(225);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



-----------------------------------------------------------------------------------------------------------------


-- change Y and N  to TES and NO in Vacant field

select distinct (SoldAsVacant) , Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant;

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
      from PortfolioProject..NashvilleHousing



update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end



----------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(
select *,
       ROW_NUMBER() over (
       partition by ParcelID,
	   PropertyAddress,
	   SaleDate,
	   LegalReference 
	   order by
	   ParcelID)
	   row_num
 from PortfolioProject..NashvilleHousing )
 select *  from RowNumCTE where row_num > 1 




 -----------------------------------------------------------------------------------------------
 -- delete unused columns

 select * from  PortfolioProject..NashvilleHousing

 alter table PortfolioProject..NashvilleHousing
 drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate