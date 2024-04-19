USE world_layoffs;  -- This uses the database world_layoffs
-- This shows the table
SELECT * FROM layoffs;


	-- created a new table so that the data is not hampred
CREATE TABLE layoffs_staging
LIKE layoffs;       -- creates a new table named layoffs_staging

select * from layoffs_staging;  -- This shows the table

INSERT layoffs_staging
select * from layoffs;   -- This copy's the data of layoffs table into layoffs_staging table





-- To remove the duplicate

select * from layoffs_staging;    -- This shows the table

WITH duplicate_rows AS(                   -- This query shows if the table has any duplicate records
SELECT *,
ROW_NUMBER () OVER( partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions, country) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_rows
WHERE row_num > 1;                               


CREATE TABLE `layoffs_final` (     -- CREATED A NEW TABLE NAMED layoffs_final
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE layoffs_final
MODIFY COLUMN row_num INT;    -- THIS CHANGES COLUMN row_num TO INTEGER

select * from layoffs_final;    -- This shows the table

INSERT INTO layoffs_final          -- This copy's the data of the query into layoffs_final table
SELECT *,
ROW_NUMBER () OVER( partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions, country) AS row_num
FROM layoffs_staging;

DELETE                        -- This deletes the duplicate rows in layoffs final table
from layoffs_final
WHERE row_num > 1;


-- standardizing DATA


ALTER TABLE layoffs_final  -- This drops the column row_num
Drop COLUMN row_num;

update layoffs_final         -- This query removes any spaces in words in particular rows
set company = trim(company);

update layoffs_final                -- This changes the rows to crypto
set industry ='Crypto'
where industry like 'crypto%';

select distinct(country), trim(trailing '.' from country) as trim
from layoffs_final
where country like 'United States%';

update layoffs_final                 -- This trims the '.' at the end of united states
set country =  trim(trailing '.' from country)
where country like 'United States%';

select `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_final;

update layoffs_final
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');      -- This chages the data type of date from txt to date datatype

alter table layoffs_final
modify column `date` date;     -- This changes the datatype of column date to date datatype

select *
from layoffs_final
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_final
set industry = null
where industry = '';

select company, industry
from layoffs_final
where industry is null;



select f1.industry,  f2.industry
from layoffs_final f1
join layoffs_final f2
on f1.company = f2.company
where f1.industry is null
and f2.industry is not null;


update layoffs_final f1      -- This fills the null value in industry column
join layoffs_final f2
on f1.company = f2.company
set f1.industry = f2.industry
where f1.industry is null
and f2.industry is not null;

DELETE                            -- This deletes the rows with nulls in total_laid_off and percentage_laid_off
from layoffs_final
where total_laid_off is null
and percentage_laid_off is null;
