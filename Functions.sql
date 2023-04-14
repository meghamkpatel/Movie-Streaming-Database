

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
  Movie_recommendations varchar2(3200)
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

---------------------------------------------------------------------------
/
CREATE OR REPLACE FUNCTION is_customer_active (Ncustomer_id IN NUMBER)
RETURN VARCHAR2
IS
    c_active VARCHAR2(20);
BEGIN
    SELECT CASE
        WHEN p.enddate >= SYSDATE THEN 'ACTIVE'
        ELSE 'NOT ACTIVE'
    END INTO c_active
    FROM purchase p
    JOIN customer c ON p.customerid = c.customerid
    WHERE c.customerid = Ncustomer_id ; 
    RETURN c_active;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid customer ID');
END;
/
-------------------------------------------------------------------------
/
CREATE OR REPLACE FUNCTION get_avg_rating_movie(p_movietitle IN VARCHAR2)
RETURN NUMBER
IS
  v_avg_rating NUMBER;
BEGIN
  SELECT AVG(ratings) INTO v_avg_rating
  FROM movie where movietitle=p_movietitle;
  
  RETURN v_avg_rating;
END;
/
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

CREATE OR REPLACE FUNCTION get_directormovies(p_director IN VARCHAR2)   ------
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
      JOIN director d ON m.directorID = c.directorID
      WHERE a.directorfirstname = f_director OR a.directorlastname = f_director
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
