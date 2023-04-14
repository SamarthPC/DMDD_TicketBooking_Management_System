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
   EXECUTE IMMEDIATE 'GRANT CREATE role to MOVIEADMIN';
   EXECUTE IMMEDIATE 'GRANT CREATE SESSION,connect TO MOVIEADMIN WITH ADMIN OPTION';
   EXECUTE IMMEDIATE 'GRANT SELECT ON DBA_ROLES TO MOVIEADMIN';
   EXECUTE IMMEDIATE 'GRANT GRANT ANY OBJECT PRIVILEGE TO MOVIEADMIN';

   COMMIT;
   end if;
end;   
/