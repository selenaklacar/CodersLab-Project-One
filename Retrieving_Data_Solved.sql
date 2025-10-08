/** SELECT Clause**/

-- 1. Query finding all students
-- Put your solution here
SELECT * FROM Students

-- 2. Query finding all teachers
-- Put your solution here
SELECT * FROM Teachers

-- 3. Query finding only names and surnames of teachers
-- Put your solution here
SELECT name 
FROM teachers

-- 4. Query finding only surnames and emails of students
-- Put your solution here
SELECT surname, email 
FROM students

/** WHERE clause **/

-- 1. Query finding all students whose name starts with the letter A
-- Put your solution here
Select name, surname 
From students 
Where name like 'A%' or surname like 'A%'

-- 2. Query finding teachers whose salary is over 1900 PLN
-- Put your solution here
select name, pay 
from teachers 
where pay > 1900

-- 3. Query finding marks above 4
-- Put your solution here
Select * From Marks
where mark > 4

-- 4. Query finding the teacher whose name is `Brajan Kubik` (note down the teacher's id on a piece of paper),
-- Put your solution here
select name
from teachers 
where name = 'Bryan Cubes'


-- 5. Query finding marks given by Brajan (use the id from the previous point — the marks you seek will have this id in their `teacher_id` field)
-- Put your solution here
select student_id
from marks 
where teacher_id = 3

/** WHERE clause **/

-- 1. Query finding the data of a student whose name is Damian and surname is Laskowski,
-- Put your solution here
Select * From students 
where name = 'Damian' and surname = 'Forrester'

-- 2. Query finding Damian Laskowski's marks higher than 3,
-- Put your solution here
select * from marks 
where student_id = 3 and mark > '3' 


-- 3. Query finding all students with names starting from D or B.
-- Put your solution here
select name, surname 
from students 
where name like 'D%' or surname like 'B%'

/** ORDER BY Clause **/

-- 1. Query finding marks given by Klara Dąbkowska, ordered from high to low,
-- Put your solution here
SELECT teacher_id
FROM teachers
WHERE name = 'Clara Oakley'

SELECT student_id,mark
FROM marks
WHERE teacher_id = 4
ORDER BY mark DESC


-- 2. Query finding all students ordered alphabetically by surname,
-- Put your solution here
SELECT name, surname
FROM students
ORDER BY surname ASC, name ASC

-- 3. Query finding all marks of the student whose email is `bertram.adamiak@yahoo.com` from high to low.
-- Put your solution here





