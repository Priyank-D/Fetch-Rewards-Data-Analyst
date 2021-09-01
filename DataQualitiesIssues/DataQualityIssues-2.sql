/*---------------------------------------------------------------------------
Users json data dump into tabular format using below SQL SERVER script.
---------------------------------------------------------------------------*/
DECLARE @JSON VARCHAR(MAX)
SELECT @JSON = BulkColumn
FROM OPENROWSET (BULK 'C:\Users\priya\Downloads\Fetch-Rewards\users.json', SINGLE_CLOB) AS i

DROP TABLE IF EXISTS #Users
CREATE TABLE #Users
(
 iD           VARCHAR(MAX)
,active       BIT
,createdDate  DATETIME
,lastLogin    DATETIME
,role         VARCHAR(MAX)
,signUpSource VARCHAR(10)
,state        VARCHAR(2)  
)

INSERT INTO #Users
SELECT --DISTINCT
id
,active
,DATEADD(S, CONVERT(INT,LEFT(createdDate, 10)), '1970-01-01') AS createdDate
,DATEADD(S, CONVERT(INT,LEFT(lastLogin, 10)), '1970-01-01') AS lastLogin
,role
,signUpSource
,state
FROM OPENJSON (@JSON,'$.Users') 
WITH (id           VARCHAR(MAX) '$._id."$oid"'
     ,active       BIT          '$.active'
	 ,createdDate  VARCHAR(100) '$.createdDate."$date"' 
	 ,lastLogin    VARCHAR(100) '$.lastLogin."$date"' 
	 ,role         VARCHAR(100) '$.role'
	 ,signUpSource VARCHAR(100) '$.signUpSource'
	 ,state        VARCHAR(100) '$.state'
)


SELECT * FROM #Users
/* if you see the output by running above query you will see around 495 records but there are lot of duplicate records you will find in this output.
So to over come from this you can use distinct to get unique records. 
Another thing is Null values in state,signUpSource and lastLogin. 
Null value is not good for signUpSource field which is used to identify sign up source of user.
This will lead Data security issues.
There should be some default value based on business requirement to avoid Null values.
For unique records run below query*/
SELECT DISTINCT * FROM #Users