/*
Portfolio project
	Cleaning data:
		.Populate values null
		.Breaking out a attribute into individual Columns
		.Edit wrong values in attributes
		.ALTER,UPDATE TABLE
		.Add,delete column
		.Remove duplicate values
	
*/	

DROP TABLE IF EXISTS Nashville_Housing

CREATE TABLE Nashville_Housing(
	UniqueID INT,
	ParcelID VARCHAR(20),
	LandUse VARCHAR(50),
	PropertyAddress VARCHAR(100),
	SaleDate DATE,
	SalePrice NUMERIC,
	LegalReference VARCHAR(50),
	SoldAsVacant BOOLEAN,
	OwnerName VARCHAR(100),
	OwnerAddress VARCHAR(150),
	Acreage DECIMAL(10,2),
	TaxDistrict VARCHAR(100),
	LandValue NUMERIC,
	BuildingValue NUMERIC,
	TotalValue NUMERIC,
	YearBuilt NUMERIC,
	Bedrooms NUMERIC,
	FullBath NUMERIC,
	HalfBath NUMERIC
)


--importando la data a psql
--Import data to psql

COPY Nashville_Housing 
FROM 'C:\Users\LENOVO\Desktop\PORTAFOLIO\3 de 4 - Limpieza de datos\Nashville Housing Data for Data Cleaning.csv'
DELIMITER ','
CSV HEADER 




--Cleaning data in SQL Queries


SELECT
	*
FROM Nashville_Housing

----------------------------------------------

--Populate property Address data
SELECT
	*
FROM Nashville_Housing
--WHERE propertyaddress IS NULL
ORDER BY parcelid 


---Uniedo la misma tabla por parcelid,
--Diferenciandola por uniqueid
--complentando 'propertyaddress' para los valores null
SELECT
	a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,
	COALESCE(a.propertyaddress,b.propertyaddress) AS changeAdress
FROM 
Nashville_Housing a 
	JOIN
Nashville_Housing b ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL


--Populating values null

UPDATE Nashville_Housing a 
SET propertyaddress = COALESCE(a.propertyaddress,b.propertyaddress)
FROM 
Nashville_Housing b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL
-----
--Verificando que los datos se hayan unido correctamente 
-- Checking data have been correct cross join 
SELECT a.parcelid,
       a.propertyaddress AS old_propertyaddress,
       COALESCE(a.propertyaddress, b.propertyaddress) AS new_propertyaddress
FROM Nashville_Housing a
JOIN Nashville_Housing b ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

--THE DATA IS PERFECT!

------------------------------------
--Breaking out Address into individual Columns (Adress, city)
--Separando las direcciones en columnas individuales ( Direccion, ciudad)
--Usamos la funcion "Split_part"
SELECT
	propertyaddress
FROM Nashville_Housing


--------------
--Separando los valores en columnas 'Address', 'city'
--Breaking out values in columns 'Address', 'city'

SELECT
	SPLIT_PART(propertyaddress, ',',1) AS Address,
	SPLIT_PART(propertyaddress, ',',2) AS City
FROM Nashville_Housing

--adding new columns to database
--Agregando las nuevas columnas a la base de datos

--Adding 'Address'
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress VARCHAR(255)

--Actualizando 'Address'
UPDATE Nashville_Housing
SET PropertySplitAddress = SPLIT_PART(propertyaddress, ',',1)

--Adding 'city'
ALTER TABLE Nashville_Housing
ADD PropertySplitCity VARCHAR(255)

--Actualizando 'City'
UPDATE Nashville_Housing
SET PropertySplitCity = SPLIT_PART(propertyaddress, ',',2)


--Checking at new columns in database
--Verificando las nuevas columnas en la base de datos

SELECT
	propertyaddress, propertysplitaddress, PropertySplitCity
FROM Nashville_Housing

--Si quieres, ya puedes eliminar la columna set 'propertyaddress' del dataset
--If you want to, already you can delete set column 'propertyaddress' to database

/*
ALTER TABLE Nashville_Housing
DROP COLUMN propertyaddress
*/


--Separando en columnas el atributo 'owneraddress'
--Breaking out Address into individual Columns (Adress, city, State)
SELECT
	owneraddress,
	SPLIT_PART(owneraddress, ',',1),
	SPLIT_PART(owneraddress, ',',2),
	SPLIT_PART(owneraddress, ',',3)
FROM Nashville_Housing


--Adding 'OwnerSplitAddress'
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress VARCHAR(255)

--Actualizando 'OwnerSplitAddress'
UPDATE Nashville_Housing
SET OwnerSplitAddress = SPLIT_PART(owneraddress, ',',1)


--Adding 'OwnerSplitCity'
ALTER TABLE Nashville_Housing
ADD OwnerSplitCity VARCHAR(255)

--Actualizando 'OwnerSplitCity'
UPDATE Nashville_Housing
SET OwnerSplitCity = SPLIT_PART(owneraddress, ',',2)


--Adding 'OwnerSplitState'
ALTER TABLE Nashville_Housing
ADD OwnerSplitState VARCHAR(255)

--Actualizando 'OwnerSplitState'
UPDATE Nashville_Housing
SET OwnerSplitState = SPLIT_PART(owneraddress, ',',3)


--Checking at new columns in database
--Verificando las nuevas columnas en la base de datos

SELECT
	owneraddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Nashville_Housing
ORDER BY 1 
--DATA IS PERFECT!
-------------------------------------------------------


--Change 'Y' and 'N' to 'yes' and 'No' in "Sold as Vacant" field
--If we'd differents values to 'Yes' and 'No' usamos 'Case - When'

SELECT
	DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM Nashville_Housing
GROUP BY soldasvacant
--WHERE soldasvacant = 'N'

-- CHANGE WRONG VALUES IF IN CASE WE HAD
SELECT 
	soldasvacant, 
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
FROM Nashville_Housing

--REPLACE VALUES IN DATABASE

UPDATE Nashville_Housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 		    WHEN soldasvacant = 'N' THEN 'No'
					ELSE soldasvacant
					END


--CHEKING DATA!

SELECT
	DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM Nashville_Housing
GROUP BY soldasvacant

-- DATA IT'S PERFECT


--Eliminando filas duplicadas
---Remove Duplicates rows

--USING CTE(common table expression)

WITH filas_numeradas AS (
SELECT
	ctid,
	ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress,saledate, saleprice, legalreference) AS row_num
FROM Nashville_Housing
)

--Deleting duplicates rows
DELETE 
FROM Nashville_Housing
WHERE ctid IN (
	SELECT ctid
	FROM filas_numeradas
	WHERE row_num>1
)

--Checking data


WITH filas_numeradas AS (
SELECT
	ctid,
	ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress,saledate, saleprice, legalreference) AS row_num
FROM Nashville_Housing
)

SELECT	*

FROM filas_numeradas
	WHERE row_num>1

--DATA IS PERFECT!
-------------------


--Lastly, 
--delete unused columns
--DELETE: propertyaddress, owneraddress, taxdistrict, saledate

--DELETING 'propertyaddress','owneraddress', 'taxdistrict', 'saledate'
ALTER TABLE Nashville_Housing
DROP COLUMN propertyaddress, 
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN saledate


SELECT
	*
FROM Nashville_Housing

--It's okay
--Database it's perfect






