set serveroutput on

BEGIN
   FOR cur_rec IN (SELECT object_name, object_type
                   FROM user_objects
                   WHERE object_type IN
                             ('TABLE',
                              'VIEW',
                              'MATERIALIZED VIEW',
                              'PACKAGE',
                              'PROCEDURE',
                              'FUNCTION',
                              'SEQUENCE',
                              'SYNONYM',
                              'PACKAGE BODY'
                             ))
   LOOP
      BEGIN
         IF cur_rec.object_type = 'TABLE'
         THEN
            EXECUTE IMMEDIATE 'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '" CASCADE CONSTRAINTS';
         ELSE
            EXECUTE IMMEDIATE 'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '"';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line ('FAILED: DROP '
                                  || cur_rec.object_type
                                  || ' "'
                                  || cur_rec.object_name
                                  || '"'
                                 );
      END;
   END LOOP;
   FOR cur_rec IN (SELECT * 
                   FROM all_synonyms 
                   WHERE table_owner IN (SELECT USER FROM dual))
   LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || cur_rec.synonym_name;
      END;
   END LOOP;
END;
/


--CREATE TABLES AS PER DATA MODEL

CREATE SEQUENCE movie_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999;

create table movie(
    movie_id NUMBER DEFAULT movie_id_seq.NEXTVAL PRIMARY KEY,
    movie_name varchar(1000),
    movie_description varchar(1000),
    movie_duration number(10),
    movie_language varchar(100),
    genre varchar(100),
    parental_rating varchar(100)
)

/

CREATE SEQUENCE customer_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999;

create table customer (
    customer_id NUMBER DEFAULT customer_id_seq.NEXTVAL PRIMARY KEY,
    customer_username varchar(100),
    customer_password varchar(100), 
    customer_name varchar(100), 
    customer_phone_number varchar(100), 
    customer_email varchar(100), 
    customer_dob date
)
/

CREATE SEQUENCE theatre_location_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999;

create table theatre_location (
    location_id NUMBER DEFAULT theatre_location_id_seq.NEXTVAL PRIMARY KEY, 
    theatre_city varchar(100),
    theatre_state varchar(100),
    theatre_zipcode varchar(10)
)

/

CREATE SEQUENCE theatre_id_seq
START WITH 1
INCREMENT BY 1;

create table theatre (
    theatre_id number(10) DEFAULT theatre_id_seq.NEXTVAL PRIMARY KEY,
    theatre_name varchar(100),
    location_id number(10),
    CONSTRAINT fk_location_id FOREIGN KEY (location_id) REFERENCES theatre_location(location_id)
)

/

CREATE SEQUENCE movie_screen_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999;

create table movie_screen (
    screen_id number(4) DEFAULT movie_screen_id_seq.NEXTVAL PRIMARY KEY,
    seat_count number(4),
    theatre_id number(10),
    CONSTRAINT fk_theatre_id FOREIGN KEY (theatre_id) REFERENCES theatre(theatre_id)
)

/
/*
CREATE SEQUENCE seat_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 999999999999999999999999999;

/*
create table seat (
    seat_id number(4) DEFAULT seat_id_seq.NEXTVAL PRIMARY KEY,
    screen_id number(4),
    seat_type varchar(10),
    seat_number number(4),
    seat_row varchar(2),
    seat_status varchar(2),
    CONSTRAINT fk_screen_id FOREIGN KEY (screen_id) REFERENCES movie_screen(screen_id)
)
*/

CREATE TABLE seat (
  seat_number VARCHAR(6),
  seat_status VARCHAR(2),
  seat_type varchar(10),
  screen_id NUMBER(4),
  CONSTRAINT pk_seat PRIMARY KEY  (seat_number),
  CONSTRAINT fk_screen_id FOREIGN KEY (screen_id) REFERENCES movie_screen(screen_id)
)
/

CREATE SEQUENCE scheduled_show_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

create table scheduled_show (
    show_id NUMBER(4) DEFAULT scheduled_show_id_seq.NEXTVAL PRIMARY KEY,
    screen_id number(4),
    movie_id number(4),
    start_date_time VARCHAR(100),
    end_date_time VARCHAR(100),
    price number(4),
    CONSTRAINT fk_show_movie_id FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    CONSTRAINT fk_show_screen_id FOREIGN KEY (screen_id) REFERENCES movie_screen(screen_id)
)
/

CREATE SEQUENCE payment_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

create table payment (
    payment_id number(4) DEFAULT payment_id_seq.NEXTVAL PRIMARY KEY,
    name_on_card varchar(50),
    address varchar(100),
    payment_amount varchar(10),
    payment_status varchar(10)
)
/


CREATE SEQUENCE addon_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

create table addon (
    addon_id number(4) DEFAULT addon_id_seq.NEXTVAL PRIMARY KEY,
    addon_name varchar(50),
    price number(4)
)
/


CREATE SEQUENCE ticket_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;



create table ticket (
    ticket_id number(4) DEFAULT ticket_id_seq.NEXTVAL PRIMARY KEY,
    customer_id number(4),
    show_id number(4),
    screen_id number(4),
    seat_list varchar(50),
    payment_id number(4),
    CONSTRAINT fk_ticket_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_ticket_show_id FOREIGN KEY (show_id) REFERENCES scheduled_show(show_id),
    CONSTRAINT fk_ticket_payment_id FOREIGN KEY (payment_id) REFERENCES payment(payment_id),
    CONSTRAINT fk_ticket_screen_id FOREIGN KEY (screen_id) REFERENCES movie_screen(screen_id)
)
/


CREATE TABLE customer_addon (
  addon_id NUMBER(4) ,
  addon_quantity NUMBER,
  ticket_id NUMBER REFERENCES ticket(ticket_id),
  CONSTRAINT fk_customer_add_id FOREIGN KEY (addon_id) REFERENCES addon(addon_id)
);
/

select *from customer_addon;

SELECT table_name FROM user_tables;


--------------- Creation of tables completed ----------------


INSERT INTO movie (movie_name, movie_description, movie_duration, movie_language, genre, parental_rating)
SELECT 'Frankenstein','An obsessed scientist assembles a living being from parts of exhumed corpses.',70,'English/Latin', 'Horror Thriller', 'PG13' FROM dual UNION ALL
SELECT 'A Free Soul','An alcoholic lawyer who successfully defended a notorious gambler on a murder charge objects when his free-spirited daughter becomes romantically involved with him.',110, 'English','Crime', 'PG13' FROM dual UNION ALL
SELECT 'Iron Man','Prizefighter Mason loses his opening fight so wife Rose leaves him for Hollywood. Without her around Mason trains and starts winning. Rose comes back and wants Mason to dump his manager Regan and replace him with her secret lover Lewis.',74,'English','Drama', 'G' FROM dual UNION ALL
SELECT 'Behind the Mask','An undercover Federal officer serving time in prison fakes his escape in order to infiltrate a heroin smuggling ring.',90,'English', 'Crime', 'PG13' FROM dual UNION ALL
SELECT 'Shang-Chi and the Legend of the Ten Rings ','Martial-arts master Shang-Chi confronts the past he thought he left behind when he is drawn into the web of the mysterious Ten Rings organization.',132,'English','Action', 'G' FROM dual UNION ALL
SELECT 'Free Guy','When a bank teller discovers he is actually a background player in an open-world video game, he decides to become the hero of his own story one that he can rewrite himself. In a world where there is no limits, he is determined to save the day his way before it is too late, and maybe find a little romance with the coder who conceived him',140, 'English','Comedy', 'G' FROM dual UNION ALL
SELECT 'The Occupant','Javier Munoz, once a successful executive, makes the fateful decision to leave his home, which him and his family can no longer afford.',95, 'Spanish','Thriller', 'PG13' FROM dual UNION ALL
SELECT 'Sooryavanshi','Starting off from where Akshay Kumar`s character was introduced in Simmba, Sooryavanshi traces the acts and serious antics of DCP Veer Sooryavanshi, the chief of the Anti-Terrorism Squad in India.',150,'Hindi','Action', 'G' FROM dual UNION ALL
SELECT 'Akhanda','A fierce devotee of Lord Shiva stands tall against evildoers.',160,'Telugu','Drama', 'G' FROM dual UNION ALL
SELECT 'House of Gucci','When Patrizia Reggiani, an outsider from humble beginnings, marries into the Gucci family, her unbridled ambition triggers a reckless spiral of betrayal, decadence, revenge, and ultimately...murder.',156, 'English', 'Crime', 'A' FROM dual UNION ALL
SELECT 'Kurup','Drawing inspiration from a real-life incident, Kurup is an adventure drama which is based on Kerala`s most eluding criminal who has been on the run since the mid-1980s.',157, 'Tamil','Crime','PG13' FROM dual UNION ALL
SELECT 'Eiffel','The government is asking Eiffel to design something spectacular for the 1889 Paris World Fair, but Eiffel simply wants to design the subway. Suddenly, everything changes when Eiffel crosses paths with a mysterious woman from his past.',113, 'French','Drama', 'G' FROM dual union all
SELECT 'Drushyam 2','The Resumption, or simply Drushyam 2 is an Indian Telugu-language crime drama film written and directed by Jeethu Joseph. It is a remake of the Malayalam film Drishyam 2 and a sequel to Drushyam',160, 'Malyalam','Drama', 'PG13' from dual union all
SELECT 'Venom: Let There Be Carnage','Eddie Brock is still struggling to coexist with the shape-shifting extraterrestrial Venom. When deranged serial killer Cletus Kasady also becomes host to an alien symbiote, Brock and Venom must put aside their differences to stop his reign of terror.',105,'English','Action', 'G' from dual union all
SELECT 'Red Notice','In the world of international crime, an Interpol agent attempts to hunt down and capture the worlds most wanted art thief.',116,'English','Comedy', 'G' from dual union all
SELECT 'Sherlock Holmes','When a couple of swindlers hold young Alice Faulkner against her will in order to discover the whereabouts of letters which could spell scandal for the royal family, Sherlock Holmes is on the case.',116,'English','Mystery', 'G' from dual union all
SELECT 'Cleopatra','The fabled queen of Egypts affair with Roman general Marc Antony is ultimately disastrous for both of them',100,'English','Drama/History', 'PG13' from dual;

select * from movie;

insert into customer (customer_username, customer_password, customer_name, customer_phone_number, customer_email, customer_dob) 
  select 'joe123','dsda2323','Joe','4772221246','abewindler@schoen.com',TO_DATE('1996-05-09','YYYY-MM-DD') from dual union all
  select 'sam123','dasd3$#2e2','Sam Morrow','5853008070','champlin.effie@grant.org',TO_DATE('1994-07-11','YYYY-MM-DD') from dual union all
  select 'garry123','fdsfv32','Garrison Douglas','4349398965','garrison.douglas@gmail.com',TO_DATE('1994-07-11','YYYY-MM-DD') from dual union all
  select 'brend','adfd%sc2#32','Brendan Giovani','6602187247','giovani72@yahoo.com',TO_DATE('1994-07-11','YYYY-MM-DD') from dual union all
  select 'senger21','sdas354','Senger Hermin','4067375114','senger.herminio@yahoo.com',TO_DATE('1994-05-25','YYYY-MM-DD') from dual union all
  select 'nicols2','s%df22','Nicolas Anahi','2175849501','nicolas.anahi@frami.net',TO_DATE('2000-03-04','YYYY-MM-DD') from dual union all
  select 'elmir21','casca22','Elmira Lee','5853008070','elmira88@yahoo.com',TO_DATE('1999-11-19','YYYY-MM-DD') from dual union all
  select 'holden323','dd#csd343','Holden Douglas','2155438228','Holden@yahoo.com',TO_DATE('1997-01-15','YYYY-MM-DD') from dual union all
  select 'shyanne2321','fsd122','Shyanne Shepard','2623286861','vrempel@gleichner.info',TO_DATE('1985-03-10','YYYY-MM-DD') from dual union all
  select 'zelma99','asd%e2','Zelma Boyer','8574378888','zelma86@gmail.com',TO_DATE('1994-08-21','YYYY-MM-DD') from dual;

select * from customer;

insert into theatre_location(theatre_city, theatre_state, theatre_zipcode)
  select 'Boston','MA','02101' from dual union all
  select 'New York','NY','10001' from dual union all
  select 'Newark','NJ','07101' from dual union all
  select 'San Diego','CA','22400' from dual union all
  select 'Richmond','VA','23173' from dual union all
  select 'Dallas','TX','75001' from dual union all
  select 'Fairfax','VA','22030' from dual union all
  select 'Atlanta','GA','30301' from dual union all
  select 'Long Beach','CA','90712' from dual union all
  select 'Seattle','WA','98101' from dual union all
  select 'Buffalo','NY','14201' from dual union all
  select 'Albany','NY','12084' from dual union all
  select 'Philadelphia ','PA','09019' from dual union all
  select 'Phoenix ','AZ','85001' from dual union all
  select 'Columbus ','OH','43004' from dual union all
  select 'Chicago ','IL','60007' from dual union all
  select 'Baltimore ','MD','21201' from dual;

SELECT * FROM theatre_location;
  
insert into theatre (theatre_name, location_id)
  select 'AMC',1 from dual union all
  select 'Regal Entertainment Group',12 from dual union all
  select 'Artcraft Theatre',14 from dual union all
  select 'Cinemark Theatres',14 from dual union all
  select 'Astor Theater',16 from dual union all
  select 'Marcus Corporation',15 from dual union all
  select 'Stages Theatre',13 from dual union all
  select 'AMC Anaheim Gardenwalk 6',12 from dual union all
  select '7th Street Theatre',12 from dual union all
  select '777 Theatre',12 from dual union all
  select 'AMC 34th Street 14',15 from dual union all
  select 'AMC Broadstreet 7',15 from dual union all
  select 'Harkins Theatres',12 from dual union all
  select 'AMC Classic Findlay 12',17 from dual union all
  select 'Regal Entertainment Group',13 from dual union all
  select 'MC Dine-In Rio Cinemas 18',13 from dual;
  
select *from theatre;
  


insert into movie_screen(seat_count, theatre_id)
   select 200,1 from dual union all
   select 100,1 from dual union all
   select 50,2 from dual union all
   select 25,2 from dual union all
   select 200,8 from dual union all
   select 100,8 from dual union all
   select 50,8 from dual union all
   select 25,11 from dual union all
   select 200,11 from dual union all
   select 100,10 from dual union all
   select 50,9 from dual union all
   select 25,11 from dual union all
   select 100,10 from dual union all
   select 50,8 from dual union all
   select 25,9 from dual union all
   select 200,5 from dual union all
   select 100,3 from dual union all
   select 50,3 from dual union all
   select 25,2 from dual;

select * from movie_screen;

insert into seat(screen_id, seat_type, seat_number,seat_status)
   select 1,'Balcony','20A','Y' from dual union all
   select 1,'Front','5B','Y' from dual union all
   select 1,'Upper','7C','Y' from dual union all
   select 1,'Centre','10D','Y' from dual union all
   select 1,'Centre','10E','Y' from dual union all
   select 2,'Upper','10A','Y' from dual union all
   select 2,'Upper','10B','Y' from dual union all
   select 3,'Balcony','25F','Y' from dual union all
   select 3,'Balcony','25A','Y' from dual union all
   select 3,'Balcony','25B','Y' from dual union all
   select 3,'Balcony','25C','Y' from dual union all
   select 3,'Balcony','25D','Y' from dual union all
   select 4,'Centre','5A','Y' from dual union all
   select 4,'Centre','3C','Y' from dual union all
   select 4,'Centre','3D','Y' from dual union all
   select 4,'Centre','3E','Y' from dual;
   
select * from seat;
   
insert into scheduled_show(screen_id, movie_id, start_date_time, end_date_time,price)  
  select 1,11,'8/12/2021 08:00:00','8/12/2021 11:30:00',120 from dual union all
  select 1,12,'9/12/2021 10:30:00','9/12/2021 01:30:00',132 from dual union all
  select 2,2,'11/1/2021 11:00:00','11/1/2021 02:30:00',40 from dual union all
  select 2,3,'11/1/2021 17:00:00','11/1/2021 19:30:00',50 from dual union all
  select 2,4,'11/1/2021 20:00:00','11/1/2021 22:30:00',40 from dual union all
  select 2,10,'5/2/2021 10:00:00','5/2/2021 00:30:00',120 from dual union all
  select 3,7,'6/2/2021 08:00:00','6/2/2021 11:30:00',150 from dual;

select * from scheduled_show;

insert into payment(name_on_card ,address, payment_amount)  
  select 'Samuel Jackson', 'Boston, MA', 75   from dual union all
  select 'Gary Neville', 'Hoboken, NJ', 125  from dual union all
  select 'Michael Senger', 'Walhtam, MA', 50 from dual union all
  select 'Mohammed Elmir', 'Providence, RI', 80 from dual union all
  select 'Gray Nicols', 'Santa Cruz, CA', 150 from dual union all
  select 'Jason Holden', 'St. Louis, MO', 25 from dual union all
  select 'Anna Zelma', 'Brooklyn, NY', 175 from dual;
  
select * from payment;


INSERT INTO addon(addon_name, price)
SELECT 'Extra Cheese', 2.5 FROM dual UNION ALL
SELECT 'Garlic Bread', 3.0 FROM dual UNION ALL
SELECT 'French Fries', 2.0 FROM dual UNION ALL
SELECT 'Onion Rings', 2.5 FROM dual;

select * from addon;


/*
insert into ticket(customer_id, show_id, seat_id, payment_id, addon_id)  
  select 9, 1, 19, 2, 3 from dual union all
  select 7, 2, 3, 3, 4 from dual union all
  select 5, 2, 4, 5, 1 from dual union all
  select 1, 3, 12, 7, 2 from dual union all
  select 8, 7, 11, 1, 1 from dual union all
  select 10, 6, 10, 4, 2 from dual union all
  select 6, 5, 7, 6, 3 from dual;
  */
select * from ticket;

select *from ticket;

------------------- Insertion into tables completed --------------------------
