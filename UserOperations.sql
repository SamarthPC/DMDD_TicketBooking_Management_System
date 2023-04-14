set serveroutput on;
BEGIN
  movieadmin.Customer_Actions();
END;
/


set serveroutput on;


-- Call the login procedure to retrieve the customer ID
BEGIN
  movieadmin.movie_booking_pkg.login;
END;
/


select theatre_city from movieadmin.theatre_location;

BEGIN
    movieadmin.movie_booking_pkg.get_theater_names_by_location('Albany');
END;
/






BEGIN
 movieadmin.movie_booking_pkg.get_movies_by_theater('Regal Entertainment Group');
END;

/





BEGIN
  movieadmin.movie_booking_pkg.check_available_seats('The Occupant', '6/2/2021 08:00:00');
END;
/


DECLARE
  v_checkout_price NUMBER;
BEGIN
  
  movieadmin.movie_booking_pkg.checkout(
                     p_seat_list => '25C',
                     p_total_price => v_checkout_price);
  
END;
/



---- to checkout after selecting tickets



DECLARE
  v_checkout_price NUMBER;
BEGIN
  movieadmin.movie_booking_pkg.AddAddOnsToCheckout(
                     p_add_on_id => 'Fries,PopCorm,Candy',
                     p_quantity => '1,3,5',
                     checkoutPrice => v_checkout_price);
END;
/



DECLARE
  p_payment_id NUMBER;
BEGIN
  movieadmin.movie_booking_pkg.processpayment(
                     p_name => 'PP',
                     p_address => '02120',
                     p_card_number => '112345678912',
                     p_payment_id => p_payment_id);
END;
/





BEGIN
  movieadmin.movie_booking_pkg.get_ticket_history;
END;
/




