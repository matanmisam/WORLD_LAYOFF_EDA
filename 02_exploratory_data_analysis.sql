/* EXPLORATORY DATA ANALYSIS ON CLEANED WORLD LAYOFFS DATASET
    DATA RANGE - MARCH 11th 2020 to MARCH 6th 2023
*/

SELECT *
FROM layoffs_staging2


/* MAX NUMBER OF EMPLOYEES LAID OFF AT ONCE AND 
MAX PERCENTAGE OF EMPLOYEES LAID OFF*/
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2


-- DATA FOR COMPANIES THAT COMPLETELY DISSOLVED I.E 100% EMPLOYEE LAYOFF
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = '100'
AND total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC

-- INDUSTRIES WITH THE MOST LAYOFFS
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC

-- COUNTRIES WITH THE MOST LAYOFFS
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC

-- TOTAL NUMBER OF LAYOFFS PER YEAR
SELECT EXTRACT(YEAR FROM date) AS YEAR, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
AND date IS NOT NULL
GROUP BY YEAR
ORDER BY 1 DESC

-- TOTAL NUMBER OF LAYOFFS BY COMPANY STAGES
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC

-- SUM OF LAYOFFS EVERY MONTH THROUGHOUT THE DATA RANGE
SELECT SUBSTRING(date::TEXT,1,7) AS MONTH, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date::TEXT,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY MONTH ASC


--ROLLING TOTAL SUM OF LAYOFFS EVERY MONTH
WITH Rolling_Total AS
(
    SELECT SUBSTRING(date::TEXT,1,7) AS MONTH, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(date::TEXT,1,7) IS NOT NULL
    GROUP BY MONTH
    ORDER BY MONTH ASC
)
SELECT MONTH, total_off,SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM Rolling_Total


--TOP 5 COMPANIES BASED ON TOTAL LAYOFFS PER YEAR
SELECT company, EXTRACT(YEAR FROM date) AS YEAR, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR
ORDER BY 3 DESC

WITH Company_year AS
(
    SELECT company, EXTRACT(YEAR FROM date) AS YEARS, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE total_laid_off IS NOT NULL
    GROUP BY company, YEARS
    ORDER BY 3 DESC
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY YEARS ORDER BY total_laid_off DESC) AS Ranking
FROM Company_year
WHERE YEARS IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5


--AVERAGE MONTHLY LAYOFF
WITH total_per_month AS
(
    SELECT SUBSTRING(date::TEXT,1,7) AS months, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(date::TEXT,1,7) IS NOT NULL
    GROUP BY 1
    ORDER BY 1
)
SELECT months, ROUND(AVG(total_off)) AS Average_layoff
FROM total_per_month
GROUP BY months
ORDER BY 1
