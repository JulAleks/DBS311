/******************************
Group 1 - Assignment 2 - NDD
Date: 2023-11-10 ---------------------------------------TO BE CHANGED 
Julia Alekssev, 051292134
Ka Ying Chan, 123231227
Audrey Duzon, 019153147
*******************************/

SET SERVEROUTPUT ON;
/******************************
         QUESTION 1
*******************************/
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
         QUESTION 2
*******************************/
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
         QUESTION 3                     ---NOT SURE ABOUT THIS ONE
*******************************/

--------GET ALL PLAYERS-------
CREATE OR REPLACE PROCEDURE playersSelectAll AS
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
      IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-5, 'No data found for the players table', TRUE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-1, 'An error occurred', TRUE);
END playersSelectAll;
/

--execute 

BEGIN
    playersSelectAll;
END;
/

--------GET ALL TEAMS-------
CREATE OR REPLACE PROCEDURE teamsSelectAll AS
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

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-5, 'No data found for the teams table', TRUE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-1, 'An error occurred', TRUE);
END teamsSelectAll;
/

--execute
BEGIN
    teamsSelectAll;
END;

--------GET ALL ROSTER-------
CREATE OR REPLACE PROCEDURE rostersSelectAll AS
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
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-5, 'No data found for the rosters table', TRUE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-1, 'An error occurred', TRUE);
END rostersSelectAll;
/
--execute 

BEGIN
    rostersSelectAll;
END;
/

/******************************
         QUESTION 4
*******************************/
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
CREATE OR REPLACE PROCEDURE spTeamRosterByID(
    pTeamID IN NUMBER
) AS
BEGIN
    FOR tTeamRoster IN (
        SELECT *
        FROM vwPlayerRosters
        WHERE rTeamID = pTeamID  
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('Team Name: ' || tTeamRoster.teamName);  
        DBMS_OUTPUT.PUT_LINE('Roster ID: ' || tTeamRoster.rosterID);  
        DBMS_OUTPUT.PUT_LINE('Player Name: ' || tTeamRoster.pFirstName || ' ' || tTeamRoster.pLastName); 
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No team roster found for the specified teamID');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred.');
END spTeamRosterByID;
/
--execute
DECLARE
    teamID NUMBER := 212; 
BEGIN
    spTeamRosterByID(teamID);
END;
/


/******************************
         QUESTION 6
*******************************/
CREATE OR REPLACE PROCEDURE spTeamRosterByName(
    tName IN VARCHAR2
) AS
BEGIN
    FOR tTeamRoster IN (
        SELECT *
        FROM vwPlayerRosters
        WHERE LOWER(teamName) LIKE LOWER(tName)  
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
        DBMS_OUTPUT.PUT_LINE('Team Name: ' || tTeamRoster.teamName);  
        DBMS_OUTPUT.PUT_LINE('Roster ID: ' || tTeamRoster.rosterID);  
        DBMS_OUTPUT.PUT_LINE('Player Name: ' || tTeamRoster.pFirstName || ' ' || tTeamRoster.pLastName); 
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 40, '-'));
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No team roster found for the specified team name');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred.');
END spTeamRosterByName;

--execute
DECLARE
    teamName VARCHAR2(25) := '&word%'; 
BEGIN
    spTeamRosterByName(teamName);
END;

/


-- 7.	Create a view that returns the number of players currently registered on each team, called vwTeamsNumPlayers.
CREATE OR REPLACE VIEW vwTeamsNumPlayers AS
    SELECT 
        t.teamID, 
        COUNT(p.playerid) AS NumPlayers
    FROM players p
        RIGHT JOIN rosters r ON r.playerid = p.playerid
        RIGHT JOIN teams t ON t.teamid = r.teamid
    GROUP BY t.teamid;
    
-- Q7 Execute
SELECT * FROM vwTeamsNumPlayers;

-- 8.	Using vwTeamsNumPlayers create a user defined function, that given the team PK, will return the number of players currently registered, called fncNumPlayersByTeamID.
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

-- Q8 Execute
DECLARE
    team INT;
    res INT;
BEGIN
    team := 210; -- test data: 210(o/p: 18)
    res:= fncNumPlayersByTeamID(team);
    DBMS_OUTPUT.PUT_LINE('Number of Player in team # '|| team || ': ' || res);
END;


-- 9.	Create a view, called vwSchedule, 
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

-- Q9 Execute
SELECT * FROM vwSchedule;


-- 10.	Create a stored procedure, spSchedUpcomingGames, using DBMS_OUTPUT, 
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

-- Q10 Execute
BEGIN
    spSchedUpcomingGames(4);
    spSchedUpcomingGames(40);
    spSchedUpcomingGames(-1);
END;

--11.Create a stored procedure, spSchedPastGames, using DBMS_OUTPUT, 
--that displays the games that have been played in the past n days, where n is an input parameter. Make sure your code will work on any day of the year.
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
END;


BEGIN
    spSchedPastGames(1);
END;
