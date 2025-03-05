/*

Data Cleaning in SQL

This project enable me to perform indebt analysis on a housing data from 2018, leading to insightful analyses and high-quality data for analyst to use seemlessly.

Techniques used include checking annd removing duplicate, deleting unused columns, replacing values,satndardizing data, etc.

*/


select *
from Projects..housingdata
order by 1


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select saledate, CONVERT(Date, saledate)
from Projects..housingdata




Update housingdata
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE housingdata
Add SaleDateConverted Date;

Update housingdata
SET SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from Projects..housingdata


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select propertyaddress    --- Check to see if there are null values
from Projects..housingdata
where PropertyAddress is null

select *
from Projects..housingdata
--where PropertyAddress is null
order by ParcelID


-- Do a self join to populate the PropertyAddresses which have same ParcelID

select *
from Projects..housingdata a
JOIN Projects..housingdata b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Projects..housingdata a
JOIN Projects..housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--This query will populate what is in the new column in PropertyAddress
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Projects..housingdata a
JOIN Projects..housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Update
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Projects..housingdata a
JOIN Projects..housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Now there are no NULL values in PropertyAddress column..




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from Projects..housingdata
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM Projects..housingdata
--order by 1


ALTER TABLE housingdata
Add PropertyAddressSplit Nvarchar(255);

Update housingdata
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE housingdata
Add PropertyCitySplit Nvarchar(255);

Update housingdata
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




select *
from Projects..housingdata





select OwnerAddress
from Projects..housingdata

--Using PARSENAME instead of SUBSTRING
select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Projects..housingdata



ALTER TABLE housingdata
Add OwnerAddressSplit Nvarchar(255);

Update housingdata
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE housingdata
Add OwnerCitySplit Nvarchar(255);

Update housingdata
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE housingdata
Add OwnerStateSplit Nvarchar(255);

Update housingdata
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Projects..housingdata




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Projects..housingdata
Group by SoldAsVacant
order by 2



--Using CASE Statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Projects..housingdata

--Update
Update housingdata
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

From Projects..housingdata
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Projects..housingdata




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from Projects..housingdata


ALTER TABLE Projects..housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate