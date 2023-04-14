CREATE OR REPLACE FUNCTION get_seat_price (
    p_show_id IN NUMBER
)
RETURN NUMBER
AS
  v_price NUMBER;
BEGIN
  SELECT price
  INTO v_price
  FROM scheduled_show
  WHERE show_id = p_show_id;
  
  RETURN v_price;
END;
/




CREATE OR REPLACE FUNCTION calculate_seat_price (
    p_seat_count IN NUMBER,
    p_seat_price IN NUMBER
)
RETURN NUMBER
AS
  v_price NUMBER;
BEGIN
  
  v_price := p_seat_count*p_seat_price;
  
  RETURN v_price;
END;
/


CREATE OR REPLACE  FUNCTION CalculateAddOnPrice(
    addOnID IN NUMBER,
    quantity IN NUMBER
) RETURN NUMBER
AS
    addOnPrice NUMBER;
    totalPrice NUMBER;
BEGIN
    SELECT price INTO addOnPrice FROM addon WHERE addon_id = addOnID;
    totalPrice := addOnPrice * quantity;
    RETURN totalPrice;
END;
/

CREATE OR REPLACE TYPE NUMBER_ARRAY AS TABLE OF NUMBER;
/

CREATE OR REPLACE TYPE VARCHAR2_ARRAY IS TABLE OF VARCHAR2(100);

/


CREATE OR REPLACE FUNCTION STRING_TO_TABLE_number (
  p_string IN VARCHAR2,
  p_delimiter IN VARCHAR2
)
RETURN NUMBER_ARRAY DETERMINISTIC
AS
  l_string VARCHAR2(32767) := p_string || p_delimiter;
  l_delimiter_index PLS_INTEGER;
  l_index PLS_INTEGER := 1;
  l_tab NUMBER_ARRAY := NUMBER_ARRAY();
BEGIN
  LOOP
    l_delimiter_index := INSTR(l_string, p_delimiter, l_index);
    EXIT WHEN l_delimiter_index = 0;
    l_tab.EXTEND;
    l_tab(l_tab.COUNT) := TO_NUMBER(SUBSTR(l_string, l_index, l_delimiter_index - l_index));
    l_index := l_delimiter_index + 1;
  END LOOP;
  RETURN l_tab;
END STRING_TO_TABLE_number;
/



CREATE OR REPLACE FUNCTION STRING_TO_TABLE(
  p_string IN VARCHAR2,
  p_delimiter IN VARCHAR2 DEFAULT ','
)
RETURN VARCHAR2_ARRAY DETERMINISTIC
AS
  l_string VARCHAR2(32767) := p_string || p_delimiter;
  l_delimiter_index PLS_INTEGER;
  l_index PLS_INTEGER := 1;
  l_tab VARCHAR2_ARRAY := VARCHAR2_ARRAY();
BEGIN
  LOOP
    l_delimiter_index := INSTR(l_string, p_delimiter, l_index);
    EXIT WHEN l_delimiter_index = 0;
    l_tab.EXTEND;
    l_tab(l_tab.COUNT) := SUBSTR(l_string, l_index, l_delimiter_index - l_index);
    l_index := l_delimiter_index + 1;
  END LOOP;
  RETURN l_tab;
END STRING_TO_TABLE;

/


CREATE OR REPLACE FUNCTION CalculateMultipleAddOnsPrice(
    p_addon_list IN VARCHAR2,
    p_quantity_list IN VARCHAR2
)
RETURN NUMBER
IS
    l_addon_array VARCHAR2_ARRAY := STRING_TO_TABLE(p_addon_list, ',');
    
    l_quantity_array NUMBER_ARRAY := STRING_TO_TABLE_number(p_quantity_list, ',');
    l_total_price NUMBER := 0;
BEGIN
   
    FOR i IN 1..l_addon_array.COUNT LOOP
     DECLARE
            l_addon_id NUMBER;
     BEGIN
     SELECT addon_id INTO l_addon_id
            FROM addon
            WHERE addon_name = l_addon_array(i);
            
        l_total_price := l_total_price + CalculateAddOnPrice(l_addon_id, l_quantity_array(i));
        END;
    END LOOP;
    
    RETURN l_total_price;
END;
/

CREATE OR REPLACE FUNCTION InsertMultipleAddOns(
    p_ticket_id IN NUMBER,
    p_addon_list IN VARCHAR2,
    p_quantity_list IN VARCHAR2
)
RETURN NUMBER
IS
    l_addon_array VARCHAR2_ARRAY := STRING_TO_TABLE(p_addon_list, ',');
    
    l_quantity_array NUMBER_ARRAY := STRING_TO_TABLE_number(p_quantity_list, ',');
    l_rows_inserted NUMBER := 0;
    
BEGIN
    
    FOR i IN 1..l_addon_array.COUNT LOOP
    
        DECLARE
            l_addon_id NUMBER;
            
    BEGIN
        SELECT addon_id INTO l_addon_id
            FROM addon
            WHERE addon_name = l_addon_array(i);
            
        INSERT INTO customer_addon (addon_id, addon_quantity, ticket_id)
        VALUES (l_addon_id, l_quantity_array(i), p_ticket_id);
        l_rows_inserted := l_rows_inserted + 1;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Addon with name ' || l_addon_array(i) || ' not found');

        END;
    END LOOP;
    
    RETURN l_rows_inserted;
END;
/




CREATE OR REPLACE FUNCTION make_payment (
    p_name_on_card IN VARCHAR2,
    p_address IN VARCHAR2,
    p_payment_amount IN NUMBER,
    payment_status IN VARCHAR2,
    p_card_number IN VARCHAR2
) RETURN NUMBER
AS
  v_payment_id NUMBER;
BEGIN
  INSERT INTO payment(name_on_card, address, payment_amount,payment_status,card_number)
  VALUES (p_name_on_card,p_address,p_payment_amount,'Successful',p_card_number)
  RETURNING payment_id INTO v_payment_id;
  
  RETURN v_payment_id;
END make_payment;
/


CREATE OR REPLACE FUNCTION update_seats(v_screen_id IN NUMBER, v_seat_list IN VARCHAR2) RETURN NUMBER
IS
BEGIN
  UPDATE seat
  SET seat_status = 'N'
  WHERE screen_id = v_screen_id
  AND seat_number IN (
    SELECT REGEXP_SUBSTR(v_seat_list, '[^,]+', 1, LEVEL)
    FROM DUAL
    CONNECT BY LEVEL <= REGEXP_COUNT(v_seat_list, ',') + 1
  );
  
  RETURN SQL%ROWCOUNT;
END;
/

