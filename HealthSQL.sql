
-- 1. a.
-- Loads the final_exam_rx into a new table called RX_new
CREATE TABLE RX_NEW (
	accountno varchar(30) primary key,
	drugname varchar(30),
	cost integer,
	dosage real, 
	dosage_instruct varchar (30)
	);

BULK INSERT RX_NEW FROM 'C:\TEMP\final_exam_rx_spring.txt'
WITH(FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')

-- 1. b.
-- Runs a SELECT TOP 10 * against the newly created table
SELECT TOP 10 * 
FROM RX_NEW

-- 2. a.
-- Returns DISTINCT drugs and dosage instructions
SELECT DISTINCT drugname,
	CASE
		WHEN dosage_instruct = 'Once Daily' THEN '1 time taken per day'
		WHEN dosage_instruct = 'Twice Daily' THEN '2 times taken per day'
		WHEN dosage_instruct = 'Every 8 hours' THEN '3 times taken per day'
		WHEN dosage_instruct = 'Every 6 hours' THEN '4 times taken per day'
		WHEN dosage_instruct = 'Every 4 hours' THEN '6 times taken per day'
		WHEN dosage_instruct = 'Every hour' THEN '24 times taken per day'
		ELSE 'Different dosage instructions'
	END AS freq_per_day
FROM RX_NEW

-- 2. b. 
-- Adds a new column to the table called freq_per_day
ALTER TABLE RX_NEW
ADD freq_per_day int;

-- 2.c.
-- Sets freq_per_day equal to the amount the drug needs to be take per day
UPDATE RX_NEW
SET freq_per_day = CASE 
	WHEN dosage_instruct = 'Once Daily' THEN 1
	WHEN dosage_instruct = 'Twice Daily' THEN 2
	WHEN dosage_instruct = 'Every 8 hours' THEN 3
	WHEN dosage_instruct = 'Every 6 hours' THEN 4
	WHEN dosage_instruct = 'Every 4 hours' THEN 6
	WHEN dosage_instruct = 'Every hour' THEN 24
    ELSE 0
END;
SELECT * FROM RX_NEW

-- 2.d. 
-- MME/day for each patients MME for ('OxyContin','Oxymorphone','Hydrocodone','Codeine')
SELECT accountno, drugname, 
	SUM(CASE 
			WHEN drugname = 'OxyContin' THEN dosage * freq_per_day * 1.5
			WHEN drugname = 'Oxymorphone' THEN dosage * freq_per_day * 3
			WHEN drugname = 'Hydrocodone' THEN dosage * freq_per_day * 1
			WHEN drugname = 'Codeine' THEN dosage * freq_per_day * 0.15
			ELSE null
     END) AS MME_per_day
FROM RX_NEW
WHERE drugname IN ('OxyContin','Oxymorphone','Hydrocodone','Codeine')
GROUP BY accountno, drugname;

-- 2.e.
-- Sums MME by drugname
ALTER TABLE RX_NEW
ADD MME_per_day int

UPDATE RX_NEW
SET MME_per_day = CASE 
			WHEN drugname = 'OxyContin' THEN dosage * freq_per_day * 1.5
			WHEN drugname = 'Oxymorphone' THEN dosage * freq_per_day * 3
			WHEN drugname = 'Hydrocodone' THEN dosage * freq_per_day * 1
			WHEN drugname = 'Codeine' THEN dosage * freq_per_day * 0.15
			ELSE null
     END;

SELECT drugname, SUM(MME_per_day) AS MME_SUM
FROM RX_NEW
WHERE drugname IN ('OxyContin', 'Oxymorphone', 'Hydrocodone', 'Codeine')
GROUP BY drugname;


-- 2.f.
-- Total drug cost by drugname by admit_year in descending order
SELECT R.drugname, A.ADMIT_YEAR, SUM(R.cost) AS total_drug_cost
FROM RX_NEW R
INNER JOIN ADMISSIONS A
ON R.accountno = A.MRN
GROUP BY drugname, ADMIT_YEAR
ORDER BY SUM(R.cost) DESC;

-- 2.g.
-- Frequency distribution of patients taking drugs
SELECT drugname, COUNT(accountno) AS patient_freq
FROM RX_NEW
GROUP BY drugname;

-- 2.h. 
-- Patients on OxyContin that have a prior history of overdose
SELECT R.accountno, R.drugname, S.P_OVERDOSE
FROM RX_NEW R
INNER JOIN SUD S
ON R.accountno = S.MRN
WHERE R.drugname = 'OxyContin' AND S.P_OVERDOSE = 'YES'
GROUP BY R.accountno, R.drugname, S.P_OVERDOSE



