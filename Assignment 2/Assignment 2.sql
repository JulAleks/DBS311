/******************************
Group 1 - Assignment 2 - NDD
Date: 2023-11-12 ---------------------------------------TO BE CHANGED 
Julia Alekssev, 051292134
Ka Ying Chan, 123231227
Audrey Duzon, 019153147
*******************************/

SET SERVEROUTPUT ON;
/******************************
         QUESTION 1
*******************************/
/*
1.	For each table in (Players, Teams, Rosters) create Stored Procedures to cover the 4 basic CRUD tasks.
a.	INSERT a new record and if the PK using autonumber, the SP returns the new PK,
b.	UPDATE an existing record given the PK value,
c.	DELETE an existing record given the PK value, and
d.	SELECT return all fields in a single row from a table given a PK value.

�	Name the SPs using the following guide:  spTableNameMethod (example spPlayersInsert)
�	Do not use DBMS_OUTPUT in the procedures in any way.  If you use it for debugging purposes, make sure it is commented out in the final submission.
�	All SPs must have appropriate exception handling specific to the method and table.
�	Use error codes of the same type and size of the PK to return values that can be clearly determined to indicate an error (example: -1 might indicate no record was found).  
These should be consistent values across all SPs such that only a single table of error codes is required in the documentation.
*/

-----------------INSERT--------------------------------
CREATE OR REPLACE PROCEDURE spInsertPlayer (
    regNumber VARCHAR2,
    firstName VARCHAR2,
    lastName VARCHAR2,
    isActive NUMBER,
    errorCode OUT NUMBER
) AS
    newPID INT := 0;
BEGIN
    -- getting auto number
    SELECT PLAYERID_SEQ.NEXTVAL INTO newPID FROM DUAL;

    -- insert values
    INSERT INTO players 
    VALUES (newPID, regNumber, firstName, lastName, isActive);
    
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spInsertPlayer;
/

-- execute it
DECLARE
    errorCode NUMBER;
BEGIN
    spInsertPlayer('000007', 'Cristiano', 'Ronaldo', 1, errorCode);
END;

/
--Test it 
SELECT * FROM players
WHERE regNumber=000007;
/
-------------UPDATE-----------------------------
CREATE OR REPLACE PROCEDURE spUpdatePlayer(
    pPlayerID IN NUMBER,
    pRegNumber IN VARCHAR2,
    pFirstName IN VARCHAR2,
    pLastName IN VARCHAR2,
    pIsActive IN NUMBER,
    errorCode OUT NUMBER
) AS
BEGIN
    UPDATE players
    SET regNumber = pRegNumber,
        firstName = pFirstName,
        lastName = pLastName, 
        isActive = pIsActive
    WHERE PlayerID = pPlayerID;
    
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spUpdatePlayer;

/
--execute

DECLARE
    errorCode NUMBER;
BEGIN
    spUpdatePlayer(7, '000010', 'Diego', 'Maradona', 0, errorCode);
     IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;

/
--test
SELECT * FROM players
WHERE playerID=7;
/
-------------------------DELETE---------------
CREATE OR REPLACE PROCEDURE spDeletePlayer(pID IN NUMBER, errorCode OUT NUMBER) AS
BEGIN
    DELETE FROM players WHERE playerID = pID;
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spDeletePlayer;
/

--execute
DECLARE
    errorCode NUMBER;
BEGIN
    spDeletePlayer(10, errorCode);
     IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;

--test
SELECT * FROM players
WHERE playerID=10;

------------SELECT----------------------
CREATE OR REPLACE PROCEDURE spGetPlayerByID(pID IN NUMBER, errorCode OUT NUMBER, playerName OUT VARCHAR2, playerLastName OUT VARCHAR2, playerIsActive OUT NUMBER) AS
BEGIN
    SELECT firstName, lastName, isActive
    INTO playerName, playerLastName, playerIsActive
    FROM players
    WHERE playerID = pID;
    
       --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
        
END spGetPlayerByID;
/

--execute
DECLARE
    errorCode NUMBER;
    firstName VARCHAR2(25); 
    lastName VARCHAR2(25); 
    isActive NUMBER;
BEGIN
    spGetPlayerByID(1317, errorCode, firstName, lastName, isActive);
     IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

/******************************
         QUESTION 2    -  using DBMS_OUTPUT
*******************************/

/*
For each table in (Players, Teams, Rosters), create an additional Stored Procedure, called spTableNameSelectAll that outputs 
the contents of the table to the script window (using DBMS_OUTPUT) for the standard SELECT * FROM <tablename> statement.
*/

--------GET ALL PLAYERS-------
CREATE OR REPLACE PROCEDURE spPlayersSelectAll(errorCode OUT NUMBER) AS
BEGIN
    FOR pPlayers IN (SELECT * FROM players) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('PlayerID: ' || pPlayers.PlayerID);
        DBMS_OUTPUT.PUT_LINE('Registration Number: ' || pPlayers.regNumber);
        DBMS_OUTPUT.PUT_LINE('Name: ' || pPlayers.FirstName || ' ' || pPlayers.LastName);
        IF pPlayers.isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Player is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Player is not active');
        END IF;
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;
    
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spPlayersSelectAll;
/

--execute 
DECLARE
    errorCode NUMBER;
BEGIN
    spPlayersSelectAll(errorCode);
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/


--------GET ALL TEAMS-------
CREATE OR REPLACE PROCEDURE spTeamsSelectAll(errorCode OUT NUMBER) AS
BEGIN
    FOR tTeams IN (SELECT * FROM teams) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('TeamID: ' || tTeams.teamid);
        DBMS_OUTPUT.PUT_LINE('Team Name: ' || tTeams.teamname);

        IF tTeams.isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Team is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Team is not active');
        END IF;
        DBMS_OUTPUT.PUT_LINE('Jersey Colour: ' || tTeams.jerseycolour);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;
    
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spTeamsSelectAll;
/
--execute 
DECLARE
    errorCode NUMBER;
BEGIN
    spTeamsSelectAll(errorCode);
    
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

--------GET ALL ROSTER-------
CREATE OR REPLACE PROCEDURE spRostersSelectAll(errorCode OUT NUMBER) AS
BEGIN
    FOR rRosters IN (SELECT * FROM rosters) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('RosterID: ' || rRosters.rosterid);
        DBMS_OUTPUT.PUT_LINE('PlayersID: ' || rRosters.playerid);
        DBMS_OUTPUT.PUT_LINE('TeamID: ' || rRosters.teamid);
        
        IF rRosters.isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Team is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Team is not active');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Jersey Number: ' || rRosters.jerseynumber);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;
    
    --error handle
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:=-5;
    ELSIF SQL%ROWCOUNT = 1 THEN
         errorCode:=0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1; 
END spRostersSelectAll;
/
--execute 
DECLARE
    errorCode NUMBER;
BEGIN
    spRostersSelectAll(errorCode);
    
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

/******************************
         QUESTION 3            -- not using DBMS_OUTPUT  ---the reaserch question
*******************************/
/*
3.	Repeat Step 2 but returning the table in the output of the SP.  Use a non-saved procedure to show receiving the data and outputting it to the script window.  
NOTE: Some research will be required here as we did not cover this in class.

*/
    --output Cursor
     /*  Research part that Clint said
    A SYS_REFCURSOR is a system-defined cursor type in Oracle Database that can be used to pass query 
    result sets between stored procedures, functions, or between a stored procedure and a calling application. 
    It's a reference cursor, meaning that it does not store the result set but rather holds a reference to the 
    result set generated by a SELECT statement.
    */
   

--------GET ALL PLAYERS-------
CREATE OR REPLACE PROCEDURE spPlayersSelectAll(
    errorCode OUT NUMBER,
    cPlayer OUT SYS_REFCURSOR --output Cursor
) AS
BEGIN
    OPEN cPlayer FOR
    SELECT PlayerID, regNumber, FirstName || ' ' || LastName AS FullName, isActive
    FROM players;

    -- error
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := -5;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1;
END spPlayersSelectAll;
/

--execute 

DECLARE
    errorCode NUMBER;
    cPlayer SYS_REFCURSOR;    
    playerID NUMBER;
    regNumber VARCHAR2(50);
    playerName VARCHAR2(100);
    isActive NUMBER;
BEGIN
    spPlayersSelectAll(errorCode, cPlayer);

    LOOP
        FETCH cPlayer INTO playerID, regNumber, playerName, isActive;
        EXIT WHEN cPlayer%NOTFOUND;

        -- display
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('PlayerID: ' || playerID);
        DBMS_OUTPUT.PUT_LINE('Registration Number: ' || regNumber);
        DBMS_OUTPUT.PUT_LINE('Name: ' || playerName);
        IF isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Player is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Player is not active');
        END IF;
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;

    CLOSE cPlayer;

    -- error
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

--------GET ALL TEAMS-------
CREATE OR REPLACE PROCEDURE spTeamsSelectAll(
    errorCode OUT NUMBER,
    cTeam OUT SYS_REFCURSOR  
) AS
BEGIN
    OPEN cTeam FOR
    SELECT * FROM teams;

    -- error
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := -5;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1;
END spTeamsSelectAll;
/

--execute
DECLARE
    errorCode NUMBER;
    cTeam SYS_REFCURSOR;
    teamid NUMBER;
    teamname VARCHAR2(25);
    isActive NUMBER;
    jerseycolour VARCHAR2(25);
BEGIN
    spTeamsSelectAll(errorCode, cTeam);

    LOOP
        FETCH cTeam INTO teamid, teamname, isActive, jerseycolour;
        EXIT WHEN cTeam%NOTFOUND;

        -- display
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('TeamID: ' || teamid);
        DBMS_OUTPUT.PUT_LINE('Team Name: ' || teamname);

        IF isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Team is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Team is not active');
        END IF;

        DBMS_OUTPUT.PUT_LINE('Jersey Colour: ' || jerseycolour);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;

    CLOSE cTeam;

    -- error
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/
--------GET ALL ROSTER-------
CREATE OR REPLACE PROCEDURE spRostersSelectAll(
    errorCode OUT NUMBER,
    cRosters OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN cRosters FOR
    SELECT * FROM rosters;

    -- eror
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := -5;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := -1;
END spRostersSelectAll;
/
--execute 
DECLARE
    errorCode NUMBER;
    cRosters SYS_REFCURSOR;
    rosterid NUMBER;
    playerid NUMBER;
    teamid NUMBER;
    isActive NUMBER;
    jerseynumber NUMBER;
BEGIN
    spRostersSelectAll(errorCode, cRosters);

    LOOP
        FETCH cRosters INTO rosterid, playerid, teamid, isActive, jerseynumber;
        EXIT WHEN cRosters%NOTFOUND;

        -- dispaly
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('RosterID: ' || rosterid);
        DBMS_OUTPUT.PUT_LINE('PlayersID: ' || playerid);
        DBMS_OUTPUT.PUT_LINE('TeamID: ' || teamid);

        IF isActive = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Team is active');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Team is not active');
        END IF;

        DBMS_OUTPUT.PUT_LINE('Jersey Number: ' || jerseynumber);
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;

    CLOSE cRosters;

    -- error
    IF errorCode != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

/******************************
         QUESTION 4
*******************************/
/*
Create a view which stores the �players on teams� information, called vwPlayerRosters which includes all fields from players, rosters, 
and teams in a single output table.  You only need to include records that have exact matches.
*/

CREATE OR REPLACE VIEW vwPlayerRosters AS
SELECT 
-- can't use * becuase there are duplicates in rosters and players with the same name
    p.playerid AS playerID,
    p.regNumber AS pRegNumber,
    p.firstName AS pFirstName,
    p.lastName AS pLastName,
    p.isActive AS pIsActive,
    r.playerid AS rPlayerID,
    r.rosterid AS rosterID,
    r.teamid AS rTeamID,
    r.isActive AS rosterIsActive,
    t.teamname AS teamName,
    t.isActive AS tIsActive,
    t.jerseycolour AS tJerseycolour
FROM players p
INNER JOIN rosters r ON p.playerid = r.playerid AND r.isActive = 1
INNER JOIN teams t ON r.teamid = t.teamid;
/
/******************************
         QUESTION 5
*******************************/
/*
Using the vwPlayerRosters view, create an SP, named spTeamRosterByID, that outputs, the team rosters, with names, 
for a team given a specific input parameter of teamID
*/

CREATE OR REPLACE PROCEDURE spTeamRosterByID(
    pTeamID IN NUMBER,
    cPlayer OUT SYS_REFCURSOR,
    pErrorCode OUT NUMBER
) AS
BEGIN
    OPEN cPlayer FOR
        SELECT 
            teamName, 
            rosterID, 
            pFirstName || ' ' || pLastName AS fullName
        FROM vwPlayerRosters
        WHERE rTeamID = pTeamID;

    -- error
    IF NOT cPlayer%ISOPEN THEN
        pErrorCode := -5;
    ELSE
        pErrorCode := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        pErrorCode := -1;
END spTeamRosterByID;
/

-- execute
DECLARE
    teamID NUMBER := 212;
    cTeamRoastPlayer SYS_REFCURSOR;
    teamName VARCHAR2(25); 
    rosterID NUMBER;        
    fullName VARCHAR2(50); 
    errorCode NUMBER;
BEGIN
    spTeamRosterByID(teamID, cTeamRoastPlayer, errorCode);

    IF errorCode = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Fetching Data...');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Team Name | Roster ID | Full Name');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');

        LOOP
            FETCH cTeamRoastPlayer INTO teamName, rosterID, fullName;
            EXIT WHEN cTeamRoastPlayer%NOTFOUND;

            -- display
            DBMS_OUTPUT.PUT_LINE(
                RPAD(teamName, 9) || ' | ' ||
                RPAD(rosterID, 9) || ' | ' ||
                RPAD(fullName, 25) 
            );
        END LOOP;
        CLOSE cTeamRoastPlayer;
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;
/

/******************************
         QUESTION 6
*******************************/
/*
Repeat task 4, by creating another similar stored procedure, named spTeamRosterByName, 
that receives a string parameter and returns the team roster, with names, for a team found through 
a search string.  The entered parameter may be any part of the name.
*/

CREATE OR REPLACE PROCEDURE spTeamRosterByName(
    tName IN VARCHAR2,
    cPlayer OUT SYS_REFCURSOR,
    pErrorCode OUT NUMBER
) AS
BEGIN
    OPEN cPlayer FOR
        SELECT 
            teamName, 
            rosterID, 
            pFirstName || ' ' || pLastName AS fullName
        FROM vwPlayerRosters
        WHERE LOWER(teamName) LIKE LOWER(tName) ;

    -- error
    IF NOT cPlayer%ISOPEN THEN
        pErrorCode := -5;
    ELSE
        pErrorCode := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        pErrorCode := -1;
END spTeamRosterByName;

/
DECLARE
    vTeamName VARCHAR2(25);
    cTeamRoastPlayer SYS_REFCURSOR;
    cTeamRoast VARCHAR2(25);
    rosterID NUMBER;
    fullName VARCHAR2(50);
    errorCode NUMBER;
BEGIN
    vTeamName := '&team_name'; --get team
    spTeamRosterByName(vTeamName, cTeamRoastPlayer, errorCode);

    IF errorCode = 0 THEN
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Team Name | Roster ID | Full Name');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');

        LOOP
            FETCH cTeamRoastPlayer INTO cTeamRoast, rosterID, fullName;
            EXIT WHEN cTeamRoastPlayer%NOTFOUND;

            -- Display
            DBMS_OUTPUT.PUT_LINE(
                RPAD(cTeamRoast, 11) || ' | ' ||
                RPAD(rosterID, 11) || ' | ' ||
                RPAD(fullName, 25)
            );
        END LOOP;

        CLOSE cTeamRoastPlayer;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || errorCode);
    END IF;
END;


/******************************
         QUESTION 7
*******************************/
--Create a view that returns the number of players currently registered on each team, called vwTeamsNumPlayers.
CREATE OR REPLACE VIEW vwTeamsNumPlayers AS
    SELECT 
        t.teamID, 
        COUNT(p.playerid) AS NumPlayers
    FROM players p
        RIGHT JOIN rosters r ON r.playerid = p.playerid
        RIGHT JOIN teams t ON t.teamid = r.teamid
    GROUP BY t.teamid;
    
-- Execute
SELECT * FROM vwTeamsNumPlayers;


/******************************
         QUESTION 8
*******************************/
--Using vwTeamsNumPlayers create a user defined function, that given the team PK, will return the number of players currently registered, called fncNumPlayersByTeamID.
CREATE OR REPLACE FUNCTION fncNumPlayersByTeamID (team INT)
    RETURN INT IS 
    numOfPlayer INT := 0;  -- declared variable that was never used
BEGIN
    SELECT NumPlayers
    INTO numOfPlayer
    FROM vwTeamsNumPlayers vtp
    WHERE vtp.teamID = team;
    
    RETURN numOfPlayer;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -5;
END fncNumPlayersByTeamID;

--Execute
DECLARE
    team INT;
    res INT;
BEGIN
    team := 210; -- test data: 210(o/p: 18)
    res:= fncNumPlayersByTeamID(team);
    DBMS_OUTPUT.PUT_LINE('Number of Player in team # '|| team || ': ' || res);
END;

/******************************
         QUESTION 9
*******************************/
--      Create a view, called vwSchedule, 
--      that shows all games, but includes the written names for teams and locations, in addition to the PK/FK values.  
--      Do not worry about division here.
CREATE OR REPLACE VIEW vwSchedule AS
    SELECT
        g.gameid,
        g.divid,
        g.gamenum,
        g.gamedatetime,
        g.hometeam,
        t1.teamname AS HomeTeamName,
        g.homescore,
        g.visitteam,
        t2.teamname AS VisitTeamName,
        g.visitscore,
        g.locationid,
        locationname,
        g.isplayed,
        g.notes
    FROM games g
        JOIN sllocations sll ON sll.locationid = g.locationid
        JOIN teams t1 ON g.hometeam = t1.teamid
        JOIN teams t2 ON g.visitteam = t2.teamid;

-- Execute
SELECT * FROM vwSchedule;

/******************************
         QUESTION 10
*******************************/
--      Create a stored procedure, spSchedUpcomingGames, using DBMS_OUTPUT, 
--      that displays the games to be played in the next n days, 
--      where n is an input parameter.  Make sure your code will work on any day of the year.
CREATE OR REPLACE PROCEDURE spSchedUpcomingGames (nextGameDay INT) AS  -- games.gamedatetime%TYPE
    matchFound BOOLEAN := FALSE;
    e_negativeDay EXCEPTION;
    BEGIN
    IF nextGameDay < 0 THEN
        RAISE e_negativeDay;
    END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Display matches in the next ' || nextGameDay || ' days' );
    FOR r IN(
        SELECT * 
        FROM vwSchedule s
        WHERE s.gameDateTime BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + nextGameDay
    )LOOP
        matchFound := TRUE;
        DBMS_OUTPUT.PUT_LINE(RPAD('Game ID',16) || LPAD(': ', 2) || r.gameid);
        DBMS_OUTPUT.PUT_LINE(RPAD('Game Date-time',16) || LPAD(': ', 2) || to_char(r.gamedatetime, 'DD Month, YYYY'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Home Team',16) || LPAD(': ', 2) || r.HomeTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Visit Team',16) || LPAD(': ', 2) || r.VisitTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Location',16) || LPAD(': ', 2) || r.locationname);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
        
    IF NOT matchFound THEN 
         DBMS_OUTPUT.PUT_LINE('No Matches Found');
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    EXCEPTION 
        WHEN e_negativeDay THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Input number must be > 0');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: A general error occured');
END spSchedUpcomingGames;

-- execute
BEGIN
    spSchedUpcomingGames(4);
    spSchedUpcomingGames(40);
    spSchedUpcomingGames(-1);
END;



/******************************
         QUESTION 11
*******************************/
/*
Create a stored procedure, spSchedPastGames, using DBMS_OUTPUT, that displays the games that have been played 
in the past n days, where n is an input parameter.  Make sure your code will work on any day of the year.
*/
CREATE OR REPLACE PROCEDURE spSchedPastGames(
    n NUMBER
)AS
    matchCt number:=0;
    date_diff DATE;
    exp1 EXCEPTION;
    CURSOR data_cur IS SELECT * FROM vwSchedule WHERE gamedatetime BETWEEN TO_DATE(date_diff, 'YY-MM-DD') AND TO_DATE(SYSDATE, 'YY-MM-DD');
    --hard coding to_date cast required otherwise games where sysdate-1 is not captured, or n has to be +1
    data_rec vwSchedule%ROWTYPE;
BEGIN
    IF n <=0 THEN
        RAISE exp1;
    END IF;
    date_diff := SYSDATE -n;
    OPEN data_cur;
    LOOP
        matchCt:= matchCt + 1;
        FETCH data_cur INTO data_rec;
        EXIT WHEN data_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD('Game ID',16) || LPAD(': ', 2) || data_rec.gameid);
        DBMS_OUTPUT.PUT_LINE(RPAD('Game Date-time',16) || LPAD(': ', 2) || to_char(data_rec.gamedatetime, 'DD Month, YYYY'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Home Team',16) || LPAD(': ', 2) || data_rec.HomeTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Visit Team',16) || LPAD(': ', 2) || data_rec.VisitTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Location',16) || LPAD(': ', 2) || data_rec.locationname);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    CLOSE data_cur;
    IF matchCt =0 THEN
        DBMS_OUTPUT.PUT_LINE('No matches found between ' || TO_CHAR(date_diff, 'Mon DD, YYYY') || ' and ' || TO_CHAR(SYSDATE, 'Mon DD, YYYY'));
    END IF;
EXCEPTION
WHEN INVALID_NUMBER
    THEN  DBMS_OUTPUT.PUT_LINE('ERROR: Value entered must be a number');
WHEN exp1
    THEN DBMS_OUTPUT.PUT_LINE('ERROR: Must be a value greater than 0');
WHEN TOO_MANY_ROWS 
    THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
WHEN NO_DATA_FOUND 
    THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
WHEN OTHERS 
    THEN DBMS_OUTPUT.PUT_LINE('Error!');
END;

-- execute
BEGIN
    spSchedPastGames(1);
END;

/******************************
         QUESTION 12
*******************************/
/*Using the Standings calculation demo code provided earlier in the semester, create a Stored Procedure, 
named spRunStandings, that replaces a temporary static table, named tempStandings, with the output of 
the SELECT code provided.*/ 
CREATE OR REPLACE PROCEDURE spRunStandings(
    stand_ref_cur IN OUT SYS_REFCURSOR
)
IS
BEGIN
 --USES THE CALCULATION DEMO CODE
 OPEN stand_ref_cur FOR 
    SELECT
        TheTeamID,
        (SELECT teamname FROM teams WHERE teamid = t.TheTeamID) AS teamname,
        SUM(GamesPlayed) AS GP,
        SUM(Wins) AS W,
        SUM(Losses) AS L,
        SUM(Ties) AS T,
        SUM(Wins) * 3 + SUM(Ties) AS Pts,
        SUM(GoalsFor) AS GF,
        SUM(GoalsAgainst) AS GA,
        SUM(GoalsFor) - SUM(GoalsAgainst) AS GD
    FROM (
        SELECT
            hometeam AS TheTeamID,
            COUNT(gameID) AS GamesPlayed,
            SUM(homescore) AS GoalsFor,
            SUM(visitscore) AS GoalsAgainst,
            SUM(
                CASE
                    WHEN homescore > visitscore THEN 1
                    ELSE 0
                    END) AS Wins,
            SUM(
                CASE
                    WHEN homescore < visitscore THEN 1
                    ELSE 0
                    END) AS Losses,
            SUM(
                CASE
                    WHEN homescore = visitscore THEN 1
                    ELSE 0
                    END) AS Ties
        FROM games
        WHERE isPlayed = 1
        GROUP BY hometeam
        
        UNION ALL
        -- perspective of the visiting team     
        SELECT
            visitteam AS TheTeamID,
            COUNT(gameID) AS GamesPlayed,
            SUM(visitscore) AS GoalsFor,
            SUM(homescore) AS GoalsAgainst,
            SUM(
                CASE
                    WHEN homescore < visitscore THEN 1
                    ELSE 0
                    END) AS Wins,
            SUM(
                CASE
                    WHEN homescore > visitscore THEN 1
                    ELSE 0
                    END) AS Losses,
            SUM(
                CASE
                    WHEN homescore = visitscore THEN 1
                    ELSE 0
                    END) AS Ties
        FROM games
        WHERE isPlayed = 1
        GROUP BY visitteam) t
    GROUP BY TheTeamID;
EXCEPTION
	WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error!');
END;

--execute
DECLARE
    stand_cursor SYS_REFCURSOR;
    teamid teams.teamid%TYPE;
    teamname teams.teamname%TYPE;
    GP NUMBER;
    W NUMBER;
    L NUMBER;
    T NUMBER;
    PTS NUMBER;
    GF NUMBER;
    GA NUMBER;
    GD NUMBER;
BEGIN
    spRunStandings(stand_cursor); --call the sp
    LOOP
        FETCH stand_cursor INTO teamid, teamname, GP, W, L, T, PTS, GF, GA, GD;
        EXIT WHEN stand_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Team ID: '|| teamid);
        DBMS_OUTPUT.PUT_LINE('Team Name: '|| teamname);
        DBMS_OUTPUT.PUT_LINE('Group plays: '|| gp);
        DBMS_OUTPUT.PUT_LINE('Wins: '|| w);
        DBMS_OUTPUT.PUT_LINE('Loses: '|| l);
        DBMS_OUTPUT.PUT_LINE('Ties: '|| t);
        DBMS_OUTPUT.PUT_LINE('Points: '|| pts);
        DBMS_OUTPUT.PUT_LINE('Goals For: '|| gf);
        DBMS_OUTPUT.PUT_LINE('Goals Against: '|| ga);
        DBMS_OUTPUT.PUT_LINE('Goals Difference: '|| gd); 
        DBMS_OUTPUT.PUT_LINE(' '); 
    END LOOP;
    CLOSE stand_cursor;
END;


/******************************
         QUESTION 13
*******************************/
/*Following up with Step 12, create a Trigger in the system to automate the execution of the spRunStandings SP 
when any row in the games table is updated.  Essentially meaning that software can run SELECT * FROM tempStandings; 
and always have up to date standings.*/
CREATE OR REPLACE TRIGGER trgUpdateStnd
AFTER UPDATE OR INSERT ON games
DECLARE
    stand_cursor SYS_REFCURSOR;
    teamid teams.teamid%TYPE;
    teamname teams.teamname%TYPE;
    GP NUMBER;
    W NUMBER;
    L NUMBER;
    T NUMBER;
    PTS NUMBER;
    GF NUMBER;
    GA NUMBER;
    GD NUMBER;
BEGIN
    spRunStandings(stand_cursor); --call the sp after update or insert
    LOOP
        FETCH stand_cursor INTO teamid, teamname, GP, W, L, T, PTS, GF, GA, GD;
        EXIT WHEN stand_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Team ID: '|| teamid);
        DBMS_OUTPUT.PUT_LINE('Team Name: '|| teamname);
        DBMS_OUTPUT.PUT_LINE('Group plays: '|| gp);
        DBMS_OUTPUT.PUT_LINE('Wins: '|| w);
        DBMS_OUTPUT.PUT_LINE('Loses: '|| l);
        DBMS_OUTPUT.PUT_LINE('Ties: '|| t);
        DBMS_OUTPUT.PUT_LINE('Points: '|| pts);
        DBMS_OUTPUT.PUT_LINE('Goals For: '|| gf);
        DBMS_OUTPUT.PUT_LINE('Goals Against: '|| ga);
        DBMS_OUTPUT.PUT_LINE('Goals Difference: '|| gd); 
        DBMS_OUTPUT.PUT_LINE(' '); 
    END LOOP;
    CLOSE stand_cursor;
END;

--update execute triggers the spStandings
--ALERT: please delete ANY existing triggers for update or insert on games
UPDATE games SET homescore = 5 WHERE gameid = 1;
UPDATE games SET visitscore = 5 WHERE gameid = 1;

/******************************
         QUESTION 14
*******************************/
/*Each group must be creative and come up with an object (SP, UDF, or potentially trigger), 
of your own choosing, that will be built in the database to help support the same ideals of the above objects..*/
--spMVPperteam displays a list of top players in each team
--teams that have no goals scored are not included
--useful for when a club bids for a player transfer
CREATE OR REPLACE PROCEDURE spMVPperteam AS
CURSOR mvp_cur IS SELECT p.playerid, 
    lastname,
    firstname,
    SUM(numgoals) AS goalCt,
    g.teamid,
    teamname
FROM players p 
    JOIN goalscorers g ON p.playerID = g.playerid
    JOIN teams t ON g.teamid = t.teamid
HAVING(SUM(numgoals)) || g.teamid IN (
    SELECT MAX(goalCt) || teamid
    FROM(
        SELECT p.playerid, 
            lastname,
            firstname,
            SUM(numgoals) AS goalCt,
            teamid 
        FROM players p JOIN goalscorers g ON p.playerID = g.playerid
        GROUP BY p.playerid, lastname,firstname, teamid
    )
    GROUP BY teamid
)
GROUP BY p.playerid, lastname,firstname, g.teamid, teamname
ORDER BY goalct DESC, g.teamID DESC;
pid players.playerid%TYPE;
lname players.lastname%TYPE;
fname players.firstname%TYPE;
goals goalscorers.numgoals%TYPE;
teamID teams.teamid%TYPE;
teamNm teams.teamname%TYPE;
BEGIN
DBMS_OUTPUT.PUT_LINE('List of top players: ' );
    OPEN mvp_cur;
    LOOP
        FETCH mvp_cur INTO pid,lname,fname,goals,teamID,teamNm;
        EXIT WHEN mvp_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Player ID: ' || pid || ' ' || lname || ', '|| fname );
        DBMS_OUTPUT.PUT_LINE('Team ID: ' || teamID|| ' ' || teamNm );
        DBMS_OUTPUT.PUT_LINE('Goals made: ' || goals);
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
    CLOSE mvp_cur;
EXCEPTION
	WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error!');
END;


--execute
BEGIN
    spMVPperteam();
END;

