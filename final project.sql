#HISTORY OF GRANTED LOANS

USE financial3_95;  -- from this moment on, the default database we use is: financial
WITH LoanSummary AS (
    SELECT
        YEAR(date) AS year,
        QUARTER(date) AS quarter,
        MONTH(date) AS month,
        SUM(amount) AS total_loan_amount,
        AVG(amount) AS avg_loan_amount,
        COUNT(*) AS total_loans
    FROM loan
    GROUP BY YEAR(date), QUARTER(date), MONTH(date)

    UNION ALL

    SELECT
        YEAR(date) AS year,
        QUARTER(date) AS quarter,
        NULL AS month,
        SUM(amount),
        AVG(amount),
        COUNT(*)
    FROM loan
    GROUP BY YEAR(date), QUARTER(date)

    UNION ALL

    SELECT
        YEAR(date) AS year,
        NULL AS quarter,
        NULL AS month,
        SUM(amount),
        AVG(amount),
        COUNT(*)
    FROM loan
    GROUP BY YEAR(date)

    UNION ALL

    SELECT
        NULL AS year,
        NULL AS quarter,
        NULL AS month,
        SUM(amount),
        AVG(amount),
        COUNT(*)
    FROM loan
)
SELECT * FROM LoanSummary
ORDER BY year DESC, quarter DESC, month DESC;


#LOAN STATUS

SELECT status, COUNT(*) AS loan_count
FROM loan
GROUP BY status
ORDER BY loan_count DESC;

# ANALYSIS OF ACCOUNTS
SELECT
    account_id,
    COUNT(*) AS total_loans,
    SUM(amount) AS total_loan_amount,
    AVG(amount) AS avg_loan_amount
FROM loan
WHERE status IN ('A','C')
GROUP BY account_id
ORDER BY total_loans DESC, total_loan_amount DESC, avg_loan_amount DESC;

# FULLY PAID LOANS

SELECT
    c.gender,
    SUM(l.amount) AS total_repaid_loan_amount
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN disp d ON a.account_id = d.account_id
JOIN client c ON d.client_id = c.client_id
WHERE d.type = 'OWNER'
  AND l.status IN ('A', 'C')
GROUP BY c.gender;

#CLIENT ANALYSIS PART 1

WITH RepaidLoans AS (
    SELECT
        c.gender,
        c.birth_date,
        l.amount
    FROM loan l
    JOIN account a ON l.account_id = a.account_id
    JOIN disp d ON a.account_id = d.account_id
    JOIN client c ON d.client_id = c.client_id
    WHERE d.type = 'OWNER'
      AND l.status IN ('A', 'C')
)
-- Number of loans
SELECT
    gender,
    COUNT(*) AS number_of_repaid_loans,
    AVG(2024 - YEAR(birth_date)) AS average_age
FROM RepaidLoans
GROUP BY gender
ORDER BY number_of_repaid_loans DESC;

#CLIENT ANALYSIS PART 2

WITH Owners AS (
    SELECT
        c.district_id,
        l.loan_id,
        l.amount
    FROM loan l
    JOIN account a ON l.account_id = a.account_id
    JOIN disp d ON a.account_id = d.account_id
    JOIN client c ON d.client_id = c.client_id
    WHERE d.type = 'OWNER'
      AND l.status IN ('A', 'C')
)
SELECT
    dist.A2 AS district_name,
    COUNT(DISTINCT o.district_id) AS number_of_clients,
    COUNT(o.loan_id) AS number_of_repaid_loans,
    SUM(o.amount) AS total_repaid_loan_amount
FROM Owners o
JOIN district dist ON o.district_id = dist.district_id
GROUP BY dist.district_id, dist.A2
ORDER BY number_of_clients DESC, number_of_repaid_loans DESC, total_repaid_loan_amount DESC;

#CLIENT ANALYSIS PART 3

WITH LoanData AS (
    SELECT
        c.district_id,
        l.amount
    FROM loan l
    JOIN account a ON l.account_id = a.account_id
    JOIN disp d ON a.account_id = d.account_id
    JOIN client c ON d.client_id = c.client_id
    WHERE d.type = 'OWNER' AND l.status IN ('A', 'C')
),
DistrictLoans AS (
    SELECT
        district_id,
        COUNT(*) AS loans_given_count,
        SUM(amount) AS loans_given_amount
    FROM LoanData
    GROUP BY district_id
),
Total AS (
    SELECT SUM(loans_given_amount) AS total_amount FROM DistrictLoans
)
SELECT
    dl.district_id,
    COUNT(DISTINCT ld.district_id) AS customer_amount,
    dl.loans_given_amount,
    dl.loans_given_count,
    ROUND(dl.loans_given_amount / t.total_amount, 4) AS amount_share
FROM DistrictLoans dl
JOIN LoanData ld ON dl.district_id = ld.district_id
JOIN Total t
GROUP BY dl.district_id, dl.loans_given_amount, dl.loans_given_count, t.total_amount
ORDER BY amount_share DESC;

# SELECTION PART 1

SELECT
    c.client_id,
    c.birth_date,
    SUM(l.amount) - SUM(l.payments) AS account_balance,
    COUNT(l.loan_id) AS loan_count
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN disp d ON a.account_id = d.account_id
JOIN client c ON d.client_id = c.client_id
WHERE c.birth_date > '1990-01-01'
GROUP BY c.client_id, c.birth_date
HAVING SUM(l.amount) - SUM(l.payments) > 1000
   AND COUNT(l.loan_id) > 5
ORDER BY account_balance DESC;

# SELECTION PART 2

# clients with more than 1000 in account balance
SELECT c.client_id, SUM(l.amount) - SUM(l.payments) AS account_balance
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN disp d ON a.account_id = d.account_id
JOIN client c ON d.client_id = c.client_id
GROUP BY c.client_id
HAVING SUM(l.amount) - SUM(l.payments) > 1000;

# more than 5 loans
SELECT c.client_id, COUNT(l.loan_id) AS loan_count
FROM loan l
JOIN account a ON l.account_id = a.account_id
JOIN disp d ON a.account_id = d.account_id
JOIN client c ON d.client_id = c.client_id
GROUP BY c.client_id
HAVING COUNT(l.loan_id) > 5;

#clients born after 1990
SELECT c.client_id, c.birth_date
FROM client c
WHERE c.birth_date > '1990-01-01';


# EXPIRING CARDS
DESCRIBE financial3_95.district;

DELIMITER $$

CREATE PROCEDURE refresh_cards_at_expiration()
BEGIN
    -- Create the cards_at_expiration table if it doesn't exist
    CREATE TABLE IF NOT EXISTS financial3_95.cards_at_expiration (
        client_id INT NOT NULL,
        card_id INT NOT NULL,
        expiration_date DATE NOT NULL,
        client_address VARCHAR(255) NOT NULL
    );

    -- Clear any existing data in the cards_at_expiration table
    TRUNCATE TABLE financial3_95.cards_at_expiration;

    -- Insert the expiring cards data
    INSERT INTO financial3_95.cards_at_expiration (client_id, card_id, expiration_date, client_address)
    SELECT
        c2.client_id,
        c.card_id,
        DATE_ADD(c.issued, INTERVAL 3 YEAR) AS expiration_date,
        d2.address AS client_address  -- Assuming 'address' is the correct column
    FROM
        financial3_95.card c
    INNER JOIN
        financial3_95.disp d ON c.disp_id = d.disp_id
    INNER JOIN
        financial3_95.client c2 ON d.client_id = c2.client_id
    INNER JOIN
        financial3_95.district d2 ON c2.district_id = d2.district_id
    WHERE
        CURDATE() BETWEEN DATE_ADD(DATE_ADD(c.issued, INTERVAL 3 YEAR), INTERVAL -7 DAY)
        AND DATE_ADD(c.issued, INTERVAL 3 YEAR);

END $$

DELIMITER ;
CALL refresh_cards_at_expiration();











