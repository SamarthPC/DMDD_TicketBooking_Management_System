set serveroutput on;
CREATE OR replace PROCEDURE Customer_Actions
is
BEGIN

dbms_output.Put_line('HELLO '
                         ||Sys_context('USERENV', 'SESSION_USER')
                         ||' !');


dbms_output.Put_line('OPERATIONS ALLOWED for the user to buy tickets in the platform:');    

dbms_output.Put_line('');

dbms_output.Put_line('-------------USER RELATED ACTIONS-------------');

dbms_output.Put_line('1. select theatre based on locations');

dbms_output.Put_line('2. select movie and show time based on the selected theatre');

dbms_output.Put_line('3. After selecting the movie and show it displays the seats available');

dbms_output.Put_line('4. To checkout : select seats ');

dbms_output.Put_line('5. To view addons : select *from addon ');


dbms_output.Put_line('6. To Add addons : provide list of addons comma separated and respective quantities ');

dbms_output.Put_line('7. Give the card details for the payment to be successful and buy a ticket');

dbms_output.Put_line('5. User can view all the tickets he purchased in the application');

dbms_output.Put_line('');
commit;
EXCEPTION
  WHEN OTHERS THEN
             dbms_output.Put_line(SQLERRM);

             dbms_output.Put_line(dbms_utility.format_error_backtrace);

             ROLLBACK;
END Customer_Actions;
/
