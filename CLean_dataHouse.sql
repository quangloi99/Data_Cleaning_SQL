--use database
use Covid_19
go
--select data
select * from [dbo].[Housedata]

--1.Convert saleDate to  type date
Select saleDate, CONVERT(Date,SaleDate)
From Housedata

update Housedata
set saleDate = CONVERT(Date,SaleDate)

----2. Populate Property Address data
select * from Housedata
where PropertyAddress is null
--- find null Property Adress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housedata a
JOIN Housedata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
order  by a.ParcelID

--update null values in column Property Adress
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housedata a
JOIN Housedata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--3.Split column PropertyAddress two columns: PropertySplitAddress, PropertySplitCity

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Housedata


ALTER TABLE Housedata
Add PropertySplitAddress Nvarchar(255);

Update Housedata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housedata
Add PropertySplitCity Nvarchar(255);

Update Housedata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select * from Housedata

--4.Split columns OwnerAddress
select a.OwnerAddress  from Housedata a

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Housedata
---add columns
ALTER TABLE Housedata
Add OwnerSplitAddress Nvarchar(255);

Update Housedata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Housedata
Add OwnerSplitCity Nvarchar(255);

Update Housedata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Housedata
Add OwnerSplitState Nvarchar(255);

Update Housedata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
--recheck table Housedata 
select * from Housedata 

--5.Change Y, N in columns SoldAsVacant
-- view data
select distinct(SoldAsVacant),count(SoldAsVacant)
from Housedata
group by SoldAsVacant
order by 2
-- Change 
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Housedata


Update Housedata
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
--6.Remove duplicate values
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

From Housedata
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--7.Delete Unused Columns
---------
Select *
From Housedata
---------
ALTER TABLE Housedata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
