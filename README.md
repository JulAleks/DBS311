DBS311 		Assignment 1
# **Assignment 1**
## Submission
***Your submission will be a single text-based SQL file with appropriate header and commenting.  Please ensure your file runs when the entire file is executed in SQL Developer.***

Only one submission per group please.
## Group Work
This assignment is to be completed in groups of 3.  Please only one submission per group.  The comment header MUST have ALL names and student numbers.

It is suggested that you **ALL do it individually** and then meet to compare answers. Those not doing the work may be barred from your group resulting in a zero and incomplete on the assignment.

**VERY IMPORTANT:**

Being part of a group is the same as being a part of a team for these assignments. When you submitted your work as part of a group you are saying that:

- you understood what was submitted and that you fully participated with ALL the group members. 
- It does not mean letting others do your work for you. 
- It does not mean watching the others do the work. 
- For your full participation, you get a mark equal to all the others in the group. 
- If on the test, which is very much like the assignment, you cannot answer it strongly indicates that you didn’t participate and understand the assignment but depended on others for the mark you received. That is very much like submitting their work and claiming it is your work.
## Tasks
1. Display the employee number, full employee name, job and hire date of all employees hired in May or November of any year, with the most recently hired employees displayed first. 
   1. Also, exclude people hired in 2015 and 2016.  
   1. Full name should be in the form “Lastname, Firstname”  with an alias called “FullName”.
   1. Hire date should point to the last day in May or November of that year (NOT to the exact day) and be in the form of [May 31<st,nd,rd,th> of 2016] with the heading Start Date. ***Do NOT use LIKE operator.*** 
   1. <st,nd,rd,th> means days that end in a 1, should have “st”, days that end in a 2 should have “nd”, days that end in a 3 should have “rd” and all others should have “th”
   1. You should display ONE row per output line by limiting the width of the Full Name to 25 characters. The output lines should look like this line (4 columns):

|174|Abel, Ellen|SA\_REP|[May 31st of 2016]|
| :- | :- | :- | :- |

1. List the employee number, full name, job and the modified salary for all employees whose monthly earning (without this increase) is outside the range $6,500 – $11,500 and who are employed as Vice Presidents or Managers (President is not counted here).  
   1. You should use Wild Card characters for this. 
   1. VP’s will get 25% and managers 18% salary increase.  
   1. Sort the output by the top salaries (before this increase) firstly.
   1. Heading will be like Employees with increased Pay
   1. The output lines should look like this sample line (note: 1 column):

Emp# 124 named Kevin Mourgos who is ST\_MAN will have a new salary of $6960

1. Display the employee last name, salary, job title and manager# of all employees not earning a commission OR if they work in the SALES department, but only if their total monthly salary with $1000 included bonus and commission (if earned) is greater than $15,000.  
   1. Let’s assume that all employees receive this bonus.
   1. If an employee does not have a manager, then display the word NONE 
   1. instead. This column should have an alias Manager#.
   1. Display the Total annual pay as well in the form of $135,600.00 with the heading Total Income.  Only include the bonus $1000 once.
   1. Sort the result so that best paid employees are shown first.
   1. The output lines should look like this sample line (5 columns):

|De Haan|17000|AD\_VP|100|$205,000.00|
| :- | :- | :- | :- | :- |

1. Display Department\_id, Job\_id and the Lowest salary for this combination under the alias Lowest Dept/Job Pay, but only if that Lowest Pay falls in the range $6500 - $16800. Exclude people who work as some kind of Representative job from this query and departments IT and SALES as well.
   1. Sort the output according to the Department\_id and then by Job\_id.
   1. You MUST **NOT** use the Subquery method.
1. Display last\_name, salary and job for all employees who earn more than all lowest paid employees per department outside the US locations.
   1. Exclude President and Vice Presidents from this query.
   1. Sort the output by job title ascending.
   1. You need to use a Subquery and Joining.
1. Who are the employees (show last\_name, salary and job) who work either in IT or MARKETING department and earn more than the worst paid person in the ACCOUNTING department. 
   1. Sort the output by the last name alphabetically.
   1. You need to use ONLY the Subquery method (NO joins allowed).
1. Display alphabetically the full name, job, salary (formatted as a currency amount incl. thousand separator, but no decimals) and department number for each employee who earns less than the best paid unionized employee (i.e. not the president nor any manager nor any VP), and who work in either SALES or MARKETING department.  
   1. Full name should be displayed as Firstname Lastname and should have the heading Employee. 
   1. Salary should be left-padded with the = symbol till the width of 15 characters. It should have an alias Salary.
   1. You should display ONE row per output line by limiting the width of the 	Employee to 24 characters.
   1. The output lines should look like this sample line (4 columns):

|Jonathon Taylor|SA\_REP|=======  $8,600|80|
| :- | :- | :- | :- |



1. “Tricky One”
   Display department name, city and number of different jobs in each department. If city is null, you should print Not Assigned Yet.
   1. This column should have alias City.
   1. Column that shows # of different jobs in a department should have the heading # of Jobs
   1. You should display ONE row per output line by limiting the width of the City to 22 characters.
   1. You need to show complete situation from the EMPLOYEE point of view, meaning include also employees who work for NO department (but do NOT display empty departments) and from the CITY point of view meaning you need to display all cities without departments as well.
## Example Submission
-- \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
-- Name: Your Name
-- ID: #########
-- Date: The current date
-- Purpose: Assignment 1 - DBS301
-- \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

-- Question 1 – write a brief note about what the question is asking
-- Q1 SOLUTION --

SELECT \* FROM TABLE;

-- Question 2 – blah blah blah


3 | Page

