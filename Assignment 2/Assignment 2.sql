/******************************
Group 1 - Assignment 2 - NDD
Date: 2023-11-08 ---------------------------------------TO BE CHANGED 
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
