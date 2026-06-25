-- Data Cleaning project --
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Duplicate identification and removal --


SELECT *
FROM layoffs;

create table layoffs_staging
like layoffs;

SELECT *
FROM layoffs_staging;

insert into layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
row_number() over(partition by company, location, industry, total_laid_off, `date`, stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

select *
from ( SELECT *,
row_number() over(partition by company, location, industry, total_laid_off, `date`, stage,country,funds_raised_millions) as row_num
FROM layoffs_staging) duplicates
where row_num > 1;

select *
FROM layoffs_staging;

ALTER TABLE world_layoffs.layoffs_staging DROP COLUMN row_num;


CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

select * 
from  world_layoffs.layoffs_staging2;


DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

-- Standadization --

select * 
from  world_layoffs.layoffs_staging2;

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
where industry like "crypto%";

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT company, trim(company) as trim_company
FROM world_layoffs.layoffs_staging2
ORDER BY company;

UPDATE layoffs_staging2
SET company = trim(company);

SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2
ORDER BY location;

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, trim(TRAILING '.' from (country))
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' from (country))
WHERE country LIKE "united states%";

select * 
from  world_layoffs.layoffs_staging2;

select `date`, str_to_date(`date`, "%m/%d/%Y") 
from  world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET `DATE` = str_to_date(`date`, "%m/%d/%Y")
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- CHECKING FOR NULL AND BLANK VALUES

select * 
from  world_layoffs.layoffs_staging2;

select * 
from  world_layoffs.layoffs_staging2
WHERE industry is NULL 
OR industry = ''
ORDER BY industry;

select * 
from  world_layoffs.layoffs_staging2
WHERE company = 'airbnb';

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

select t1.company, t1.industry, t2.industry
from  world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company 
WHERE t1.company = 'airbnb';


UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- removing irrelevant column and rows --

select total_laid_off, percentage_laid_off
from  world_layoffs.layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off IS NULL;

DELETE FROM world_layoffs.layoffs_staging2
where total_laid_off IS NULL
and percentage_laid_off IS NULL;

select * 
from  world_layoffs.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 