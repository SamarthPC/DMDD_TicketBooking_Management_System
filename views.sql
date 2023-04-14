

-------------- Creation of views -------------

--- Movie Schedule -----

CREATE VIEW movie_schedule AS
SELECT m.movie_name,m.Genre,m.movie_language,ss.show_id, ss.start_date_time, ss.end_date_time, sc.screen_id
FROM scheduled_show ss
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id;

SELECT * FROM movie_schedule;
-- Theatre locations ---

CREATE VIEW theatre_locations_view AS
SELECT t.theatre_id, t.theatre_name, l.theatre_city, l.theatre_state
FROM theatre t
INNER JOIN theatre_location l ON t.location_id = l.location_id;
/

SELECT * FROM theatre_locations_view where theatre_city = 'Albany';

---- Tickets_history ---- 

CREATE VIEW tickets_history AS
SELECT t.ticket_id, t.customer_id,m.movie_name, ss.start_date_time, ss.end_date_time, sc.screen_id, t.seat_list, p.payment_amount, p.payment_status
FROM ticket t
INNER JOIN scheduled_show ss ON t.show_id = ss.show_id
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id
INNER JOIN payment p ON t.payment_id = p.payment_id;
/


select *from MOVIEADMIN.tickets_history  ;


---- Seats available for the show --------
CREATE VIEW seats_available AS
SELECT m.movie_name,ss.start_date_time, sc.screen_id,s.seat_number, s.seat_row, s.seat_status
FROM seat s
INNER JOIN scheduled_show ss ON s.screen_id = ss.screen_id
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id
where s.seat_status = 'Y';
/

select * from seat;



