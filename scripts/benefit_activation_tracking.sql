-- BUSINESS CONTEXT: 83% of employees are unaware of benefits. 
-- PURPOSE: Identify "Ghost Users" for the Automated WhatsApp Drip.

WITH onboarding_summary AS (
    SELECT 
        employee_id,
        onboarding_date,
        onboarding_channel, -- Email vs WhatsApp
        DATEDIFF(CURRENT_DATE, onboarding_date) AS days_since_joined
    FROM user_onboarding_logs
),
activation_status AS (
    SELECT 
        employee_id,
        MIN(activation_timestamp) AS first_activation
    FROM benefit_engagements
    WHERE event_type = 'health_card_download'
    GROUP BY 1
)

SELECT 
    o.onboarding_channel,
    COUNT(o.employee_id) AS total_onboarded,
    COUNT(a.employee_id) AS total_activated,
    -- Calculate the "Awareness Gap" per channel
    ROUND(100.0 * (1 - COUNT(a.employee_id) / COUNT(o.employee_id)), 2) AS awareness_gap_percentage
FROM onboarding_summary o
LEFT JOIN activation_status a ON o.employee_id = a.employee_id
WHERE o.days_since_joined >= 14
GROUP BY 1;
