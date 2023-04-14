select user from dual;

---movie table procedures----
CREATE OR REPLACE PROCEDURE add_movie (
    p_movie_name IN VARCHAR2,
    p_movie_description IN VARCHAR2,
    p_movie_duration IN NUMBER,
    p_movie_language IN VARCHAR2,
    p_genre IN VARCHAR2,
    p_parental_rating IN VARCHAR2
)
AS BEGIN
INSERT INTO movie (
        movie_name, 
        movie_description, 
        movie_duration, 
        movie_language, 
        genre, 
        parental_rating
    )
    VALUES (
        p_movie_name, 
        p_movie_description, 
        p_movie_duration, 
        p_movie_language, 
        p_genre, 
        p_parental_rating
    );
    COMMIT;
END;
/


select * from movie;

BEGIN
    add_movie(
        'The Godfather2', 
        'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.', 
        175, 
        'English', 
        'Crime Drama', 
        'R'
    );
END;
/

BEGIN
    add_movie(
        'Gods must be crazy', 
        'Unknown', 
        120, 
        'English', 
        'Drama', 
        'R'
    );
END;
/

CREATE OR REPLACE PROCEDURE update_movie(
    p_movie_id IN movie.movie_id%TYPE,
    p_movie_name IN movie.movie_name%TYPE,
    p_movie_description IN movie.movie_description%TYPE,
    p_movie_duration IN movie.movie_duration%TYPE,
    p_movie_language IN movie.movie_language%TYPE,
    p_genre IN movie.genre%TYPE,
    p_parental_rating IN movie.parental_rating%TYPE
)
IS
BEGIN
    UPDATE movie
    SET movie_name = p_movie_name,
        movie_description = p_movie_description,
        movie_duration = p_movie_duration,
        movie_language = p_movie_language,
        genre = p_genre,
        parental_rating = p_parental_rating
    WHERE movie_id = p_movie_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Movie updated successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Movie not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating movie: ' || SQLERRM);
END;
/

BEGIN
  update_movie(19, 'New Movie Title', 'New Movie Description', 120, 'English', 'Action', 'PG-13');
END;
/

CREATE OR REPLACE PROCEDURE delete_movie (
    p_movie_id IN movie.movie_id%TYPE
) AS
BEGIN
    DELETE FROM movie WHERE movie_id = p_movie_id;
    COMMIT;
END;
/

BEGIN
    delete_movie(19);
END;
/



select * from movie;

--------theatre table updates-----

CREATE OR REPLACE PROCEDURE create_theatre (
    theatre_name IN VARCHAR2,
    location_id IN NUMBER
)
IS
BEGIN
    INSERT INTO theatre (theatre_name, location_id)
    VALUES (theatre_name, location_id);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Theatre created successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error while creating theatre: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Procedure to update a theatre record
CREATE OR REPLACE PROCEDURE update_theatre (
    p_theatre_id IN theatre.theatre_id%TYPE,
    p_theatre_name IN theatre.theatre_name%TYPE,
    p_location_id IN theatre.location_id%TYPE
) IS
BEGIN
    UPDATE theatre
    SET theatre_name = p_theatre_name,
        location_id = p_location_id
    WHERE theatre_id = p_theatre_id;
    
    COMMIT;
END;
/


-- Procedure to delete a theatre record
CREATE OR REPLACE PROCEDURE delete_theatre (
    p_theatre_id IN theatre.theatre_id%TYPE
) IS
BEGIN
    DELETE FROM theatre
    WHERE theatre_id = p_theatre_id;
    
    COMMIT;
END;
/


select * from theatre;
select * from theatre_location;

BEGIN
    create_theatre('Orion Mall', 1);
END;
/

BEGIN
    update_theatre(17, 'Orion Mall', 2);
END;
/

BEGIN
    delete_theatre(17);
END;
/

------scheduled show---------

CREATE OR REPLACE PROCEDURE create_scheduled_show (
    p_screen_id IN scheduled_show.screen_id%TYPE,
    p_movie_id IN scheduled_show.movie_id%TYPE,
    p_start_date_time IN scheduled_show.start_date_time%TYPE,
    p_end_date_time IN scheduled_show.end_date_time%TYPE
) AS
BEGIN
    INSERT INTO scheduled_show (screen_id, movie_id, start_date_time, end_date_time)
    VALUES (p_screen_id, p_movie_id, p_start_date_time, p_end_date_time);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE get_scheduled_show (
    p_show_id IN scheduled_show.show_id%TYPE,
    p_screen_id OUT scheduled_show.screen_id%TYPE,
    p_movie_id OUT scheduled_show.movie_id%TYPE,
    p_start_date_time OUT scheduled_show.start_date_time%TYPE,
    p_end_date_time OUT scheduled_show.end_date_time%TYPE
) AS
BEGIN
    SELECT screen_id, movie_id, start_date_time, end_date_time
    INTO p_screen_id, p_movie_id, p_start_date_time, p_end_date_time
    FROM scheduled_show
    WHERE show_id = p_show_id;
END;
/

CREATE OR REPLACE PROCEDURE update_scheduled_show (
    p_show_id IN scheduled_show.show_id%TYPE,
    p_screen_id IN scheduled_show.screen_id%TYPE,
    p_movie_id IN scheduled_show.movie_id%TYPE,
    p_start_date_time IN scheduled_show.start_date_time%TYPE,
    p_end_date_time IN scheduled_show.end_date_time%TYPE
) AS
BEGIN
    UPDATE scheduled_show
    SET screen_id = p_screen_id,
        movie_id = p_movie_id,
        start_date_time = p_start_date_time,
        end_date_time = p_end_date_time
    WHERE show_id = p_show_id;
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE delete_scheduled_show (
    p_show_id IN scheduled_show.show_id%TYPE
)
IS
BEGIN
    DELETE FROM ticket
    WHERE show_id = p_show_id;

    DELETE FROM scheduled_show
    WHERE show_id = p_show_id;
END;
/


select * from scheduled_show;

BEGIN
    create_scheduled_show(1, 2, '2023-05-01 18:30:00', '2023-05-01 21:00:00');
END;
/
BEGIN
    update_scheduled_show(1, 2, 3, '2023-05-01 19:00:00', '2023-05-01 22:00:00');
END;
/
BEGIN
    delete_scheduled_show(1);
END;
/





