
CREATE OR REPLACE PROCEDURE insert_customer(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_name IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_email IN VARCHAR2,
    p_dob IN DATE
) AS
    v_count NUMBER;
BEGIN
    -- check if the username already exists
    SELECT COUNT(*) INTO v_count FROM customer WHERE customer_username = p_username;
    
    IF v_count > 0 THEN
        -- username already exists, update phone_number, name, and email
        UPDATE customer SET 
            customer_password = p_password,
            customer_name = p_name,
            customer_phone_number = CASE WHEN LENGTH(p_phone_number) = 10 THEN p_phone_number ELSE customer_phone_number END,
            customer_email = CASE WHEN REGEXP_LIKE(p_email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN p_email ELSE customer_email END
        WHERE customer_username = p_username;
		
    ELSE
        -- insert new customer record
        INSERT INTO customer (customer_username, customer_password, customer_name, customer_phone_number, customer_email, customer_dob)
        VALUES (p_username, p_password, p_name, p_phone_number, p_email, p_dob);
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid value entered');
    WHEN OTHERS THEN
        IF SQLCODE = -2290 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid phone number or email');
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END insert_customer;
/




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
            dbms_output.put_line('User  already exists');
        ELSE
            EXECUTE IMMEDIATE 'create user ' ||  UPPER(p_username) || ' identified by '|| p_password;
            EXECUTE IMMEDIATE 'grant create session, connect to ' ||  UPPER(p_username);
            EXECUTE IMMEDIATE 'grant CUSTOMER_USER to ' || UPPER(p_username);
            EXECUTE IMMEDIATE 'grant read any table to ' || UPPER(p_username);
            EXECUTE IMMEDIATE 'GRANT EXECUTE ON movie_booking_pkg TO ' ||  UPPER(p_username);

            EXECUTE IMMEDIATE  'GRANT EXECUTE on Customer_Actions  TO ' || UPPER(p_username);

            dbms_output.put_line('User custuser created successfully');
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            dbms_output.put_line(SQLERRM);
            ROLLBACK;
            RAISE;
    END;

    BEGIN
    insert_customer(
        p_username,
        p_password,
        p_name,
        p_phone_number,
        p_email,
        p_dob
    );
    END;
    
    COMMIT;
END user_signup;

/




