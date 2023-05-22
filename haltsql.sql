REM Procedure to stop a specific sql
REM
REM Author -- Kishan
REM
CREATE OR REPLACE PROCEDURE stopsql (sql_id IN VARCHAR2)
AS
   stmt VARCHAR (1000);
   CURSOR get_sql
   IS
	  SELECT s.sid, s.serial# serial, sq.sql_id FROM v$session s
                 INNER JOIN v$sql sq on (s.sql_id = sq.sql_id)
                 WHERE sq.sql_text like '%xtbl%'
                  AND
                 sq.sql_text not like '%INNER JOIN v$sql%'
                  AND 
                 sq.elapsed_time/1000000 > 1;
BEGIN
   FOR x IN get_sql
   LOOP
	  BEGIN
		 stmt :=  'ALTER SYSTEM CANCEL SQL ''' || x.sid || ',' || x.serial || '''' || '';
		 BEGIN
			EXECUTE IMMEDIATE stmt;
		 EXCEPTION
			WHEN OTHERS
			THEN
			   -- If there are any exceptions specify here
			   CONTINUE;
		 END;
	  END;
   END LOOP;
END;
/
