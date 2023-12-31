/***************************************
    DBS311 NDD - ASSIGNMENT 2
    INSTRUCTOR: Clint MacDonald
    
    GROUP 1:
        Julia Alekssev  051292134
        Ka Ying Chan    123231227
        Audrey Duzon    019153147
        
    DATE: 3 DECEMBER 2023
/***************************************

/*
    Exit code (Exit code):
    Success                 : 0
    Generic Error           : -1
    Insert Error            : -2
    Insert Existing ID      : -201
    Update Error            : -3
    Delete Error            : -4
    No Data Found Error     : -5
    Too Many Rows Eeturned  : -6
    Invalid Input           : -7
    Invalid Cursor          : -8
*/
----------------------------------------

SET SERVEROUTPUT ON;

/*
Q1.	For each table in (Players, Teams, Rosters) create Stored Procedures to cover the 4 basic CRUD tasks.
a.	INSERT a new record and if the PK using autonumber, the SP returns the new PK,
b.	UPDATE an existing record given the PK value,
c.	DELETE an existing record given the PK value, and
d.	SELECT return all fields in a single row from a table given a PK value.
�	Name the SPs using the following guide:  spTableNameMethod (example spPlayersInsert)
�	Do not use DBMS_OUTPUT in the procedures in any way.
    If you use it for debugging purposes, make sure it is commented out in the final submission.
�	All SPs must have appropriate exception handling specific to the method and table.
�	Use Exit codes of the same type and size of the PK to return values that can be clearly determined to indicate an error (example: -1 might indicate no record was found).  
    These should be consistent values across all SPs such that only a single table of Exit codes is required in the documentation.
*/
-- PLAYER INSERT:
CREATE OR REPLACE PROCEDURE spPlayersInsert(
    sp_playerid      IN OUT      players.playerid%TYPE,
    sp_regnumber     IN          players.regnumber%TYPE,
    sp_lastname      IN          players.lastname%TYPE,
    sp_firstname     IN          players.firstname%TYPE,
    sp_isactive      IN          players.isactive%TYPE,
    exitcode         OUT         NUMBER
) AS
BEGIN
    exitcode := 0;
    IF sp_playerid IS NULL THEN
        SELECT MAX(playerid) + 1
        INTO sp_playerid 
        FROM players; 
    END IF;
    
    INSERT INTO players (
        playerid,
        regnumber, 
        lastname, 
        firstname, 
        isactive
        )
    VALUES (
        sp_playerid,
        sp_regnumber, 
        sp_lastname, 
        sp_firstname, 
        sp_isactive
        );
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -2;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        exitcode := -201; -- Insert an EXISTING id.
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersInsert;
/
-- TEST 1 - MANUAL INPUT NUMBER:
-- INSERT players WHERE playerid = 7;
DECLARE 
    inputID players.playerid%TYPE := 7;
    exitcode NUMBER;
BEGIN 
    spPlayersInsert(inputID, 12323, 'Cristiano', 'Ronaldo', 1, exitcode);
    DBMS_OUTPUT.PUT_LINE('Playerid: ' || inputID);
    DBMS_OUTPUT.PUT_LINE('Exit Code: ' || exitcode);
END;
/
-- TEST 2 - AUTONUMBER:
DECLARE 
    inputID players.playerid%TYPE;
    exitcode NUMBER;
BEGIN 
    spPlayersInsert(inputID, 12323, 'Cristiano', 'Ronaldo', 1, exitcode);
    DBMS_OUTPUT.PUT_LINE('Playerid: ' || inputID);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
-- ROLLBACK;


-- PLAYER UPDATE:
CREATE OR REPLACE PROCEDURE spPlayersUpdate(
    sp_playerid      IN      players.playerid%TYPE,
    sp_regnumber     IN      players.regnumber%TYPE,
    sp_lastname      IN      players.lastname%TYPE,
    sp_firstname     IN      players.firstname%TYPE,
    sp_isactive      IN      players.isactive%TYPE,
    exitcode         OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    UPDATE players 
    SET 
        regnumber   = sp_regnumber, 
        lastname    = sp_lastname, 
        firstname   = sp_firstname, 
        isactive    = sp_isactive
    WHERE playerid  = sp_playerid;
    
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -3;
    END IF;
        
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersUpdate;
/

-- TEST 1 - MODIFY DATA:
DECLARE exitcode INT;
BEGIN 
    spPlayersUpdate(7, 12323, 'Diego', 'Maradona', 0, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
SELECT * FROM players
WHERE playerid = 7;
-- TEST 2 - MODIFY NON-EXISTING DATA:
DECLARE exitcode INT;
BEGIN 
    spPlayersUpdate(987666, 55555, 'Ogeid', 'Anodaram', 1, exitcode); -- UPDATE ERROR: -3
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
-- PLAYER DELETE:
CREATE OR REPLACE PROCEDURE spPlayersDelete(
    sp_playerid     IN      players.playerid%TYPE,
    exitcode        OUT     NUMBER
)AS
BEGIN
    exitcode := 0;
    DELETE FROM players
    WHERE playerid = sp_playerid;

    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -4;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersDelete;
/
DECLARE
    exitcode NUMBER;
BEGIN
    spPlayersDelete(7, exitcode); -- DELETE SUCESS: 0
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    spPlayersDelete(7, exitcode); -- NOT EXIST ANY MORE - DELETE FAIL: -4
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END; 
/

-- PLAYER SELECT
CREATE OR REPLACE PROCEDURE spPlayersSelect(
    sp_playerid     IN      players.playerid%TYPE,
    sp_record       OUT     players%ROWTYPE,
    exitcode        OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    
    SELECT *
    INTO sp_record
    FROM players
    WHERE playerid = sp_playerid;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        exitcode := -5;
    WHEN TOO_MANY_ROWS THEN
        exitcode := -6;
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersSelect;
/
-- TEST 1: 
DECLARE
    spRecord players%ROWTYPE;
    exitcode NUMBER;
BEGIN
    spPlayersSelect(7, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('player id: ' || spRecord.playerid);
    DBMS_OUTPUT.PUT_LINE('player lastname: ' || spRecord.lastname);
    DBMS_OUTPUT.PUT_LINE('player firstname: ' || spRecord.firstname);
    DBMS_OUTPUT.PUT_LINE('player regnumber: ' || spRecord.regnumber);
    DBMS_OUTPUT.PUT_LINE('player isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END; 
/
-- TEST 2: 
DECLARE
    spRecord players%ROWTYPE;
    exitcode NUMBER;
BEGIN
    spPlayersSelect(987666, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('player id: ' || spRecord.playerid);
    DBMS_OUTPUT.PUT_LINE('player lastname: ' || spRecord.lastname);
    DBMS_OUTPUT.PUT_LINE('player firstname: ' || spRecord.firstname);
    DBMS_OUTPUT.PUT_LINE('player regnumber: ' || spRecord.regnumber);
    DBMS_OUTPUT.PUT_LINE('player isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END; 
/

-- TEAM INSERT
CREATE OR REPLACE PROCEDURE spTeamsInsert (
    sp_teamid       IN OUT      teams.teamid%TYPE,
    sp_teamname     IN          teams.teamname%TYPE,
    sp_isactive     IN          teams.isactive%TYPE,
    sp_jerseycolour IN          teams.jerseycolour%TYPE,
    exitcode        OUT         NUMBER
) AS
BEGIN
    exitcode := 0;
    IF sp_teamid IS NULL THEN
        SELECT MAX(teamid) + 1
        INTO sp_teamid 
        FROM teams; 
    END IF;
    
    INSERT INTO teams (
        teamid,
        teamname, 
        isactive, 
        jerseycolour
        )
    VALUES (
        sp_teamid,
        sp_teamname, 
        sp_isactive, 
        sp_jerseycolour
        );
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -2;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        exitcode := -201; -- Insert an EXISTING id.
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsInsert; 
/
-- TEST 1 - MANUAL INPUT NUMBER:
-- DELETE FROM teams WHERE teamid = 600;
DECLARE 
    inputID teams.teamid%TYPE := 600;
    exitcode NUMBER;
BEGIN 
    spTeamsInsert(inputID, 'YellowJays', 1, 'Yellow', exitcode);
    DBMS_OUTPUT.PUT_LINE('Teamid: ' || inputID);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
-- TEST 2 - AUTONUMBER:
DECLARE 
    inputID teams.teamid%TYPE;
    exitcode NUMBER;
BEGIN 
    spTeamsInsert(inputID, 'YellowJays', 1, 'Yellow', exitcode);
    DBMS_OUTPUT.PUT_LINE('Playerid: ' || inputID);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
ROLLBACK;

-- TEAM UPDATE:
CREATE OR REPLACE PROCEDURE spTeamsUpdate(
    sp_teamid       IN          teams.teamid%TYPE,
    sp_teamname     IN          teams.teamname%TYPE,
    sp_isactive     IN          teams.isactive%TYPE,
    sp_jerseycolour IN          teams.jerseycolour%TYPE,
    exitcode        OUT         NUMBER
) AS
BEGIN
    exitcode := 0;
    UPDATE teams 
    SET 
        teamname = sp_teamname, 
        isactive = sp_isactive, 
        jerseycolour = sp_jerseycolour
    WHERE teamid = sp_teamid;
    
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -3;
    END IF;
        
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsUpdate;
/
-- TEST 1 - MODIFY DATA:
DECLARE exitcode NUMBER;
BEGIN 
    spTeamsUpdate(600, 'YellowYays', 1, 'Big Yellow', exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
SELECT * FROM teams
WHERE teamid = 600;
-- TEST 2 - MODIFY NON-EXISTING DATA:
/
DECLARE exitcode NUMBER;
BEGIN 
    spTeamsUpdate(666, 'BlackPink', 0, 'Black and Pink', exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
-- TEAM DELETE:
CREATE OR REPLACE PROCEDURE spTeamsDelete(
    sp_teamid     IN      teams.teamid%TYPE,
    exitcode       OUT     NUMBER
)AS
BEGIN
    exitcode := 0;
    DELETE FROM teams
    WHERE teamid = sp_teamid;

    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -4;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsDelete;
/
-- TEST:
DECLARE
    exitcode NUMBER;
BEGIN
    spTeamsDelete(600, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    spTeamsDelete(600, exitcode); -- DOES NOT EXIST ANY MORE
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END; 
/
-- TEAM SELECT
CREATE OR REPLACE PROCEDURE spTeamsSelect(
    sp_teamid     IN      teams.teamid%TYPE,
    sp_record     OUT     teams%ROWTYPE,
    exitcode      OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    
    SELECT *
    INTO sp_record
    FROM teams
    WHERE teamid = sp_teamid;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        exitcode := -5;
    WHEN TOO_MANY_ROWS THEN
        exitcode := -6;
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsSelect;
/
-- TEST: 
DECLARE
    spRecord teams%ROWTYPE;
    exitcode NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 1:');
    spTeamsSelect(600, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('Team id: ' || spRecord.teamid);
    DBMS_OUTPUT.PUT_LINE('Team name: ' || spRecord.teamname);
    DBMS_OUTPUT.PUT_LINE('Team isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Team jersey colour: ' || spRecord.jerseycolour);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 2:');
    spTeamsSelect(666, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('Team id: ' || spRecord.teamid);
    DBMS_OUTPUT.PUT_LINE('Team name: ' || spRecord.teamname);
    DBMS_OUTPUT.PUT_LINE('Team isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Team jersey colour: ' || spRecord.jerseycolour);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('------------------------------');
END; 
/
-- ROSTER INSERT
CREATE OR REPLACE PROCEDURE spRostersInsert (
    sp_rosterid     IN OUT      rosters.rosterid%TYPE,
    sp_playerid     IN          rosters.playerid%TYPE,
    sp_teamid       IN          rosters.teamid%TYPE,
    sp_isactive     IN          rosters.isactive%TYPE,
    sp_jerseynumber IN          rosters.jerseynumber%TYPE,
    exitcode        OUT         NUMBER
) AS
    playerExist     NUMBER;
    teamExist       NUMBER;
BEGIN
    exitcode := 0;
    
    -- POSSIBLE ERROR: 
    -- 1. playerid not exist
    SELECT COUNT(*)
    INTO playerExist
    FROM players
    WHERE playerid = sp_playerid;
    -- 2. teamid not exist
    SELECT COUNT(*)
    INTO teamExist
    FROM teams
    WHERE teamid = sp_teamid;
    
    IF playerExist = 0 OR teamExist = 0 THEN
        exitcode := -5; -- No Data Found
        RETURN;
    END IF;
    
    INSERT INTO rosters (
        rosterid,
        playerid, 
        teamid, 
        isactive,
        jerseynumber
        )
    VALUES (
        sp_rosterid, -- ROSTERID GENERATED BY DEFAULT ON NULL AS IDENTITY
        sp_playerid, 
        sp_teamid, 
        sp_isactive,
        sp_jerseynumber
        ) 
        RETURNING rosterid INTO sp_rosterid; -- RETURN NEW AUTOMATICALLY GENERATED ID TO OUT NUMBER
        
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -2;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        exitcode := -201; -- Insert an EXISTING id.
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersInsert; 
/

-- TEST:
-- **INSERT** DATA FOR TESTING:
DECLARE 
    inputID players.playerid%TYPE := 7;
    exitcode INT;
BEGIN spPlayersInsert(inputID, 12323, 'Doe', 'Jane', 1, exitcode);
END;
DECLARE 
    inputID teams.teamid%TYPE := 600;
    exitcode NUMBER;
BEGIN spTeamsInsert(inputID, 'YellowJays', 1, 'Yellow', exitcode);
END;
/
-- **DELETE** DATA FOR TESTING:
DECLARE exitcode INT;
BEGIN spPlayersDelete(7, exitcode);
END;
DECLARE exitcode INT;
BEGIN spTeamsDelete(600, exitcode);
END;
/
DELETE FROM rosters WHERE rosterid = 900;

-- START TESTING:
/
DECLARE 
    inputID rosters.rosterid%TYPE := 900;
    exitcode NUMBER;
BEGIN 
    spRostersInsert(inputID, 7, 600, 1, 16, exitcode);
    DBMS_OUTPUT.PUT_LINE('inputID: ' || inputID || ' | ' || 'Exit code: ' || exitcode);
END;
/
SELECT * FROM rosters
WHERE rosterid = 900;
-- TEST - AUTONUMBER:
/
DECLARE 
    inputID rosters.rosterid%TYPE;
    exitcode NUMBER;
BEGIN 
    spRostersInsert(inputID, 7, 600, 1, 16, exitcode);
    DBMS_OUTPUT.PUT_LINE('inputID: ' || inputID || ' | ' || 'Exit code: ' || exitcode);
END;
/
ROLLBACK;


-- ROSTER UPDATE:
/
CREATE OR REPLACE PROCEDURE spRostersUpdate(
    sp_rosterid     IN          rosters.rosterid%TYPE,
    sp_playerid     IN          rosters.playerid%TYPE,
    sp_teamid       IN          rosters.teamid%TYPE,
    sp_isactive     IN          rosters.isactive%TYPE,
    sp_jerseynumber IN          rosters.jerseynumber%TYPE,
    exitcode        OUT         NUMBER
) AS
    playerExist     NUMBER;
    teamExist       NUMBER;
BEGIN
    exitcode := 0;
    
    -- POSSIBLE ERROR: 
    -- 1. playerid not exist
    SELECT COUNT(*)
    INTO playerExist
    FROM players
    WHERE playerid = sp_playerid;
    -- 2. teamid not exist
    SELECT COUNT(*)
    INTO teamExist
    FROM teams
    WHERE teamid = sp_teamid;
    
    IF playerExist = 0 OR teamExist = 0 THEN
        exitcode := -5; -- No data found
        RETURN;
    END IF;
    
    UPDATE rosters 
    SET 
        playerid        = sp_playerid,
        teamid          = sp_teamid,
        isactive        = sp_isactive,
        jerseynumber    = sp_jerseynumber
    WHERE rosterid  = sp_rosterid;
    
    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -3;
    END IF;
        
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersUpdate;
/

-- TEST:
DECLARE exitcode NUMBER;
BEGIN 
    spRostersUpdate(900, 7, 600, 1, 99, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/
SELECT * FROM rosters
WHERE rosterid = 900;
-- TEST 2 modifying non-existing data:
DECLARE exitcode NUMBER;
BEGIN 
    spRostersUpdate(900, 1026, 600, 1, 99, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END;
/

-- ROSTER DELETE:
CREATE OR REPLACE PROCEDURE spRostersDelete(
    sp_rosterid     IN      rosters.rosterid%TYPE,
    exitcode         OUT     NUMBER
)AS
BEGIN
    exitcode := 0;
    DELETE FROM rosters
    WHERE rosterid = sp_rosterid;

    IF SQL%ROWCOUNT = 0 THEN
        exitcode := -4;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersDelete;
/
-- TEST:
DECLARE
    exitcode NUMBER;
BEGIN
    spRostersDelete(900, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    spRostersDelete(900, exitcode); -- TRY TO DELETE TWICE
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
END; 
/
-- ROSTER SELECT
CREATE OR REPLACE PROCEDURE spRostersSelect(
    sp_rosterid     IN      rosters.rosterid%TYPE,
    sp_record       OUT     rosters%ROWTYPE,
    exitcode        OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    
    SELECT *
    INTO sp_record
    FROM rosters
    WHERE rosterid = sp_rosterid;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        exitcode := -5;
    WHEN TOO_MANY_ROWS THEN
        exitcode := -6;
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersSelect;
/
-- TEST: 
DECLARE
    spRecord rosters%ROWTYPE;
    exitcode NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 1:');
    spRostersSelect(900, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('Roster id: ' || spRecord.rosterid);
    DBMS_OUTPUT.PUT_LINE('Roster playerID: ' || spRecord.playerid);
    DBMS_OUTPUT.PUT_LINE('Roster teamID: ' || spRecord.teamid);
    DBMS_OUTPUT.PUT_LINE('Roster isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Roster jersey number: ' || spRecord.jerseynumber);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    DBMS_OUTPUT.PUT_LINE('TEST 2:');
    spRostersSelect(901, spRecord, exitcode);
    DBMS_OUTPUT.PUT_LINE('Roster id: ' || spRecord.rosterid);
    DBMS_OUTPUT.PUT_LINE('Roster playerID: ' || spRecord.playerid);
    DBMS_OUTPUT.PUT_LINE('Roster teamID: ' || spRecord.teamid);
    DBMS_OUTPUT.PUT_LINE('Roster isactive: ' || spRecord.isactive);
    DBMS_OUTPUT.PUT_LINE('Roster jersey number: ' || spRecord.jerseynumber);
    DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('------------------------------');
END; 
/

-- 2.	For each table in (Players, Teams, Rosters), create an additional Stored Procedure, 
--      called spTableNameSelectAll that outputs the contents of the table to the script window (using DBMS_OUTPUT) for the standard SELECT * FROM <tablename> statement.
CREATE OR REPLACE PROCEDURE spPlayersSelectAll(exitcode OUT NUMBER) AS
    CURSOR csPlayers IS
        SELECT *
        FROM players;
    pRpt csPlayers%ROWTYPE;
    found BOOLEAN := FALSE;
BEGIN   
    exitcode := 0;
    OPEN csPlayers;
    DBMS_OUTPUT.PUT_LINE(
        RPAD('PlayerID', 10) || 
        RPAD('Reg Number', 15) || 
        RPAD('Lastname', 20) || 
        RPAD('Firstname', 20) || 
        RPAD('Active', 6)
    );
        LOOP
            FETCH csPlayers INTO pRpt;
            EXIT WHEN csPlayers%NOTFOUND;
            found := TRUE;
            -- If the cursor is empty from the start, the loop is exited before found is set to TRUE, accurately reflecting that no rows were fetched.
            DBMS_OUTPUT.PUT_LINE(
                RPAD(pRpt.playerid, 10) || 
                RPAD(pRpt.regnumber, 15) || 
                RPAD(pRpt.lastname, 20) || 
                RPAD(pRpt.firstname, 20) || 
                RPAD(pRpt.isactive, 6)
            );
        END LOOP;
    CLOSE csPlayers;
    
    IF NOT found THEN
        exitcode := -5;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersSelectAll;
/
-- spPlayersSelectAll TEST:
DECLARE exitcode NUMBER;
BEGIN spPlayersSelectAll(exitcode);
END;
/
-- Q2 cont' spTeamsSelectAll:
CREATE OR REPLACE PROCEDURE spTeamsSelectAll(exitcode OUT NUMBER) AS
    CURSOR csTeams IS
        SELECT *
        FROM teams;
    tRpt csTeams%ROWTYPE;
    found BOOLEAN := FALSE;
BEGIN   
    exitcode := 0;
    OPEN csTeams;
    DBMS_OUTPUT.PUT_LINE(
        RPAD('TeamID', 8) || 
        RPAD('Team Name', 12) || 
        RPAD('Active', 8) || 
        RPAD('Jersey Colour', 16)
    );
        LOOP
            FETCH csTeams INTO tRpt;
            EXIT WHEN csTeams%NOTFOUND;
            found := TRUE;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(tRpt.teamid, 8) || 
                RPAD(tRpt.teamname, 12) || 
                RPAD(tRpt.isactive, 8) || 
                RPAD(tRpt.jerseycolour, 16)
            );
        END LOOP;
    CLOSE csTeams;
    
    IF NOT found THEN
        exitcode := -5;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsSelectAll;
/
-- spTeamsSelectAll TEST:
DECLARE exitcode NUMBER;
BEGIN spTeamsSelectAll(exitcode);
END;
/
-- Q2 cont' spRostersSelectAll:
CREATE OR REPLACE PROCEDURE spRostersSelectAll(exitcode OUT NUMBER) AS
    CURSOR csRosters IS
        SELECT *
        FROM rosters;
    rRpt csRosters%ROWTYPE;
    found BOOLEAN := FALSE;
BEGIN
    exitcode := 0;
    OPEN csRosters;
    DBMS_OUTPUT.PUT_LINE(
        RPAD('RosterID', 10)||
        RPAD('PlayerID', 10)||
        RPAD('TeamID', 8)||
        RPAD('Active', 8)||
        RPAD('Jersey No.', 10)
    );
        LOOP
            FETCH csRosters INTO rRpt;
            EXIT WHEN csRosters%NOTFOUND;
            found := TRUE;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rRpt.rosterid, 10)||
                RPAD(rRpt.playerid, 10)||
                RPAD(rRpt.teamid, 8)||
                RPAD(rRpt.isactive, 8)||
                RPAD(rRpt.jerseynumber, 10)
            );
        END LOOP;
    CLOSE csRosters;
    
    IF NOT found THEN
        exitcode := -5;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersSelectAll;
/
-- spRostersSelectAll TEST:
DECLARE exitcode NUMBER;
BEGIN spRostersSelectAll(exitcode);
END;
/

-- 3.  Repeat Step 2 but returning the table in the output of the SP.  
--     Use a non-saved procedure to show receiving the data and outputting it to the script window.  
--     NOTE: Some research will be required here as we did not cover this in class.
CREATE OR REPLACE PROCEDURE spPlayersSelectAll(
    csPlayers     OUT     SYS_REFCURSOR,
    exitcode      OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    OPEN csPlayers FOR
        SELECT * 
        FROM players;
EXCEPTION
   WHEN INVALID_CURSOR THEN 
        exitcode := -8;
    WHEN OTHERS THEN
        exitcode := -1;
END spPlayersSelectAll;
/

-- spPlayersSelectAll CALL:
DECLARE 
    exitcode     NUMBER;
    csPlayers   SYS_REFCURSOR;
    pRpt        players%ROWTYPE;
    found       BOOLEAN := FALSE;
BEGIN 
    spPlayersSelectAll(csPlayers, exitcode);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('PlayerID', 10) || 
        RPAD('Reg Number', 15) || 
        RPAD('Lastname', 20) || 
        RPAD('Firstname', 20) || 
        RPAD('Active', 6)
    );
    LOOP
        FETCH csPlayers INTO pRpt;
        EXIT WHEN csPlayers%NOTFOUND;
        found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(pRpt.playerid, 10) || 
            RPAD(pRpt.regnumber, 15) || 
            RPAD(pRpt.lastname, 20) || 
            RPAD(pRpt.firstname, 20) || 
            RPAD(pRpt.isactive, 6)
        );
    END LOOP;
    CLOSE csPlayers;

    IF NOT found THEN
        exitcode := -5;
        DBMS_OUTPUT.PUT_LINE('No Data Found. Exit code: ' || exitcode);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
        DBMS_OUTPUT.PUT_LINE('Generic error occured. Exit code: ' || exitcode);
END;
/

-- Q3 spTeamsSelectAll:
CREATE OR REPLACE PROCEDURE spTeamsSelectAll(
    csTeams     OUT SYS_REFCURSOR,
    exitcode    OUT NUMBER
) AS
BEGIN
    exitcode := 0;
    OPEN csTeams FOR
        SELECT * 
        FROM teams;
EXCEPTION
   WHEN INVALID_CURSOR THEN 
        exitcode := -8;
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamsSelectAll;
/

-- spTeamsSelectAll CALL:
DECLARE 
    exitcode    NUMBER;
    csTeams     SYS_REFCURSOR;
    tRpt        teams%ROWTYPE;
    found       BOOLEAN := FALSE;
BEGIN 
    spTeamsSelectAll(csTeams, exitcode);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('TeamID', 8) || 
        RPAD('Team Name', 12) || 
        RPAD('Active', 8) || 
        RPAD('Jersey Colour', 16)
    );
    LOOP
        FETCH csTeams INTO tRpt;
        EXIT WHEN csTeams%NOTFOUND;
        found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(tRpt.teamid, 8) || 
            RPAD(tRpt.teamname, 12) || 
            RPAD(tRpt.isactive, 8) || 
            RPAD(tRpt.jerseycolour, 16)
        );
    END LOOP;
    CLOSE csTeams;

    IF NOT found THEN
        exitcode := -5;
        DBMS_OUTPUT.PUT_LINE('No Data Found. Exit code: ' || exitcode);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
        DBMS_OUTPUT.PUT_LINE('Generic error occured. Exit code: ' || exitcode);
END;
/

-- Q3 spRostersSelectAll:
CREATE OR REPLACE PROCEDURE spRostersSelectAll(
    csRosters   OUT     SYS_REFCURSOR,
    exitcode    OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    
    OPEN csRosters FOR
        SELECT * 
        FROM rosters;
EXCEPTION
   WHEN INVALID_CURSOR THEN 
        exitcode := -8;
    WHEN OTHERS THEN
        exitcode := -1;
END spRostersSelectAll;
/

-- spRostersSelectAll CALL:
DECLARE 
    exitcode NUMBER;
    csRosters SYS_REFCURSOR;
    rRpt rosters%ROWTYPE;
    found BOOLEAN := FALSE;
BEGIN 
    spRostersSelectAll(csRosters, exitcode);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('RosterID', 10)||
        RPAD('PlayerID', 10)||
        RPAD('TeamID', 8)||
        RPAD('Active', 8)||
        RPAD('Jersey No.', 10)
    );
    
    LOOP
        FETCH csRosters INTO rRpt;
        EXIT WHEN csRosters%NOTFOUND;
        found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(rRpt.rosterid), 10)||
            RPAD(TO_CHAR(rRpt.playerid), 10)||
            RPAD(TO_CHAR(rRpt.teamid), 8)||
            RPAD(TO_CHAR(rRpt.isactive), 8)||
            RPAD(TO_CHAR(rRpt.jerseynumber), 10)
        );
    END LOOP;
    CLOSE csRosters;
    
    IF NOT found THEN
        exitcode := -5;
        DBMS_OUTPUT.PUT_LINE('No Data Found. Exit code: ' || exitcode);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
        DBMS_OUTPUT.PUT_LINE('Generic error occured. Exit code: ' || exitcode);
END;
/


-- 4. Create a view which stores the �players on teams� information, 
--    called vwPlayerRosters which includes all fields from players, rosters, and teams in a single output table.  
--    You only need to include records that have exact matches.
CREATE OR REPLACE VIEW vwPlayerRosters AS
SELECT 
    p.playerid      AS playerID,
    p.regNumber     AS pRegNumber,
    p.firstName     AS pFirstName,
    p.lastName      AS pLastName,
    p.isActive      AS pIsActive,
    r.playerid      AS rPlayerID,
    r.rosterid      AS rosterID,
    r.teamid        AS rTeamID,
    r.isActive      AS rosterIsActive,
    t.teamname      AS teamName,
    t.isActive      AS tIsActive,
    t.jerseycolour  AS tJerseycolour
FROM players p
    INNER JOIN rosters r ON p.playerid = r.playerid AND r.isActive = 1
    INNER JOIN teams t ON r.teamid = t.teamid;
-- TEST:
SELECT * FROM vwPlayerRosters;


-- 5. Using the vwPlayerRosters view, create an SP, named spTeamRosterByID, that outputs, the team rosters, with names, 
--    for a team given a specific input parameter of teamID
/
CREATE OR REPLACE PROCEDURE spTeamRosterByID(
    pTeamID     IN      NUMBER,
    cPlayer     OUT     SYS_REFCURSOR,
    exitcode    OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    OPEN cPlayer FOR
        SELECT 
            teamName, 
            rosterID, 
            pFirstName || ' ' || pLastName AS fullName
        FROM vwPlayerRosters
        WHERE rTeamID = pTeamID;

    -- error
    IF NOT cPlayer%ISOPEN THEN
        exitcode := -5;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamRosterByID;
/
-- Q5 EXECUTE
DECLARE
    teamID              NUMBER := 212;
    cTeamRoastPlayer    SYS_REFCURSOR;
    teamName            VARCHAR2(25); 
    rosterID            NUMBER;        
    fullName            VARCHAR2(50); 
    exitcode            NUMBER;
BEGIN
    spTeamRosterByID(teamID, cTeamRoastPlayer, exitcode);

    IF exitcode = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Fetching Data...');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Team Name | Roster ID | Full Name');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');

        LOOP
            FETCH cTeamRoastPlayer 
            INTO 
                teamName, 
                rosterID, 
                fullName;
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
        DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    END IF;
END;
/

/*
6.	Repeat task 4, by creating another similar stored procedure, named spTeamRosterByName, 
    that receives a string parameter and returns the team roster, 
    with names, for a team found through a search string.  
    The entered parameter may be any part of the name.
*/
CREATE OR REPLACE PROCEDURE spTeamRosterByName(
    tName       IN      teams.teamname%TYPE,
    cPlayer     OUT     SYS_REFCURSOR,
    exitcode    OUT     NUMBER
) AS
BEGIN
    exitcode := 0;
    OPEN cPlayer FOR
        SELECT 
            teamname, 
            rosterID, 
            pFirstName || ' ' || pLastName AS fullName
        FROM vwPlayerRosters
        WHERE TRIM(UPPER(teamname)) LIKE ('%'||TRIM(UPPER(tName))||'%'); 

    IF NOT cPlayer%ISOPEN THEN
        exitcode := -8;
    END IF;
EXCEPTION
   WHEN INVALID_CURSOR THEN 
        exitcode := -8;
    WHEN OTHERS THEN
        exitcode := -1;
END spTeamRosterByName;
/
-- Q6 EXECUTE:
DECLARE
    vTeamName           VARCHAR2(25);
    cTeamRoastPlayer    SYS_REFCURSOR;
    cTeamRoast          VARCHAR2(25);
    rosterID            NUMBER;
    fullName            VARCHAR2(50);
    exitcode            NUMBER;
BEGIN
    vTeamName := '&team_name'; --get team
    spTeamRosterByName(vTeamName, cTeamRoastPlayer, exitcode);
    
    IF exitcode = 0 THEN
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
        DBMS_OUTPUT.PUT_LINE('Exit code: ' || exitcode);
    END IF;
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
/
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
/
-- Q8 Execute
DECLARE
    team INT;
    res INT;
BEGIN
    team := 210; -- test data: 210(o/p: 18)
    res:= fncNumPlayersByTeamID(team);
    DBMS_OUTPUT.PUT_LINE('Number of Player in team # '|| team || ': ' || res);
END;
/

-- 9.	Create a view, called vwSchedule, 
--      that shows all games, but includes the written names for teams and locations, in addition to the PK/FK values.  
--      Do not worry about division here.
CREATE OR REPLACE VIEW vwSchedule AS
    SELECT
        g.gameid,
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
-- Q9 EXECUTE
SELECT * FROM vwSchedule;


-- 10.	Create a stored procedure, spSchedUpcomingGames, using DBMS_OUTPUT, 
--      that displays the games to be played in the next n days, 
--      where n is an input parameter.  Make sure your code will work on any day of the year.
/
CREATE OR REPLACE PROCEDURE spSchedUpcomingGames (nextGameDay INT, exitcode OUT NUMBER) AS  -- games.gamedatetime%TYPE
    found BOOLEAN := FALSE;
    e_negativeDay EXCEPTION;
BEGIN
    exitcode := 0;
    IF nextGameDay < 0 THEN
        RAISE e_negativeDay;
    END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Display matches in the next ' || nextGameDay || ' days' );
    FOR r IN(
        SELECT * 
        FROM vwSchedule s
        WHERE s.gameDateTime BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + nextGameDay 
            AND s.isplayed = 0
    )LOOP
        found := TRUE; -- If the query returns no records, the loop body will not execute, and found will remain FALSE.
        DBMS_OUTPUT.PUT_LINE(RPAD('Game ID',16) || LPAD(': ', 2) || r.gameid);
        DBMS_OUTPUT.PUT_LINE(RPAD('Game Date-time',16) || LPAD(': ', 2) || to_char(r.gamedatetime, 'DD Month, YYYY'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Home Team',16) || LPAD(': ', 2) || r.HomeTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Visit Team',16) || LPAD(': ', 2) || r.VisitTeamName);
        DBMS_OUTPUT.PUT_LINE(RPAD('Location',16) || LPAD(': ', 2) || r.locationname);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
        
    IF NOT found THEN 
         exitcode := -5;
    END IF;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
EXCEPTION 
    WHEN e_negativeDay THEN
        exitcode := -7;
    WHEN OTHERS THEN
        exitcode := -1;
END spSchedUpcomingGames;
/
-- Q10 EXECUTE
-- TEST: 
DECLARE exitcode INT;
BEGIN 
    DBMS_OUTPUT.PUT_LINE('*** TEST 1 ***');
    spSchedUpcomingGames(30, exitcode); -- DEFAULT
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('*** TEST 2 ***');
    spSchedUpcomingGames(-1,exitcode); -- USER INPUT NEGATIVE DAYS
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('*** TEST 3 ***');
    spSchedUpcomingGames(0,exitcode); -- USER INPUT 0
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
END;
/
/*
11.	Create a stored procedure, spSchedPastGames, 
    using DBMS_OUTPUT, that displays the games that have been played in the past n days, 
    where n is an input parameter.  Make sure your code will work on any day of the year.
*/
CREATE OR REPLACE PROCEDURE spSchedPastGames(
    n           IN      NUMBER,
    exitcode    OUT     NUMBER
)AS
    matchCt                NUMBER   := 0;
    e_negativeInput        EXCEPTION;
    CURSOR data_cur IS 
        SELECT * 
        FROM vwSchedule s
        WHERE s.gameDateTime BETWEEN TRUNC(SYSDATE) - n AND TRUNC(SYSDATE)
            AND s.isplayed = 1;
    data_rec vwSchedule%ROWTYPE;
BEGIN
    exitcode := 0;
    IF n < 0 THEN
        RAISE e_negativeInput;
    END IF;

    OPEN data_cur;
        LOOP
            FETCH data_cur INTO data_rec;
            EXIT WHEN data_cur%NOTFOUND;
            matchCt := matchCt + 1;
            DBMS_OUTPUT.PUT_LINE(RPAD('Game ID',16) || LPAD(': ', 2) || data_rec.gameid);
            DBMS_OUTPUT.PUT_LINE(RPAD('Game Date-time',16) || LPAD(': ', 2) || to_char(data_rec.gamedatetime, 'DD Month, YYYY'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Home Team',16) || LPAD(': ', 2) || data_rec.HomeTeamName);
            DBMS_OUTPUT.PUT_LINE(RPAD('Visit Team',16) || LPAD(': ', 2) || data_rec.VisitTeamName);
            DBMS_OUTPUT.PUT_LINE(RPAD('Location',16) || LPAD(': ', 2) || data_rec.locationname);
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
    CLOSE data_cur;
    IF matchCt = 0 THEN
        exitcode := -5;
    END IF;
EXCEPTION
    WHEN e_negativeInput THEN 
        exitcode := -7;
    WHEN TOO_MANY_ROWS THEN 
        exitcode := -6;
    WHEN OTHERS THEN 
        exitcode := -1;
END;
/
-- Q11 TEST: DEFAULT
DECLARE exitcode INT;
BEGIN 
    spSchedPastGames(90, exitcode);
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
END;
/
-- Q11 TEST: USER INPUT NEGATIVE DAYS
DECLARE exitcode INT;
BEGIN 
    spSchedPastGames(-3,exitcode); -- INVALID INPUT: -7
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
END;
/
-- Q11 TEST: USER INPUT 0
DECLARE exitcode INT;
BEGIN 
    spSchedPastGames(0,exitcode); -- NO_DATA_FOUND: -5
    DBMS_OUTPUT.PUT_LINE('Exitcode: ' || exitcode);
END;
/

/*
12.	Using the Standings calculation demo code provided earlier in the semester, create a Stored Procedure, named spRunStandings, 
    that replaces a temporary static table, named tempStandings, with the output of the SELECT code provided. 
*/
CREATE TABLE tempStandings AS (
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
    GROUP BY TheTeamID)
    ORDER BY 
        Pts DESC, 
        W DESC, 
        GD Desc;
-- DROP TABLE tempStandings;
 SELECT * FROM tempStandings;

-- Q12 cont - spRunStandings:
/
CREATE OR REPLACE PROCEDURE spRunStandings AS
    CURSOR csStandings IS 
            SELECT *
            FROM tempStandings;
   sRpt csStandings%ROWTYPE;
   found BOOLEAN := FALSE;
BEGIN
--    exitcode := 0;
    OPEN csStandings;
    DBMS_OUTPUT.PUT_LINE(
        RPAD('TeamID', 8)||
        RPAD('Teamname', 10)||
        RPAD('GP', 4)||
        RPAD('W',4)||
        RPAD('L',4)||
        RPAD('T',4)||
        RPAD('PTS',4)||
        RPAD('GF',4) ||
        RPAD('GA',4) ||
        RPAD('GD',4) 
    );
        LOOP 
            FETCH csStandings INTO sRpt;
            EXIT WHEN csStandings%NOTFOUND;
            found := TRUE;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(sRpt.theteamid, 8)||
                RPAD(sRpt.teamname, 10)||
                RPAD(sRpt.gp, 4)||
                RPAD(sRpt.w,4)||
                RPAD(sRpt.l,4)||
                RPAD(sRpt.t,4)||
                RPAD(sRpt.pts,4)||
                RPAD(sRpt.gf,4) ||
                RPAD(sRpt.ga,4) ||
                RPAD(sRpt.gd,4) 
            );
        END LOOP;
    CLOSE csStandings;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END spRunStandings;
/
-- Q12 TEST:
DECLARE exitcode NUMBER;
BEGIN spRunStandings;
END;
/

/*
13.	Following up with Step 12, create a Trigger in the system to automate the execution of the spRunStandings SP when any row in the games table is updated.  
    Essentially meaning that software can run SELECT * FROM tempStandings; and always have up to date standings.
*/
CREATE OR REPLACE TRIGGER trgUpdateTempStandings
    AFTER INSERT OR UPDATE OF homescore, isplayed, visitscore ON games
BEGIN
    DELETE FROM tempStandings;
    INSERT INTO tempStandings (
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
        GROUP BY TheTeamID)
        ORDER BY 
            Pts DESC, 
            W DESC, 
            GD Desc;
    spRunStandings;
END trgUpdateTempStandings;
/
-- TEST:
UPDATE games SET homescore = 96 WHERE gameid = 1;
-- TEST Output: 
-- TeamID 218 From GA 21 -> GF 111, GD 3 -> GD 93
-- TeamID 212 From GA 28 -> GA 118, GD -10 -> GD -100
ROLLBACK;

/*
14.	Each group must be creative and come up with an object (SP, UDF, or potentially trigger), of your own choosing, 
that will be built in the database to help support the same ideals of the above objects.
*/
-- * The procedure spMVPperteam displays a list of top players in each team
--      + Teams that have no goals scored are not included
--      + Useful for when a club bids for a player transfer
/
CREATE OR REPLACE PROCEDURE spMVPperteam (exitcode OUT NUMBER) AS
    CURSOR mvp_cur IS 
        SELECT 
            p.playerid, 
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
                FROM players p 
                    JOIN goalscorers g ON p.playerID = g.playerid
                GROUP BY 
                    p.playerid, 
                    lastname,
                    firstname, 
                    teamid
            )
            GROUP BY teamid
        )
        GROUP BY 
            p.playerid, 
            lastname,
            firstname, 
            g.teamid, 
            teamname
        ORDER BY 
            goalct DESC, 
            g.teamID DESC;

    mRpt mvp_cur%ROWTYPE;
    found BOOLEAN := FALSE;
BEGIN
    exitcode := 0;
    DBMS_OUTPUT.PUT_LINE('List of top players: ' );
    OPEN mvp_cur;
        LOOP
            FETCH mvp_cur INTO mRpt;
            EXIT WHEN mvp_cur%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('Player ID: ' || mRpt.playerid || ' ' || mRpt.lastname || ', '|| mRpt.firstname );
            DBMS_OUTPUT.PUT_LINE('Team ID: ' || mRpt.teamid|| ' ' || mRpt.teamname );
            DBMS_OUTPUT.PUT_LINE('Goals made: ' || mRpt.goalCt);
            DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    CLOSE mvp_cur;
EXCEPTION
   WHEN INVALID_CURSOR THEN 
        exitcode := -8;
	WHEN TOO_MANY_ROWS THEN 
        exitcode := -6;
    WHEN NO_DATA_FOUND THEN 
        exitcode := -5;
    WHEN OTHERS THEN 
        exitcode := -1;
END;
/
-- TEST:
DECLARE exitcode NUMBER;
BEGIN spMVPperteam(exitcode);
END;
/