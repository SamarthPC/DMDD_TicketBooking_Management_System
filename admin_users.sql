CREATE OR REPLACE PROCEDURE user_signup(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_dob IN DATE
)
IS
BEGIN
    DECLARE 
        nCount number;
      
    
    BEGIN
    
        SELECT count(*) INTO nCount FROM ALL_USERS WHERE USERNAME = UPPER(p_username);
        IF nCount > 0 THEN 
            dbms_output.put_line('User custuser already exists');
        ELSE
            EXECUTE IMMEDIATE 'create user ' ||  UPPER(p_username) || ' identified by '|| p_password;
            EXECUTE IMMEDIATE 'grant create session, connect to ' ||  UPPER(p_username);
            EXECUTE IMMEDIATE 'grant CUSTOMER_USER to ' || UPPER(p_username);
             EXECUTE IMMEDIATE 'grant read any table to ' || UPPER(p_username);
            dbms_output.put_line('User custuser created successfully');
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            dbms_output.put_line(SQLERRM);
            ROLLBACK;
            RAISE;
    END;
/*
    INSERT INTO customer (
        customer_username,
        customer_password,
        customer_name,
        customer_phone_number,
        customer_email,
        customer_dob
    ) VALUES (
        p_username,
        p_password,
        p_name,
        p_phone_number,
        p_email,
        p_dob
    );*/
    
    COMMIT;
END user_signup;

/


GRANT CREATE SESSION TO TEST;

select *from all_users where username = 'TEST'
SELECT * FROM dba_roles where role = 'CUSTOMER_USER';

SELECT * FROM SESSION_PRIVS;

grant create session, connect to ' ||  p_username







drop role CUSTOMER_USER;

SELECT count(*)  FROM ALL_USERS WHERE USERNAME = 'TESTNEW';


BEGIN
    user_signup('testnew12', 'NewUser123876', 'John Doe', '1234567890', 'johndoe@example.com', TO_DATE('1990-01-01', 'YYYY-MM-DD'));
END;
