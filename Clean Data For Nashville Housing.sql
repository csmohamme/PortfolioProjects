/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

--------------------------------------------
-- Standardize Date Format

SELECT SaleDate,CONVERT(date,SaleDate)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted date


UPDATE NashvilleHousing
SET SaleDateConverted = SaleDate


SELECT SaleDateConverted
FROM NashvilleHousing


--------------------------------------------
-- Populate Property Address Date 

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is null


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


--------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing 

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySpliAddress NVARCHAR(255),
PropertySpliCITY NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySpliAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertySpliCITY=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySpliAddress,PropertySpliCITY
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSpliAddress NVARCHAR(255),
OwnerSpliCity NVARCHAR(255),
OwnerSpliState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSpliAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSpliCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSpliState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSpliAddress,OwnerSpliCity,OwnerSpliState
FROM NashvilleHousing

--------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant,
Case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
FROM NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

--------------------------------------------
-- Remove Duplicates


Select *
FROM NashvilleHousing

with RowNumberCte as(
Select *,ROW_NUMBER() Over(
Partition By ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference Order By [UniqueID ]) as row_num
FROM NashvilleHousing
)
Select * 
From RowNumberCte
Where row_num > 1


--------------------------------------------
-- Delete Unused Columns

Select *
FROM NashvilleHousing

Alter table NashvilleHousing
Drop Column PropertyAddress,OwnerAddress,SaleDate,TaxDistrict