--data cleaning
SELECT *
FROM layoffsde1..layoffs
ORDER BY date desc;


--creating another dataset so as to keep the raw data intact
SELECT *
INTO layoffs_staging
FROM layoffsde1..layoffs
WHERE 1 = 0;

SELECT * 
FROM layoffs_staging
ORDER BY date DESC;

INSERT INTO layoffs_staging
SELECT *
FROM layoffsde1..layoffs;

--1. Removing duplicates from the data
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
ORDER BY date) AS CNT
FROM layoffs_staging;

--CERATING A CTE 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
ORDER BY date) AS CNT
FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE CNT>1;


--DOUBLE CHECKING THE DUPLICATES
SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; --OR company = 'Cazoo';

--CREATE A NEW TABLE WITH DATA FROM CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
ORDER BY date) AS CNT
FROM layoffs_staging)
SELECT *
INTO layoffs_staging2
FROM duplicate_cte;

SELECT *
FROM layoffs_staging2
ORDER BY date DESC;

--2. Check formats and standardize the data LIKE REMOVING WHITESPACES
SELECT company, TRIM(company)
FROM layoffs_staging2;

--UPDATING THE COMPANY COLUMN WITH REMOVED WHITESPACES
UPDATE layoffs_staging2
SET company = TRIM(company);

--LOOKING AT INDUSTRIES COLUMN
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

--UPDATING A COUPLE OF INDUSTRIES WHERE THEY ARE SAME
SELECT *
FROM layoffs_staging2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE industry = 'Transportation' or industry = 'Travel';


--LOOKING AT LOCATION
SELECT DISTINCT location
FROM layoffs_staging2
order by 1;
--Malmö
UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location like 'Malm%';

--LOOKING AT COUNTRY
SELECT distinct country
FROM layoffs_staging2
order by 1;
--Malmö
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country like 'United Stat%';

--CHANGING THE FORMAT OF THE DATE
SELECT date
from layoffs_staging2;

SELECT date
FROM layoffs_staging2
WHERE ISDATE(date) = 0;

SELECT 
    CASE 
        WHEN ISDATE(date) = 1 THEN CONVERT(DATE, date, 101)
        ELSE NULL  -- or handle the invalid data case as needed
    END AS formatted_date
FROM layoffs_staging2;

SELECT CONVERT(DATE, date, 101) AS formatted_date
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
ADD formatted_date DATE;



UPDATE layoffs_staging2
SET date = TRY_CONVERT(DATE, date, 101);

ALTER TABLE layoffs_staging2
DROP COLUMN formatted_date;

--changing the date format to date
USE layoffsde1;

ALTER TABLE layoffs_staging2
ALTER COLUMN date DATE;

--3. Dealing with NULL and Blank values
SELECT *
FROM layoffs_staging2
ORDER BY date DESC;

--looking at percentage laid off and total laid off values
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL ;

UPDATE layoffs_staging2
SET percentage_laid_off = CAST(percentage_laid_off AS FLOAT) 
WHERE ISNUMERIC(percentage_laid_off) = 1; 

SELECT *
FROM layoffs_staging2
WHERE (percentage_laid_off IS NULL OR percentage_laid_off = '')
AND total_laid_off IS NULL;

--doesnt work
SELECT CAST(percentage_laid_off AS FLOAT) AS percentage_laid_off
FROM layoffs_staging2;
SELECT CONVERT(FLOAT, percentage_laid_off) AS ConvertedFloatColumn
FROM layoffs_staging2;
--chaning the data type to float
SELECT TRY_CAST(percentage_laid_off AS FLOAT) AS ConvertedFloatColumn
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET percentage_laid_off = TRY_CAST(percentage_laid_off AS FLOAT);


--looking at industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


--self joining tables to be able to populate null or blank values
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
	AND t1.location=t2.location
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry is NOT NULL;

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
INNER JOIN layoffs_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


--4. Removng unecessary rows/columns
SELECT *
FROM layoffs_staging2;


DELETE
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL ;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL ;

ALTER TABLE layoffs_staging2
DROP COLUMN CNT;