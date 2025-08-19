
-- Sushma Bhonagiri 24-07-2025 20.38PM

-- SQL Script for Summer Camp Data


-- Dropping tables in case they are existing


DROP TABLE IF EXISTS #Stud;
DROP TABLE IF EXISTS #CampDetails;
DROP TABLE IF EXISTS #CampVisits;


-- Create Table Scripts


CREATE TABLE #Stud (
    S_ID INT PRIMARY KEY,
    FName VARCHAR(50),
    MName VARCHAR(50),
    LName VARCHAR(50),
    Gender VARCHAR(50),
    DOB DATE,
    Email VARCHAR(100),
    Phone VARCHAR(15)
);


CREATE TABLE #CampDetails (
    C_ID INT PRIMARY KEY,
    CampTitle VARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Capacity INT,
    Price DECIMAL(10,2)
);


CREATE TABLE #CampVisits (
    V_ID INT PRIMARY KEY,
    S_ID INT,
    C_ID INT,
    VisitDate DATE
);


-- Creating Name List for First Name


DECLARE @NameList1 TABLE (Name VARCHAR(50));
INSERT INTO @NameList1 VALUES ('Vamshi'), ('Isha'), ('Vihaan'), ('Sneha'), ('Aditya'), ('Mounika'), ('Karthik'), ('Aarti'),
('Raja'), ('Rakesh'), ('Vijay'), ('Shruthi'), ('Tanya'), ('Monica');


-- Female First Names
DECLARE @GirlNames TABLE (Name VARCHAR(50));
INSERT INTO @GirlNames VALUES ('Isha'), ('Sneha'), ('Mounika'), ('Aarti'), ('Shruthi'), ('Tanya'), ('Monica');

-- Male First Names
DECLARE @BoyNames TABLE (Name VARCHAR(50));
INSERT INTO @BoyNames VALUES ('Vamshi'), ('Vihaan'), ('Aditya'), ('Karthik'), ('Raja'), ('Rakesh'), ('Vijay');



-- Creating Name List for Middle Name

DECLARE @NameList2 TABLE (Name VARCHAR(50));
INSERT INTO @NameList2 VALUES ('V'), ('A'), ('B'), ('C'), ('M'), ('K'), ('D'), ('L');

-- Creating Name List for Last Name

DECLARE @NameList3 TABLE (Name VARCHAR(50));
INSERT INTO @NameList3 VALUES ('Rao'), ('Singh'), ('Modi'), ('Kumar'), ('Khan'), ('Patel'), ('Kumar'), ('Sinha');

-- Declaring variables as necessary

DECLARE @TotalStudents INT = 5000;
DECLARE @Counter INT = 1;


-- Initiating Counters to generate rows and also using RAND() to distribute column values

WHILE @Counter <= @TotalStudents
BEGIN
    DECLARE @Gender VARCHAR(10);
    DECLARE @DOB DATE;
    DECLARE @FName VARCHAR(50);
    DECLARE @MName VARCHAR(50);
    DECLARE @LName VARCHAR(50);

    -- Select random name
    
   -- SELECT TOP 1 @FName = Name FROM @NameList1 ORDER BY NEWID();
    SELECT TOP 1 @MName = Name FROM @NameList2 ORDER BY NEWID();
    SELECT TOP 1 @LName = Name FROM @NameList3 ORDER BY NEWID();

    -- DOB Logic using age brackets as per instructions

    SET @DOB = CASE 
        WHEN RAND(CHECKSUM(NEWID())) <= 0.18 THEN DATEFROMPARTS(2013 - FLOOR(RAND(CHECKSUM(NEWID())) * 6), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 12), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 28))  -- 7–12
        WHEN RAND(CHECKSUM(NEWID())) <= 0.45 THEN DATEFROMPARTS(2011 - FLOOR(RAND(CHECKSUM(NEWID())) * 2), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 12), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 28))  -- 13–14
        WHEN RAND(CHECKSUM(NEWID())) <= 0.65 THEN DATEFROMPARTS(2009 - FLOOR(RAND(CHECKSUM(NEWID())) * 3), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 12), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 28))  -- 15–17
        ELSE DATEFROMPARTS(2007 - FLOOR(RAND(CHECKSUM(NEWID())) * 2), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 12), 1 + FLOOR(RAND(CHECKSUM(NEWID())) * 28))                             -- 18–19
    END;


      -- Gender: ~65% Girls
    SET @Gender = CASE 
        WHEN RAND(CHECKSUM(NEWID())) <= 0.65 THEN 'Girl' 
        ELSE 'Boy' 
    END;
    --



-- Match first name to gender
IF @Gender = 'Girl'
    SELECT TOP 1 @FName = Name FROM @GirlNames ORDER BY NEWID();
ELSE
    SELECT TOP 1 @FName = Name FROM @BoyNames ORDER BY NEWID();


    -- Inserting rows 

    INSERT INTO #Stud (S_ID, FName, MName, LName, Gender, DOB, Email, Phone)
    VALUES (
        @Counter,
        @FName,
        @MName,
        @LName,
        @Gender,
        @DOB,
        CAST(@FName AS VARCHAR)+'@gmail.com',
        '999' + CAST(@Counter AS VARCHAR)
    );

    SET @Counter += 1;
END;

-- Task 2

-- Inserting SAMPLE CAMPDETAILS

INSERT INTO #CampDetails (C_ID, CampTitle, StartDate, EndDate, Capacity, Price) VALUES
(1, 'Games', '2024-05-01', '2024-05-07', 100, 5000.00),
(2, 'Arts', '2023-06-10', '2023-06-20', 50, 3000.00),
(3, 'Coding', '2022-07-01', '2022-07-15', 70, 4000.00);



-- Inserting SAMPLE CAMPVISITS

INSERT INTO #CampVisits (V_ID, S_ID, C_ID, VisitDate) VALUES
(1, (SELECT TOP 1 S_ID FROM #Stud WHERE FName = 'Isha'), 1, '2024-05-01'),
(4, (SELECT TOP 1 S_ID FROM #Stud WHERE FName = 'Isha'), 2, '2024-05-04'),
(2, 10, 2, '2023-06-10'),
(3, 20, 3, '2025-07-01');

-- checking results


select * from #Stud;

select * from #CampDetails ;

select * from #CampVisits;



-- Task 1

DECLARE @UpdateID INT = (SELECT TOP 1 S_ID FROM #Stud WHERE FName = 'Isha');
UPDATE #Stud 
SET FName = 'Lakshmi' 
WHERE S_ID = @UpdateID;

SELECT
FName,
COUNT(*) AS TotalVisits
FROM #CampVisits CV
JOIN #Stud S ON CV.S_ID =S.S_ID
WHERE FName = 'Lakshmi'
  AND VisitDate >= dateadd(year, -3, getdate())
GROUP BY S.FName;

--- TASK 3

SELECT
  Generation,
  COUNT(*) AS TotalStudents,
  CAST(ROUND(100.0 * SUM(CASE WHEN Gender = 'Boy' THEN 1 ELSE 0 END) / COUNT(*),1) AS decimal(4,1)) AS Male,
  CAST(ROUND(100.0 * SUM(CASE WHEN Gender = 'Girl' THEN 1 ELSE 0 END) / COUNT(*), 1) AS decimal(4,1)) AS Female
FROM (
  SELECT *,
    CASE
      WHEN DOB BETWEEN '1965-01-01' AND '1980-12-31' THEN 'Gen X'
      WHEN DOB BETWEEN '1981-01-01' AND '1996-12-31' THEN 'Millennials'
      WHEN DOB BETWEEN '1997-01-01' AND '2012-12-31' THEN 'Gen Z'
      WHEN DOB BETWEEN '2013-01-01' AND '2025-12-31' THEN 'Gen Alpha'
      ELSE 'Other'
    END AS Generation
  FROM #Stud
) AS GenData
GROUP BY Generation;


