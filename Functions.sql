

CREATE OR REPLACE FUNCTION REGION_RESTRICTED_MOVIE1(in_customer_id IN NUMBER, in_movie_id in NUMBER) 
Return VARCHAR2
IS
  cust_region VARCHAR2(100);
  movie_region VARCHAR2(100);
  var_movie_id number;
BEGIN
    SELECT m.movieid INTO var_movie_id FROM customer c JOIN address a ON a.CustomerID = c.CustomerID JOIN REGION r ON r.regionname=a.country
    JOIN   Movie m ON m.movieid = r.movieid  WHERE c.CustomerID = in_customer_id AND m.movieid = in_movie_id;
  IF var_movie_id IS NOT null THEN
    DBMS_OUTPUT.PUT_LINE('Play Movie');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Movie is not available in your Region');
  END IF;
END;


-----------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_movie_recommendation(genre IN VARCHAR2)
RETURN VARCHAR2
IS
  Movie_recommendations varchar2(3200);
BEGIN
  Movie_recommendations:='';
  for row in (
    SELECT DISTINCT m.movietitle
    FROM movie m
    JOIN (
        SELECT m.genreid, COUNT(*) as total_count
        FROM movie m
        INNER JOIN watch_history w ON m.movieId = w.movieId
        GROUP BY m.genreid
        ORDER BY total_count DESC
        FETCH FIRST 3 ROWS ONLY
    ) g ON m.genreid = g.genreid
    WHERE m.movieId NOT IN (
        SELECT movieId
        FROM watch_history
    )
    FETCH FIRST 10 ROWS ONLY
  ) loop
    Movie_recommendations:=Movie_recommendations || ' ' || row.movietitle;
  end loop;
  RETURN Movie_recommendations;
END;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_actormovies(p_actor IN VARCHAR2)   ------done1
RETURN VARCHAR2
IS
  v_movies VARCHAR2(32767); 
  v_actor VARCHAR2(32767); -- local variable to store converted actor name
  f_actor VARCHAR2(32767);
BEGIN
  v_movies := '';
  
  -- Convert input actor name to sentence case
  v_actor := LOWER(p_actor); -- Convert to lowercase
  f_actor := INITCAP(v_actor); -- Convert to initcap
  
  BEGIN
    FOR row IN (
      SELECT DISTINCT movietitle 
      FROM movie m
      JOIN movie_cast c ON m.movieID = c.movieID
      JOIN actor a ON c.actorID = a.actorID
      WHERE a.actorfirstname = f_actor OR a.actorlastname = f_actor
    ) LOOP
      v_movies := v_movies || row.movietitle || CHR(10); -- concatenate movie titles with newline separator
    END LOOP;
    
    IF v_movies IS NULL THEN
      v_movies := 'No movies found for the specified actor.';
    END IF;
    
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_movies := 'No movies found for the specified actor.';
    WHEN OTHERS THEN
      v_movies := 'Error occurred: ' || SQLERRM;
  END;
  
  RETURN v_movies;
END;
/
-----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_directormovies(p_director IN VARCHAR2)   ------done2
RETURN VARCHAR2
IS
  v_movies VARCHAR2(32767); 
  v_director VARCHAR2(32767); -- local variable to store converted actor name
  f_director VARCHAR2(32767);
BEGIN
  v_movies := '';
  
  -- Convert input actor name to sentence case
  v_director := LOWER(p_director); -- Convert to lowercase
  f_director := INITCAP(v_director); -- Convert to initcap
  
  BEGIN
    FOR row IN (
      SELECT DISTINCT movietitle 
      FROM movie m
      JOIN director d ON m.directorID = d.directorID
      WHERE d.directorfirstname = f_director OR d.directorlastname = f_director
    ) LOOP
      v_movies := v_movies || row.movietitle || CHR(10); -- concatenate movie titles with newline separator
    END LOOP;
    
    IF v_movies IS NULL THEN
      v_movies := 'No movies found for the specified director.';
    END IF;
    
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_movies := 'No movies found for the specified director.';
    WHEN OTHERS THEN
      v_movies := 'Error occurred: ' || SQLERRM;
  END;
  
  RETURN v_movies;
END;
/
------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_movies(p_genre IN VARCHAR2) ---- done3
RETURN VARCHAR2
IS
  v_movies VARCHAR2(32767); -- increased size of the variable
  v_genre VARCHAR2(32767); -- added variable to store sentence case genre name
BEGIN
  v_genre := p_genre; -- store the original input genre name
  v_movies := '';
  
  -- Convert input genre name to sentence case
  v_genre := LOWER(v_genre); -- Convert to lowercase
  v_genre := INITCAP(v_genre); -- Convert to initcap
  
  BEGIN
    FOR row IN (
      SELECT DISTINCT movietitle 
      FROM movie m
      JOIN genre g ON m.genreID = g.genreID
      WHERE g.genrename = v_genre -- corrected WHERE clause
    ) LOOP
      v_movies := v_movies || row.movietitle || CHR(10); -- concatenate movie titles with newline separator
    END LOOP;
    
    IF v_movies IS NULL THEN
      v_movies := 'No movies found for the specified genre.';
    END IF;
    
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_movies := 'No movies found for the specified genre.';
    WHEN OTHERS THEN
      v_movies := 'Error occurred: ' || SQLERRM;
  END;
  
  RETURN v_movies;
END;
/
------------------------------------------------------------------------------

--Renews plan adds a row to the purchase table
CREATE OR REPLACE FUNCTION auto_renew_plan(plan_id IN NUMBER, customer_id IN NUMBER)
RETURN NUMBER
IS
  purchase_id NUMBER;
  start_date DATE := SYSDATE;
  end_date DATE := ADD_MONTHS(SYSDATE, 1);
BEGIN
  SELECT MAX(purchaseid) + 1 INTO purchase_id FROM purchase;
  
  INSERT INTO purchase (purchaseid, planid, customerid, startdate, enddate)
  VALUES (purchase_id, plan_id, customer_id, start_date, end_date);
  
  COMMIT;
  
  RETURN (purchase_id);
END;

-- This is the function call 
/*DECLARE
  new_purchase_id NUMBER;
BEGIN
  new_purchase_id := auto_renew_plan(3, 123); -- replace with your plan_id and customer_id values
END;*/ 

