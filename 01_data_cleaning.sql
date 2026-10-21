--INSPECTING RAW DATA (LAYOFFS TABLE)
SELECT *
FROM layoffs;

-- CREATE STAGING DUPLICATE TO PRESERVE RAW DATA
CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs;

/*
REMOVING DUPLICATES
    -INSERT A ROW NUMBER COLLUMN, PARTITIONED BY EVERY COLUM TO IDENTIFY DUPLICATES
*/
SELECT *,
ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage,
            country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- FILTERING TO RETURN EVERY DUPLICATE RECORD
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage,
            country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

/*CREATE ANOTHER DUPLICATE TABLE WHERE THE ROW NUMBER COLUMN IS AN ORIGINAL COMPONENT
    (NEW DUPLICATE "layoffs_staging2" = OLD DUPLICATE "layoffs_staging" + ROW NUMBER COLUMN)
    -WILL ALLOW FOR FILTERING TO PERMANENTLY DELETE DUPLICATES
*/
CREATE TABLE layoffs_staging2 AS
SELECT 
    *,
    ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage,
                country, funds_raised_millions
                ) AS row_num
FROM layoffs_staging

--DELETING EVERY DEPLICATE RECORD
DELETE
FROM layoffs_staging2
WHERE row_num > 1

--QUICK QUERYING TO CONFIRM DELETION OF DUPLICATES
SELECT *
FROM layoffs_staging2
WHERE row_num > 1

/*DATA STANDARDIZATION 
    -TRIMMING "company" COLUMN FOR UNWANTED SPACING
*/
SELECT company, TRIM(company)
FROM layoffs_staging2


UPDATE layoffs_staging2
SET company = TRIM(company)

-- STANDARDIZING EVERY "Cryptocurrency" & "Crypto Currency" RECORD TO "Crypto"
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'

--TRIMMING TRAILING '.' FROM RECORDS IN THE "country" COLUMN
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

--PROPERLY FORMATTING THE date COLUMN
ALTER TABLE layoffs_staging2
ALTER COLUMN date TYPE DATE



