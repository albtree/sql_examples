-- Clean patient names 
UPDATE demographics
SET name = UPPER(name) -- change to upper case

UPDATE demographics
SET name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name, 'MR. ', ''),'MRS. ', ''),'DR. ',''),'MS. ','') 
,'MISS ','') -- removed all instances of MR, MRS, DR, MS, MISS

-- Most common blood types by gender

SELECT gender
	,blood_type
	,COUNT(blood_type) AS count_blood_type
FROM demographics
GROUP BY blood_type, gender
ORDER BY -count_blood_type


-- Most common medical conditions for patients aged 65 or older

SELECT condition, COUNT(condition) AS count_conditions
FROM medical_condition
WHERE UR IN (SELECT UR
FROM demographics
WHERE age >= 65)
GROUP BY condition
ORDER BY -count_conditions

--Exploratory data analysis of length of stay by condition, admission type, doctors, insurance providers

SELECT mc."condition"
,AVG(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS mean_LOS
,MAX(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS max_LOS
FROM medical_condition mc 
LEFT JOIN admission_details ad ON mc.UR = ad.UR 
GROUP BY mc."condition" 

SELECT ad.admission_type 
,AVG(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS mean_LOS
,MAX(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS max_LOS
FROM medical_condition mc 
LEFT JOIN admission_details ad ON mc.UR = ad.UR 
GROUP BY ad.admission_type 

-- Get min, mean, and max length of stay for doctors who have between 10 and 20 patients
SELECT  d.doctor
,COUNT (d.doctor)
,MIN(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS min_LOS
,AVG(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS mean_LOS
,MAX(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS max_LOS
FROM doctors d 
LEFT JOIN admission_details ad ON d.UR = ad.UR 
GROUP BY d.doctor 
HAVING COUNT(*) BETWEEN 10 AND 20

-- Get min, mean, and max length of stay for insurance providers + calculate how many patients are with each insurance provider
SELECT  i.insurance_provider 
,COUNT (i.insurance_provider )
,MIN(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS min_LOS
,AVG(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS mean_LOS
,MAX(JULIANDAY(DATE(REPLACE(discharge_date, "/", "-")))-JULIANDAY(DATE(REPLACE(admission_date, "/", "-")))) AS max_LOS
FROM insurance i 
LEFT JOIN admission_details ad ON i.UR = ad.UR 
GROUP BY i.insurance_provider 

-- Breakdown of medication for Hypertension and Asthma
SELECT condition,
medication,
COUNT(medication)
from medical_condition mc 
WHERE condition = "Hypertension" OR condition = "Asthma"
GROUP BY condition, medication

-- Breakdown of Billing Amount of condition and insurance provider

SELECT i.insurance_provider 
,mc."condition" 
,AVG(ad.billing_amount)
from admission_details ad 
LEFT JOIN insurance i ON i.UR = ad.UR
LEFT JOIN medical_condition mc ON ad.UR = mc.UR 
GROUP BY i.insurance_provider, mc."condition" 

-- Breakdown of Billing Amount of condition and hospital

SELECT  ad.Hospital 
,mc."condition" 
,AVG(ad.billing_amount)
from admission_details ad 
LEFT JOIN medical_condition mc ON ad.UR = mc.UR 
GROUP BY ad.Hospital, mc."condition" 
