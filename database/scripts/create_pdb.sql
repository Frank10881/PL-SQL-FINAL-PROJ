-- Pluggable Database Creation Script for Customer Loyalty Points & Rewards Automation System

-- Connect as SYSDBA
CONN sys AS SYSDBA;

-- Create the Pluggable Database (PDB)
CREATE PLUGGABLE DATABASE mon_26652_frank_loyalty_db
ADMIN USER loyalty_owner IDENTIFIED BY loyalty123
ROLES=(DBA)
FILE_NAME_CONVERT=(
  '/opt/oracle/oradata/ORCL/pdbseed/system01.dbf', 
  '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/system01.dbf',
  '/opt/oracle/oradata/ORCL/pdbseed/sysaux01.dbf', 
  '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/sysaux01.dbf',
  '/opt/oracle/oradata/ORCL/pdbseed/temp01.dbf', 
  '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/temp01.dbf'
)
STORAGE (
  MAXSIZE 1G
  MAX_SHARED_TEMP_SIZE 100M
);

-- Open the newly created PDB
ALTER PLUGGABLE DATABASE mon_26652_frank_loyalty_db OPEN READ WRITE;

-- Save the state of the PDB so it starts automatically
ALTER PLUGGABLE DATABASE mon_26652_frank_loyalty_db SAVE STATE;

-- Connect to the new PDB
ALTER SESSION SET CONTAINER = mon_26652_frank_loyalty_db;

-- Create additional tablespaces in the PDB
CREATE TABLESPACE loyalty_data
DATAFILE '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/loyalty_data01.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE 500M;

CREATE TABLESPACE loyalty_index
DATAFILE '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/loyalty_index01.dbf'
SIZE 50M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 200M;

CREATE TEMPORARY TABLESPACE loyalty_temp
TEMPFILE '/opt/oracle/oradata/ORCL/mon_26652_frank_loyalty_db/loyalty_temp01.dbf'
SIZE 20M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 100M;

-- Enable archive logging for the PDB
ALTER SESSION SET CONTAINER = mon_26652_frank_loyalty_db;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- Verify the PDB creation
SELECT pdb_id, pdb_name, status FROM dba_pdbs WHERE pdb_name = 'MON_26652_FRANK_LOYALTY_DB';