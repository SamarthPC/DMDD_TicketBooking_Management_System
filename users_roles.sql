select user from dual;



---- Execute this script as Admin ----- 


------------ Create roles -----------

------------------------------------MovieAdmin----------------------------------------------------
Declare 
ncount number;
BEGIN
 select count(1) into ncount from all_users where username = 'MOVIEADMIN';
 if (ncount>0) THEN
  dbms_output.put_line('USER MOVIEADMIN ALREADY EXISTS');
 else EXECUTE IMMEDIATE 'create user movieAdmin identified by GCQiRbpWBk1q';
   EXECUTE IMMEDIATE 'GRANT CONNECT,RESOURCE to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO movieAdmin';
   EXECUTE IMMEDIATE 'Grant create view, create sequence,create trigger, create procedure to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT CREATE user to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT DROP user to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT DROP user to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT CREATE role to movieAdmin';
   EXECUTE IMMEDIATE 'GRANT CREATE SESSION,connect TO movieAdmin';
   EXECUTE IMMEDIATE 'GRANT SELECT ON DBA_ROLES TO TO movieAdmin';
   COMMIT;
   end if;
end;   
/
------------------------------------roleUser----------------------------------------------------
DECLARE
  ncount NUMBER;
BEGIN
  SELECT COUNT(1) INTO ncount FROM DBA_ROLES WHERE role = 'CUSTOMER_USER';
  IF (ncount > 0) THEN
    DBMS_OUTPUT.PUT_LINE('ROLE CUSTOMER_USER ALREADY EXISTS');
  ELSE
    EXECUTE IMMEDIATE 'CREATE ROLE CUSTOMER_USER';
    FOR x IN (SELECT * FROM user_tables WHERE table_name='CUSTOMER')
    LOOP
      EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON ' || x.table_name || ' TO CUSTOMER_USER';
    END LOOP;
    COMMIT;
    FOR x IN (SELECT * FROM user_tables WHERE table_name IN ('MOVIE','THEATRE','THEATRE_LOCATION','SCHEDULED_SHOW','PAYMENT','MOVIE_SCREEN','TICKET'))
    LOOP
      EXECUTE IMMEDIATE 'GRANT SELECT ON ' || x.table_name || ' TO CUSTOMER_USER';
    END LOOP;
    COMMIT;
  END IF;
END;
/
------------------------------------roleGuest----------------------------------------------------
Declare
ncount number;
BEGIN
 select count(1) into ncount from DBA_ROLES where role = 'GUEST';
 if (ncount>0) THEN
  dbms_output.put_line('ROLE GUEST ALREADY EXISTS');
 else EXECUTE IMMEDIATE 'CREATE ROLE GUEST';
   FOR x IN (SELECT * FROM user_tables where table_name in ('CUSTOMER'))
   LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT,UPDATE ON ' || x.table_name || ' TO GUEST';
   END LOOP;
   COMMIT;
   FOR x IN (SELECT * FROM user_tables where table_name in ('MOVIE','THEATRE','SCHEDULED_SHOW','THEATRE_LOCATION','MOVIE_SCREEN'))
   LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON ' || x.table_name || ' TO GUEST';
   END LOOP;
   COMMIT;
   END IF;
END;
/ 

