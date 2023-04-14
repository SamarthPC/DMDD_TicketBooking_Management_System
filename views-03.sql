------------- User to check tickets -------

CREATE or REPLACE VIEW tickets_history AS
SELECT t.ticket_id,t.customer_id, m.movie_name, ss.start_date_time, ss.end_date_time, sc.screen_id, t.seat_list, p.payment_amount, p.payment_status, LISTAGG(a.addon_name, ', ') WITHIN GROUP (ORDER BY a.addon_id) AS addon_names,
       SUM(a.price * ca.addon_quantity) AS addon_total_price
FROM ticket t
INNER JOIN scheduled_show ss ON t.show_id = ss.show_id
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id
INNER JOIN payment p ON t.payment_id = p.payment_id
LEFT JOIN customer_addon ca ON t.ticket_id = ca.ticket_id
LEFT JOIN addon a ON ca.addon_id = a.addon_id
GROUP BY t.ticket_id,t.customer_id, m.movie_name, ss.start_date_time, ss.end_date_time, sc.screen_id, t.seat_list, p.payment_amount, p.payment_status;




select *from movieadmin.tickets_history;
------------ 





-------------- Creation of views -------------

--- Movie Schedule -----

CREATE or REPLACE VIEW movie_schedule AS
SELECT m.movie_name,m.Genre,m.movie_language,ss.show_id, ss.start_date_time, ss.end_date_time, sc.screen_id
FROM scheduled_show ss
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id;

SELECT * FROM movieadmin.movie_schedule;
-- Theatre locations ---

CREATE or REPLACE VIEW theatre_locations_view AS
SELECT t.theatre_id, t.theatre_name, l.theatre_city, l.theatre_state
FROM theatre t
INNER JOIN theatre_location l ON t.location_id = l.location_id;
/

SELECT * FROM movieadmin.theatre_locations_view where theatre_city = 'Albany';



---- Seats available for all show --------

CREATE or replace VIEW seats_available AS
SELECT m.movie_name,ss.start_date_time, sc.screen_id,s.seat_number,s.seat_status
FROM seat s
INNER JOIN scheduled_show ss ON s.screen_id = ss.screen_id
INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
INNER JOIN movie m ON ss.movie_id = m.movie_id
where s.seat_status = 'Y';
/


select * from movieadmin.seats_available;



---------------------------------------------



