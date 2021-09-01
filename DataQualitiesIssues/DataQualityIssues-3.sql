/*---------------------------------------------------------------------------
Brands json data dump into tabular format using below SQL SERVER script.
---------------------------------------------------------------------------*/
DECLARE @JSON2 VARCHAR(MAX)
SELECT @JSON2=BulkColumn
FROM OPENROWSET (BULK 'C:\Users\priya\Downloads\Fetch-Rewards\brands.json', SINGLE_CLOB) AS i

DROP TABLE IF EXISTS #Brands
CREATE TABLE #Brands
(id           VARCHAR(MAX)
,barcode      VARCHAR(MAX)
,brandCode    VARCHAR(MAX)
,category     VARCHAR(MAX)
,categoryCode VARCHAR(MAX)
,cpgId        VARCHAR(MAX)
,cpgRef       VARCHAR(MAX)
,name         VARCHAR(MAX)
,topBrand     BIT         
)
INSERT INTO #Brands
SELECT DISTINCT * --To avoid duplicates
FROM OPENJSON (@JSON2,'$.Brands') 
WITH (id           VARCHAR(MAX) '$._id."$oid"'
     ,barcode      VARCHAR(MAX) '$.barcode'
	 ,brandCode    VARCHAR(MAX) '$.brandCode' 
	 ,category     VARCHAR(MAX) '$.category' 
	 ,categoryCode VARCHAR(MAX) '$.categoryCode'
	 ,cpgId        VARCHAR(MAX) '$.cpg."$id"."$oid"'
	 ,cpgRef       VARCHAR(MAX) '$.cpg."$ref"'
	 ,name         VARCHAR(MAX) '$.name'
	 ,topBrand     BIT          '$.topBrand'
)

SELECT * FROM #Brands
/*If you see the output of above query topBrand have null values. Now this will impact your decision when you wanted 
to check for topbrands. Crucial pieces of informations are missing here
*/