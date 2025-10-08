/** Adding new teacher **/

/**
1. Try to add a new teacher to the database with the following data:
- teacher_id - 2
- name - Jan Kowalski
- pay - 1300 Did adding the teacher work? If not, what error was returned from the database?
**/
-- Put your solution here
insert into teachers (teacher_id, name, pay)
values (2, 'Jan Kowalski', 1300)

--Key (teacher_id)=(2) already exists
SELECT *
FROM teachers
WHERE teacher_id = 2


-- 2. Add the teacher from the previous point, specifying only his name and salary. Do not give the primary key (`teacher_id` field),
-- Put your solution here
INSERT INTO teachers (name, pay)
VALUES ('Jan Kowalski', 1300)


-- 3. Load all teachers. What primary key has been assigned to Jan Kowalski?
-- Put your solution here
SELECT *
FROM teachers
-- jan's teacher_id is 11

-- 4. Try adding a new teacher by giving all fields (together with the primary key – `teacher_id` field). But this time as the `teacher_id` give the value that does not yet exist in the table (e.g. greater by one than the last value in the filed).
-- Put your solution here
INSERT INTO teachers (teacher_id, name, pay)
VALUES (6, 'Jane Doe', 1500)

SELECT *
FROM teachers


