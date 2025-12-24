CREATE DATABASE Employee_Management_system;
USE Employee_Management_system;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from employee;


-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Leaves ;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from JobDepartment;
select * from SalaryBonus;
select * from Employee;
select * from Qualification;
select * from Leaves;
select * from Payroll;



-- Analysis Questions

-- 1. EMPLOYEE INSIGHTS 
-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT Job_ID) AS Total_Employees
FROM Employee;

-- Which departments have the highest number of employees?
SELECT jd.jobdept AS Department, COUNT(e.emp_ID) AS Employee_Count
FROM JobDepartment jd
LEFT JOIN Employee e ON jd.Job_ID = e.Job_ID
GROUP BY jd.jobdept
ORDER BY Employee_Count DESC;

-- What is the average salary per department? 
SELECT jd.jobdept AS Department, AVG(sb.amount) AS Avg_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY Avg_Salary DESC;


-- Who are the top 5 highest-paid employees?
SELECT e.firstname, e.lastname, sb.amount AS Salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(amount) as Total_Salary_Expenditure FROM SalaryBonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- How many different job roles exist in each department?
SELECT jobdept AS Department, COUNT(name) AS Total_Roles
FROM JobDepartment
GROUP BY jobdept;

-- What is the average salary range per department? 
SELECT jd.jobdept AS Department, AVG(sb.amount) AS Avg_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- Which job roles offer the highest salary? 
SELECT jd.jobdept,jd.name AS job_role, sb.amount
FROM jobDepartment jd
JOIN SalaryBonus sb ON sb.job_ID = JD.Job_ID
ORDER BY sb.amount DESC 
LIMIT 10;

--  Which departments have the highest total salary allocation? 
SELECT jd.jobdept AS Department, SUM(sb.amount) AS Total_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY Total_Salary DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS 
-- How many employees have at least one qualification listed? 
SELECT COUNT(DISTINCT Emp_ID) AS Employees_With_Qualifications
FROM Qualification;


-- Which positions require the most qualifications? 
SELECT Position,COUNT(*) AS Qualification_Count
FROM Qualification
GROUP BY position
ORDER BY Qualification_Count;

--  Which employees have the highest number of qualifications? 
SELECT Emp_ID, COUNT(*)
FROM Qualification
GROUP BY Emp_ID
ORDER BY COUNT(*) DESC
LIMIT 1;


-- 4. LEAVE AND ABSENCE PATTERNS 
-- Which year had the most employees taking leaves? 
SELECT YEAR(date), COUNT(DISTINCT Emp_ID)
FROM Leaves
GROUP BY YEAR(Date)
ORDER BY COUNT(*) DESC;

-- What is the average number of leave days taken by its employees per department? 
SELECT J.jobdept, AVG(extract(day from date)) AS avg_leave from leaves l
join employee e on l.emp_id=e.emp_id
join jobdepartment j on e.job_id = j.job_id
group by j.jobdept;

-- Which employees have taken the most leaves? 
select e.emp_id, sum(extract(day from l.date)) as most_leaves
from leaves l join employee e on l.emp_id = e.emp_id
group by e.emp_id
order by most_leaves desc;

-- What is the total number of leave days taken company-wide? 
select j.jobdept, sum(extract(day from l.date)) as total_leaves
from leaves l
join employee e on l.emp_id=e.emp_id
join jobdepartment j on j.job_id=e.job_id
group by j.jobdept
order by total_leaves desc;

-- How do leave days correlate with payroll amounts? 
select p.emp_id, extract(day from l.date) as leave_day,
p.date as pay_roll_date, total_amount
from leaves l
join payroll p on l.leave_id = p.leave_id;


-- 5. PAYROLL AND COMPENSATION ANALYSIS 
-- What is the total monthly payroll processed? 
select extract(year from date) as year,
extract(month from date) as month,
sum(total_amount) as total from payroll
group by extract(year from date), extract(month from date)
order by year,month;

-- What is the average bonus given per department? 
select j.jobdept, avg(s.bonus) as avg_bonus
from jobdepartment j join salarybonus s on j.job_id = s.job_id
group by j.jobdept;


-- Which department receives the highest total bonuses? 
select j.jobdept, sum(s.bonus) as total_bonus
from jobdepartment j join salarybonus s on j.job_id = s.job_id
group by j.jobdept
order by total_bonus desc
limit 1;

-- What is the average value of total_amount after considering leave deductions?
select avg(total_amount) as avg_value from payroll;

