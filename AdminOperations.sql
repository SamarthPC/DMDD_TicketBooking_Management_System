BEGIN
    user_signup('testnew12', 'NewUser123876', 'John Doe', '1234567890', 'johndoe@example.com', TO_DATE('1990-01-01', 'YYYY-MM-DD'));
END;



--Testing with a new customer:
EXEC insert_customer('newuser', 'password123', 'John Doe', '1234567890', 'john.doe@example.com', TO_DATE('1990-01-01', 'YYYY-MM-DD'));

--Testing with an existing customer and updated information:
EXEC insert_customer('newuser', 'newpassword', 'Jane Doe', '9876543210', 'jane.doe@example.com', TO_DATE('1995-01-01', 'YYYY-MM-DD'));

--Testing with an existing customer and invalid phone number:
EXEC insert_customer('existinguser', 'newpassword', 'Jane Doe', '123', 'jane.doe@example.com', TO_DATE('1995-01-01', 'YYYY-MM-DD'));

-- Testing with an existing customer and invalid email address:
EXEC insert_customer('existinguser', 'newpassword', 'Jane Doe', '9876543210', 'jane.doe@example', TO_DATE('1995-01-01', 'YYYY-MM-DD'));


--drop user testnew12;