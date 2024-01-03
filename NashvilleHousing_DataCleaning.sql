Select*
From [Portfolio Project]..NashvilleHousing

--Standardize Date Format

Select SaleDateConverted
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Alter Column SaleDate Date
Add SaleDateConverted Date;

Update [Portfolio Project]..NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
From [Portfolio Project]..NashvilleHousing
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Address into Individual Columns (Address, City, State)
	
	-- To Modify Property address
Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) as City
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertyAlteredAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertyAlteredAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertyAlteredCity nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertyAlteredCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) )

	--To Modify Owner Address
Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerAlteredAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerAlteredAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerAlteredCity nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerAlteredCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerAlteredState nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerAlteredState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant"

Select  Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End
From [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End


--Remove Duplicates

With RowNumCTE as(
Select *,
	Row_Number() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From [Portfolio Project]..NashvilleHousing
)

Select* 
From RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused columns

Select *
From [Portfolio Project]..NashvilleHousing
Alter Table [Portfolio Project]..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress