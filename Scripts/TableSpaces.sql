-- Tablespace Configuration Script for Customer Loyalty Points & Rewards Automation System

-- Create tablespace for data
CREATE TABLESPACE loyalty_data
DATAFILE 'loyalty_data.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE 500M;

-- Create tablespace for indexes
CREATE TABLESPACE loyalty_index
DATAFILE 'loyalty_index.dbf'
SIZE 50M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 200M;

-- Create temporary tablespace
CREATE TEMPORARY TABLESPACE loyalty_temp
TEMPFILE 'loyalty_temp.dbf'
SIZE 20M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 100M;

-- Display tablespace information
SELECT tablespace_name, status, contents FROM dba_tablespaces WHERE tablespace_name LIKE '%LOYALTY%';
