-- Data Cleaning Project 2-7-2024

SELECT *
FROM layoffs;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values or blank values 
-- 4. remove any columns and rows that are not necessary - few ways (not always the case, depending the conditions of the data. Do not remove columns from raw datasets at workplace)


-- Create a new table and copy the data from the raw dataset to work on.
-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Now we insert the data
INSERT layoffs_staging 
SELECT * 
FROM layoffs;

-- Why do we need to create the staging data? Because we will be making lot of changes on the data and if any error occur, we will want to have raw dataset to fall back on.
-- Do not work on the raw data.

-- Begin Data Cleaning
-- 1 Removing Duplicates
SELECT *,
ROW_NUMBER() OVER( 
	PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Now, let's put it in a CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( 
	PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, `date`, stage, country,
    funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( 
	PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, `date`, stage, country,
    funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

DROP TABLE IF EXISTS `layoffs_staging2`;
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
	PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, `date`, stage, country,
    funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;

SELECT *
from layoffs_staging2;

-- 2. Standardizing Data - This is finding issues in the data and fixing them

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
from layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United State%';       

SELECT *
from layoffs_staging2;          

SELECT `date`,
STR_TO_DATE (`date`, '%m/%d%Y')
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- now we can convert the data type properly. Do not do this on the raw dataset.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
or industry = '';

select *
From layoffs_staging2
Where company = 'Airbnb';

select t1.industry, t2.industry
From layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry is not null;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry is not null;

-- When treating null values in the data, check for similarrities in the columns, then fill the one's similar. Do not just delete null columns.
-- Now lets look up another company
select *
From layoffs_staging2
Where company LIKE 'Bally%';

select *
From layoffs_staging2;

-- 4. remove any columns and rows we need to
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- since we might not be needing those columns that is populated with null values, we can delete them
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



-- NOW WE HAVE A CLEANED DATA
