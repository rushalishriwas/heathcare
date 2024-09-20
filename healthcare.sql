CREATE DATABASE healthcare;
USE healthcare;

SELECT * FROM PATIENTS;
SELECT * FROM APPOINTMENTS;
SELECT * FROM BILLING;
SELECT * FROM DOCTORS;
SELECT * FROM PRESCRIPTIONS;

SELECT * FROM APPOINTMENTS
WHERE PATIENT_ID =1;

SELECT * FROM PRESCRIPTIONS
WHERE APPOINTMENT_ID=1;

SELECT * FROM BILLING
WHERE APPOINTMENT_ID=2;

SELECT a.appointment_id,p.first_name as patient_first_name,p.last_name as patient_last_name,
d.first_name as doctor_first_name,d.last_name as doctor_last_name,b.amount,b.payment_date,b.status
FROM appointments a 
JOIN PATIENTS p ON a.PATIENT_ID = p.PATIENT_ID
JOIN DOCTORS d ON a.DOCTOR_ID = d.doctor_id
JOIN BILLING b ON a.appointment_ID = b.appointment_id;


-- FIND THE ALL PAID BILLING
SELECT * FROM BILLING
WHERE STATUS ='PAID';

-- CALCULATE TOTAL AMOUNT BILLED AND TOTAL PAID AMOUNT
SELECT
(SELECT SUM(AMOUNT) FROM BILLING)AS TOTAL_BILLED,
(SELECT SUM(AMOUNT) FROM BILLING WHERE STATUS = 'PAID') AS TOTAL_PAID;

SELECT d.specialty,count(a.appointment_id) as number_of_appointments from appointments a 
join doctors d on a.doctor_id = d.doctor_id
group by d.specialty
order by number_of_appointments desc;

SELECT reason,
count(*) as count
from appointments group by reason order by count desc;

SELECT p.patient_id,p.first_name,p.last_name,MAX(a.appointment_date)AS LASTEST_APPOINTMENT FROM PATIENTS p 
JOIN APPOINTMENTS a ON p.PATIENT_ID = a.PATIENT_ID 
GROUP BY p.PATIENT_ID,p.FIRST_NAME, p.LAST_NAME;

SELECT d.doctor_id, d.first_name,d.last_name, COUNT(a.appointment_id) AS number_of_appointments FROM doctors d 
LEFT join appointments a ON d.doctor_id= a.doctor_id 
GROUP BY d.doctor_id,d.first_name,d.last_name;

SELECT DISTINCT p.*
FROM Patients p 
join appointments a ON p.patient_id = a.patient_id
where a.appointment_date>=CURDATE()-INTERVAL 30 DAY;

SELECT pr.prescription_id, pr.medication,pr.dosage,pr.instructions from prescriptions pr 
join appointments a ON pr.appointment_id = a.appointment_id 
join billing b ON a.appointment_id = b.appointment_id
where b.status='pending';

SELECT P.PATIENT_id,p.first_name,p.last_name,p.dob,p.gender,p.address,p.phone_number,
a.appointment_id,a.appointment_date,a.reason,
b.amount,b.payment_date,b.status as billing_status
from patients p 
LEFT JOIN Appointments a On p.patient_id = a.patient_id
LEFT JOIN billing b ON a.appointment_id=b.appointment_id
ORDER BY p.patient_id,a.appointment_date;

-- analyse patient demographics
select gender, count(*) as count from patients group by gender;

select date_format(appointment_date, '%Y-%m') as month, count(*) as number_of_appointments from appointments
group by month
order by month;

-- yearly trend
SELECT 
    YEAR(appointment_date) AS year,
    COUNT(*) AS number_of_appointments
FROM
    appointments
GROUP BY year
ORDER BY year;

-- identify the most frequently prescribed medications and their total dosage
select medication, count(*) as frequency, sum(cast(substring_index(dosage,'',1) as unsigned)) as total_dosage
from prescriptions group by medication
order by frequency desc;

-- average billing amount by number of appointments
select p.patient_id, count(a.appointment_id) as appoinment_count, avg(b.amount) as avg_billing_amount
from patients p 
left join appointments a on p.patient_id = a.patient_id
left join billing b on a.appointment_id = b.appointment_id
group by p.patient_id
order by avg_billing_amount desc;

-- analyze the correlation between appointment frequency and billing status
select p.patient_id, p.first_name, p.last_name, sum(b.amount) as total_billed
from patients p
join appointments a on p.patient_id = a.patient_id
join billing b on a.appointment_id = b.appointment_id
group by p.patient_id, p.first_name, p.last_name
order by total_billed desc
limit 10;

-- payment status over time
select date_format(payment_date, '%Y-%m') as month, status, count(*) as count
from billing 
group by month, status
order by month, status;

-- unpaid bills analysis
select p.patient_id, p.first_name, p.last_name, sum(b.amount) as total_unpaid 
from patients p
join appointments a on p.patient_id = a.patient_id
join billing b on a.appointment_id = b.appointment_id
where b.status = 'pending'
group by p.patient_id, p.first_name, p.last_name
order by total_unpaid desc;

-- doctor performance metrics
select d.doctor_id, d.first_name, d.last_name, count(a.appointment_id) as number_of_appointments
from doctors d
left join appointments a on d.doctor_id = a.doctor_id
group by d.doctor_id, d.first_name, d.last_name;

-- day wise appointment counts
select appointment_date, count(*) as appointment_count
from appointments 
group by appointment_date;

-- find patients with missing appointments
select p.patient_id, p.first_name, p.last_name
from patients p
left join appointments a on p.patient_id = a.patient_id
where a.appointment_id is null;

-- find all appointments from doctor with id 1
select a.doctor_id, a.appointment_id, p.first_name as patient_first_name, p.last_name as patient_last_name, a.appointment_date, a.reason
from appointments a
join patients p on a.patient_id = p.patient_id
where a.doctor_id = 1;

-- all prescriptions with payment status pending
select p.medication, p.dosage, p.instructions, b.amount, b.payment_date, b.status
from prescriptions p 
join appointments a on p.appointment_id = a.appointment_id
join billing b on a.appointment_id = b.appointment_id
where b.status = 'Pending';

-- list all patients who had appointmenta in august
select distinct p.first_name, p.last_name, p.dob, p.gender, a.appointment_date
from patients p
join appointments a on p.patient_id = a.patient_id
where date_format(a.appointment_date, '%Y-%m') = '2024-08';

