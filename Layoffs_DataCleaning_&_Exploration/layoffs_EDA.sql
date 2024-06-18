--Exploratory Analysis
SELECT *
FROM layoffs_staging2;

--Analysis of total_laid_off
SELECT MAX(total_laid_off) AS Highest_Laid_Off, MAX(percentage_laid_off) AS Highest_Percentage
FROM layoffs_staging2;

--converting the percentage column to flaot

/*--SELECT TRY_CAST(percentage_laid_off AS FLOAT) AS ConvertedFloatColumn
FROM layoffs_staging2;
--updating the column
UPDATE layoffs_staging2
SET percentage_laid_off = TRY_CAST(percentage_laid_off AS FLOAT);
COMMIT;




SELECT percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;





SELECT COUNT(*) 
FROM layoffs_staging2 
WHERE percentage_laid_off IS NULL;



UPDATE layoffs_staging2
SET percentage_laid_off = CAST(percentage_laid_off AS FLOAT);

*/
--this worked
ALTER TABLE layoffs_staging2
ALTER COLUMN percentage_laid_off FLOAT;

--to check data types
EXEC sp_help 'layoffs_staging2';


SELECT *
FROM layoffs_staging2
where percentage_laid_off = 1
order by 9 desc;


--parameters vs total_laid_off
--total people laid off in a company 
SELECT company, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY company
order by 2 desc;

--start date and most recent date inside data
SELECT MIN(date),MAX(date)
FROM layoffs_staging2;


--industries that were hit the most
SELECT industry, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY industry
order by 2 desc;

--countries that laid off the most
SELECT country, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY country
order by 2 desc;

--year vs total laid off
SELECT YEAR(date) as Year, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY YEAR(date)
order by 1 desc;

--company stage vs total_laid_off
SELECT stage, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY stage
order by 2 desc;



--Analysis of Percentage_laid_off is not very informative

--rolling total layoffs

--looking at the year/mon vs total laid off
SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) is not null
group by SUBSTRING(date,1,7)
order by 1 ASC;

/*
--using a CTE to perform the rolling sum
WITH Rolling_Total AS
(
SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) as Total_ppl_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) is not null
group by SUBSTRING(date,1,7)
order by 1 ASC
)
select dates, SUM(Total_ppl_laid_off) OVER(ORDER BY dates) AS Rolling_total
from Rolling_Total; */

--A CTE with dates VS total_ppl_laid_off VS Rolling_Total
WITH Rolling_Total AS
(
    SELECT SUBSTRING(date, 1, 7) AS dates, 
           SUM(total_laid_off) AS Total_ppl_laid_off
    FROM layoffs_staging2
    WHERE SUBSTRING(date, 1, 7) IS NOT NULL
    GROUP BY SUBSTRING(date, 1, 7)
)
SELECT dates, Total_ppl_laid_off,
       SUM(Total_ppl_laid_off) OVER (ORDER BY dates) AS Rolling_total
FROM Rolling_Total;



--breaking up the company layoffs per year
SELECT company, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY company
order by 2 desc;

SELECT company, year(date), SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY company, year(date)
ORDER BY 3 DESC;

--Creating a CTE and calculating ranking of layoffs
WITH Company_year (Company, Years, Total_laid_off) AS
(
SELECT company, year(date) as Year, SUM(total_laid_off) as Tota_ppl_laid_off
FROM layoffs_staging2
Group BY company, year(date)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_laid_off DESC) AS Ranking
FROM Company_year
WHERE Years is not null
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking<=5;
