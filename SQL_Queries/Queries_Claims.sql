USE insurance_claims;
SELECT * FROM claims LIMIT 10;
ALTER TABLE claims MODIFY COLUMN policy_bind_date date,
MODIFY COLUMN policy_state char(2),
MODIFY COLUMN incident_date date,
MODIFY COLUMN incident_state char(2),
MODIFY COLUMN total_claim_amount double,
MODIFY COLUMN injury_claim double,
MODIFY COLUMN property_claim double,
MODIFY COLUMN vehicle_claim double,
MODIFY COLUMN fraud_reported text;
SET SQL_SAFE_UPDATES = 0;
UPDATE claims 
SET fraud_reported = CASE 
	WHEN fraud_reported = 'N' THEN 'No'
	WHEN fraud_reported = 'Y' THEN 'Yes'
	ELSE fraud_reported
END;
UPDATE claims 
SET collision_type = CASE 
	WHEN collision_type = '?' THEN 'Own Damage'
	ELSE collision_type
END;
UPDATE claims 
SET police_report_available = CASE 
	WHEN police_report_available = '?' THEN 'Unknown'
	ELSE police_report_available
END;
UPDATE claims 
SET property_damage = CASE 
	WHEN property_damage = '?' THEN 'Unknown'
	ELSE property_damage
END;

# Number of fraudulent and non-fraudulent claims
SELECT
SUM(fraud_reported = 'Yes') AS Fraudulent,
SUM(fraud_reported = 'No') AS Non_Fraudulent
FROM claims;

# Claims by state
SELECT
incident_state AS incident_state,
count(policy_number) AS claims_by_state
FROM claims
GROUP BY incident_state;

# Average annual policy premium by status fraud 
SELECT 
fraud_reported AS Fraud,
ROUND(AVG(policy_annual_premium), 2) AS Avg_Premium
FROM claims
GROUP BY fraud_reported;

# Fraudulent car brand
SELECT
auto_make AS Car_Brand,
COUNT(policy_number) AS Claims
FROM claims
WHERE fraud_reported = 'Yes'
GROUP BY auto_make
ORDER BY Claims DESC LIMIT 1;

# More than two vehicles involved
SELECT
COUNT(policy_number) AS Claims_with_more_than_two_vehicles_involved
FROM claims
WHERE number_of_vehicles_involved > 2;

# Top 5 of the most fraudulent cities
SELECT 
incident_city AS City,
COUNT(policy_number) AS Fraudulent_claims
FROM claims
WHERE fraud_reported = 'Yes'
GROUP BY incident_city
ORDER BY Fraudulent_claims DESC LIMIT 5;

# Percentage of fraudulent claims
SELECT
ROUND(SUM(fraud_reported = 'Yes') / COUNT(policy_number) * 100, 2) AS Fraud_Percentage
FROM claims;

# Claims by incident severity 
SELECT
incident_severity AS Incident_Severity,
COUNT(policy_number) AS Claims
FROM claims
GROUP BY incident_severity;

# Most fraudulent occupations 
SELECT
insured_occupation AS Occupation,
insured_sex AS Genre,
COUNT(policy_number) AS Claims
FROM claims
WHERE fraud_reported = 'Yes'
GROUP BY insured_occupation, insured_sex
ORDER BY Claims DESC LIMIT 3; 

# Percentage of claims by type of incident
SELECT 
incident_type AS Incident_Type,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM claims), 2) AS Percentage
FROM claims
GROUP BY incident_type
ORDER BY Percentage DESC;

# Percentage of fraudulent claims by type of incident
SELECT 
incident_type AS Incident_Type,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM claims WHERE fraud_reported = 'Yes'), 2) AS Percentage
FROM claims
WHERE fraud_reported = 'Yes'
GROUP BY incident_type
ORDER BY Percentage DESC;

# Percentage of claims with witnesses
SELECT 
ROUND(SUM(witnesses > 0) / COUNT(*) * 100, 2) AS Witness_Percentage
FROM claims;

# The top 3 most common brand cars involved in fraudulent claims and the average total claim amount
SELECT 
auto_make AS Auto_Brand,
COUNT(*) AS Fraudulent_claims,
ROUND(AVG(total_claim_amount), 2) AS Avg_Claim_Amount
FROM claims
WHERE fraud_reported = 'Yes'
GROUP BY auto_make
ORDER BY Fraudulent_Claims DESC, Avg_Claim_Amount DESC
LIMIT 3;

# The average time between the policy bind date and the incident date
SELECT 
fraud_reported AS Fraud, 
ROUND(AVG(TIMESTAMPDIFF(MONTH, policy_bind_date, incident_date)), 2) AS Avg_Months
FROM claims
GROUP BY fraud_reported;