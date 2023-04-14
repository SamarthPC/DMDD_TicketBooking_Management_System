CREATE OR REPLACE PACKAGE movie_booking_pkg AS
    v_customer_id_global NUMBER;
    v_checkout_price_global NUMBER;
    v_ticket_id_global NUMBER;
    v_theatre_id_global NUMBER;
    v_screen_id_global NUMBER;
    v_show_id_global NUMBER;
    v_movie_id_global NUMBER;
    v_location_id_global NUMBER;
    
    
    PROCEDURE login;
    
    
    PROCEDURE get_theater_names_by_location(
  p_location IN theatre_location.theatre_city%TYPE
);
    PROCEDURE get_movies_by_theater(
  p_theater_name IN theatre.theatre_name%TYPE
);
    PROCEDURE check_available_seats(
  p_movie_name IN movie.movie_name%TYPE,
  p_start_date_time IN scheduled_show.start_date_time%TYPE
);

    PROCEDURE checkout (

        p_seat_list IN VARCHAR2,
        p_total_price OUT NUMBER
    );
    PROCEDURE processpayment (
        p_name IN VARCHAR2,
        p_address IN VARCHAR2,
        p_card_number IN VARCHAR,
        p_payment_id OUT NUMBER
    );
    PROCEDURE AddAddOnsToCheckout(
        p_add_on_id IN VARCHAR2,
        p_quantity IN VARCHAR2,
        checkoutPrice out NUMBER
    );
PROCEDURE get_ticket_history;
END movie_booking_pkg;
/
  



CREATE OR REPLACE PACKAGE BODY movie_booking_pkg AS

   PROCEDURE login
  IS
    v_customer_id NUMBER;
    p_username varchar2(30);
  BEGIN
    SELECT sys_context('USERENV', 'SESSION_USER') INTO p_username FROM DUAL;
   
     DBMS_OUTPUT.PUT_LINE(p_username);
    SELECT customer_id INTO v_customer_id
    FROM customer
    WHERE customer_username = LOWER(p_username) ;
    
    movie_booking_pkg.v_customer_id_global := v_customer_id;
    DBMS_OUTPUT.PUT_LINE('\customer ID: ' || movie_booking_pkg.v_customer_id_global);
    
    DBMS_OUTPUT.PUT_LINE('Logged in successfully.');
    commit;
  END login;
   

   

  
------------------------------------------------
     PROCEDURE get_movies_by_theater(
  p_theater_name IN theatre.theatre_name%TYPE
)
IS
v_theatre_id NUMBER;
v_location_id NUMBER;
BEGIN
    v_location_id := movie_booking_pkg.v_location_id_global;
    DBMS_OUTPUT.PUT_LINE('Location ID : ' || movie_booking_pkg.v_location_id_global);
    select theatre_id into v_theatre_id from theatre where theatre_name = p_theater_name and theatre.location_id = v_location_id;
    IF v_theatre_id IS NULL THEN
   		 RAISE_APPLICATION_ERROR(-20001, 'Theater not found');
  	END IF;
    movie_booking_pkg.v_theatre_id_global := v_theatre_id;
    DBMS_OUTPUT.PUT_LINE('Theatre ID : ' || movie_booking_pkg.v_theatre_id_global);
  
  FOR r_show IN (
    SELECT s.start_date_time, m.movie_name, t.theatre_name ,t.theatre_id, s.screen_id, s.show_id
    FROM scheduled_show s
    JOIN movie m ON s.movie_id = m.movie_id
    JOIN movie_screen sc ON s.screen_id = sc.screen_id
    JOIN theatre t ON sc.theatre_id = t.theatre_id
    WHERE t.theatre_id = v_theatre_id 
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('Movie: ' || r_show.movie_name || ', Start Date/Time: ' || r_show.start_date_time);
    

  END LOOP; 
  COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No shows found for the given theater');
  ROLLBACK;

END get_movies_by_theater;
----------------------------------------------------------------
  PROCEDURE get_theater_names_by_location(
  p_location IN theatre_location.theatre_city%TYPE
)
IS
 

  CURSOR c_theater_names IS
    SELECT theatre.theatre_name, theatre.theatre_id , theatre_location.location_id
    FROM theatre
    INNER JOIN theatre_location ON theatre.location_id = theatre_location.location_id
    WHERE theatre_location.theatre_city = p_location;
    
    
    
BEGIN
  
  FOR r_theater_name IN c_theater_names LOOP
    DBMS_OUTPUT.PUT_LINE(' Theatre NAme: ' || r_theater_name.theatre_name);
    movie_booking_pkg.v_location_id_global := r_theater_name.location_id;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' Location ID: ' || movie_booking_pkg.v_location_id_global);

 IF movie_booking_pkg.v_location_id_global IS NULL THEN
   		 RAISE_APPLICATION_ERROR(-20001, 'Location not found');
  	END IF;
    

 COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No theaters found for the given location');
  WHEN OTHERS THEN
    ROLLBACK;
    

END get_theater_names_by_location;

----------------------------------------------------------------
  
     PROCEDURE check_available_seats(
  p_movie_name IN movie.movie_name%TYPE,
  p_start_date_time IN scheduled_show.start_date_time%TYPE
)
IS
  v_movie_id movie.movie_id%TYPE;
  v_show_id scheduled_show.show_id%TYPE;
  v_screen_id movie_screen.screen_id%TYPE;
  v_theatre_id number;


BEGIN

SELECT movie_id INTO v_movie_id FROM movie WHERE movie_name = p_movie_name;
    movie_booking_pkg.v_movie_id_global := v_movie_id;
 v_theatre_id := movie_booking_pkg.v_theatre_id_global;
 DBMS_OUTPUT.PUT_LINE(' Movie ID: ' || movie_booking_pkg.v_movie_id_global);
  DBMS_OUTPUT.PUT_LINE(' Theatre ID: ' || v_theatre_id);
  SELECT ms.screen_id, s.show_id INTO v_screen_id,v_show_id FROM scheduled_show s JOIN movie_screen ms on ms.screen_id = s.screen_id WHERE s.movie_id = v_movie_id and ms.theatre_id = v_theatre_id AND s.start_date_time = p_start_date_time;
  
  IF v_screen_id IS NULL OR v_show_id IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Show not found');
  END IF;

  movie_booking_pkg.v_screen_id_global := v_screen_id;
  movie_booking_pkg.v_show_id_global := v_show_id;

  FOR s IN (
      SELECT seat_number
      FROM seat
      WHERE screen_id = v_screen_id
        AND seat_status = 'Y'
    ) LOOP
  DBMS_OUTPUT.PUT_LINE(' Seat Number: ' || s.seat_number);
  END LOOP;

COMMIT;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No shows found for the given movie and start date/time');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLCODE || ' - ' || SQLERRM);
   ROLLBACK;
END check_available_seats;
----------------------------------------------------------------
  PROCEDURE checkout (

    p_seat_list IN VARCHAR2,
    p_total_price OUT NUMBER
)
AS
  v_seat_count NUMBER;
  v_seat_price NUMBER;
  v_total_price NUMBER := 0;
  p_customer_id NUMBER;
  p_ticket_id_seq NUMBER;
  p_movie_id  NUMBER;
    p_show_id  NUMBER;
    p_screen_id  NUMBER;
    status NUMBER;
BEGIN
  -- Get the price for each seat
  p_movie_id := v_movie_id_global;
  p_show_id := v_show_id_global;
  p_screen_id := v_screen_id_global;
  p_customer_id := movie_booking_pkg.v_customer_id_global;
  
  
  status := checkavailability(p_screen_id,p_seat_list);
  
  INSERT INTO ticket(customer_id, show_id, screen_id,seat_list)
  VALUES (p_customer_id, p_show_id,p_screen_id,p_seat_list)
  RETURNING ticket_id INTO p_ticket_id_seq;

IF p_ticket_id_seq IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Error inserting ticket');

  END IF;
   
   DBMS_OUTPUT.PUT_LINE('Ticket ID: ' || p_ticket_id_seq);
  
  v_seat_price := get_seat_price(p_show_id);
  
  -- Split the seat list into individual seats
  v_seat_count := REGEXP_COUNT(p_seat_list, ',') + 1;

IF v_seat_count = 0 or v_seat_count is null  THEN
    RAISE_APPLICATION_ERROR(-20001, 'No seats selected');
    
  END IF;
  DBMS_OUTPUT.PUT_LINE('Count : ' || v_seat_count);
  
    -- Calculate the price for the all the seats and add it to the total
  v_total_price := calculate_seat_price(v_seat_count, v_seat_price);

  
  -- Set the total price output parameter
  p_total_price := v_total_price;
  
  movie_booking_pkg.v_ticket_id_global := p_ticket_id_seq;
  movie_booking_pkg.v_checkout_price_global := v_total_price;
  
  DBMS_OUTPUT.PUT_LINE('Price : ' || movie_booking_pkg.v_checkout_price_global);
  COMMIT;
 EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
    
    
END checkout;
----------------------------------------------------------------
PROCEDURE processpayment (
    p_name IN VARCHAR2,
    p_address IN VARCHAR2,
    p_card_number IN VARCHAR,
    p_payment_id OUT NUMBER
)
AS
  v_ticket_id NUMBER;
  v_screen_id NUMBER;
  v_seat_list VARCHAR(20);
    p_customer_id NUMBER;
    p_amount NUMBER;
    p_ticket_id NUMBER;
    updatedrows NUMBER;
    v_payment_id NUMBER;
BEGIN
if movie_booking_pkg.v_ticket_id_global is not null then
            SELECT payment_id into v_payment_id FROM ticket WHERE ticket_id = movie_booking_pkg.v_ticket_id_global;
            
        if v_payment_id IS NOT NULL THEN
    	RAISE_APPLICATION_ERROR(-20001, 'Payment has already been processed for this ticket');
        END IF;
        END IF;
    IF LENGTH(p_card_number) <> 12 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Card number should be 12 characters long');
    END IF;
    p_amount := movie_booking_pkg.v_checkout_price_global;
  -- Insert payment record into payment table
  p_payment_id := make_payment(p_name,p_address,p_amount,'Successful',p_card_number);
  
  p_ticket_id := movie_booking_pkg.v_ticket_id_global;
  
  SELECT seat_list,screen_id INTO v_seat_list,v_screen_id FROM ticket WHERE ticket_id = p_ticket_id;
  DBMS_OUTPUT.PUT_LINE('seat_list: ' || v_seat_list);
  DBMS_OUTPUT.PUT_LINE('screen_id: ' || v_screen_id);
    updatedrows := update_seats(v_screen_id,v_seat_list);
  DBMS_OUTPUT.PUT_LINE('Updated rows: ' || updatedrows);
  -- Update ticket record with payment id
   UPDATE ticket
    SET payment_id = p_payment_id
    WHERE ticket_id = p_ticket_id;
  
  DBMS_OUTPUT.PUT_LINE('Payment ID: ' || p_payment_id);
  DBMS_OUTPUT.PUT_LINE('Ticket ID: ' || p_ticket_id);
COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ticket not found');
    --WHEN OTHERS THEN
      --RAISE_APPLICATION_ERROR(-20002, 'Error processing payment');
  ROLLBACK;
END processpayment;
   ----------------------------------------------------------------
    PROCEDURE AddAddOnsToCheckout(
        p_add_on_id IN VARCHAR2,
        p_quantity IN VARCHAR2,
        checkoutPrice OUT NUMBER
    )
    AS
        addonPrice NUMBER;
        totalrows NUMBER;
        p_ticket_id NUMBER;
        v_payment_id NUMBER;

    BEGIN
    if movie_booking_pkg.v_ticket_id_global is null then
             RAISE_APPLICATION_ERROR(-20001, 'select  seats first');
            END IF;
        if movie_booking_pkg.v_ticket_id_global is not null then
            SELECT payment_id into v_payment_id FROM ticket WHERE ticket_id = movie_booking_pkg.v_ticket_id_global;
            
        if v_payment_id IS NOT NULL THEN
    	RAISE_APPLICATION_ERROR(-20001, 'Payment has already been processed. Cannot modify addons checkout.');
        END IF;
        END IF;
        p_ticket_id := movie_booking_pkg.v_ticket_id_global;
        
        checkoutPrice := movie_booking_pkg.v_checkout_price_global ;
        DBMS_OUTPUT.PUT_LINE('Ticket_Id: ' || p_ticket_id);
        totalrows :=InsertMultipleAddOns(p_ticket_id => p_ticket_id,p_addon_list => p_add_on_id,p_quantity_list => p_quantity);

IF totalrows = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No rows were inserted into customer add ons.');
        END IF;
        DBMS_OUTPUT.PUT_LINE('Total Rows Added: ' || totalrows);
    
        addonPrice := CalculateMultipleAddOnsPrice(p_add_on_id,p_quantity);
        checkoutPrice := checkoutPrice + addonPrice;
        movie_booking_pkg.v_checkout_price_global := checkoutPrice;
        DBMS_OUTPUT.PUT_LINE('New Checkout Price: ' || movie_booking_pkg.v_checkout_price_global);
        COMMIT;
   EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            

    END AddAddOnsToCheckout;

----------------------------------------------------------------

   PROCEDURE get_ticket_history 
AS
BEGIN

  

    FOR r_show IN (SELECT t.ticket_id, m.movie_name, ss.start_date_time, ss.end_date_time, sc.screen_id, t.seat_list, p.payment_amount, p.payment_status, LISTAGG(a.addon_name, ', ') WITHIN GROUP (ORDER BY a.addon_id) AS addon_names,
       SUM(a.price * ca.addon_quantity) AS addon_total_price
    FROM ticket t
    INNER JOIN scheduled_show ss ON t.show_id = ss.show_id
    INNER JOIN movie_screen sc ON ss.screen_id = sc.screen_id
    INNER JOIN movie m ON ss.movie_id = m.movie_id
    INNER JOIN payment p ON t.payment_id = p.payment_id
    LEFT JOIN customer_addon ca ON t.ticket_id = ca.ticket_id
    LEFT JOIN addon a ON ca.addon_id = a.addon_id
    INNER JOIN customer c ON t.customer_id = c.customer_id
    WHERE c.customer_id = movie_booking_pkg.v_customer_id_global
    GROUP BY t.ticket_id, m.movie_name, ss.start_date_time, ss.end_date_time, sc.screen_id, t.seat_list, p.payment_amount, p.payment_status)
    
    LOOP
    DBMS_OUTPUT.PUT_LINE('Movie: ' || r_show.movie_name || ', Start Date/Time: ' || r_show.start_date_time || ', End Date/time:   ' || r_show.end_date_time || ', Screen ID: ' ||r_show.screen_id || ', Amount: ' || r_show.payment_amount || ', Status: ' || r_show.payment_status || ', Add-ons: ' || r_show.addon_names || ', ADdon Price: ' || r_show.addon_total_price);
    

  END LOOP; 
    
END get_ticket_history;




    
END movie_booking_pkg;
/





/*



*/



