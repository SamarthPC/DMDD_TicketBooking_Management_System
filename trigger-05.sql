CREATE OR REPLACE TRIGGER scheduled_show_insert_trigger
AFTER INSERT ON scheduled_show
FOR EACH ROW
DECLARE
  v_message VARCHAR2(100);
  moviename varchar2(100);
BEGIN
  select movie_name into moviename from movie where movie_id = :NEW.movie_id;
  v_message := 'New show scheduled - Movie: ' || moviename || ', Start Date/Time: ' || :NEW.start_date_time;
  DBMS_OUTPUT.PUT_LINE(v_message);
END;
/



