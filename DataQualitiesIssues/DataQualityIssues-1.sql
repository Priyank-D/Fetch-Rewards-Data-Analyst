/*---------------------------------------------------------------------------
Receipts json data dump into tabular format using below SQL SERVER script.
---------------------------------------------------------------------------*/
DECLARE @JSON3 VARCHAR(MAX)
SELECT @JSON3=BulkColumn
FROM OPENROWSET (BULK 'C:\Users\priya\Downloads\Fetch-Rewards\receipts.json', SINGLE_CLOB) AS i

DROP TABLE IF EXISTS #Receipts
SELECT DISTINCT 
 JSON_Value (c.value,'$._id."$oid"')               AS id
,JSON_Value (c.value,'$.bonusPointsEarned')        AS bonusPointsEarned        
,JSON_Value (c.value,'$.bonusPointsEarnedReason')  AS bonusPointsEarnedReason  
,CONVERT(INT,JSON_Value (c.value,'$.purchasedItemCount'))       AS purchasedItemCount 
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.createDate."$date"'       ), 10)), '1970-01-01') AS createDate       
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.dateScanned."$date"'      ), 10)), '1970-01-01') AS dateScanned 
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.finishedDate."$date"'     ), 10)), '1970-01-01') AS finishedDate  
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.modifyDate."$date"'       ), 10)), '1970-01-01') AS modifyDate      
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.pointsAwardedDate."$date"'), 10)), '1970-01-01') AS pointsAwardedDate
,DATEADD(S, CONVERT(INT,LEFT(JSON_Value (c.value,'$.purchaseDate."$date"'     ), 10)), '1970-01-01') AS purchaseDate   
,JSON_Value (c.value,'$.pointsEarned')  AS pointsEarned          
,JSON_Value (p.value,'$.barcode'                ) AS r_barcode                 
,JSON_Value (p.value,'$.description'            ) AS r_description             
,JSON_Value (p.value,'$.finalPrice'             ) AS r_finalPrice              
,JSON_Value (p.value,'$.itemPrice'              ) AS r_itemPrice               
,JSON_Value (p.value,'$.needsFetchReview'       ) AS r_needsFetchReview        
,JSON_Value (p.value,'$.needsFetchReviewReason' ) AS r_needsFetchReviewReason  
,CONVERT(INT,JSON_Value (p.value,'$.partnerItemId'          )) AS r_partnerItemId           
,JSON_Value (p.value,'$.pointsNotAwardedReason' ) AS r_pointsNotAwardedReason  
,JSON_Value (p.value,'$.pointsPayerId'          ) AS r_pointsPayerId           
,JSON_Value (p.value,'$.preventTargetGapPoints' ) AS r_preventTargetGapPoints  
,JSON_Value (p.value,'$.quantityPurchased'      ) AS r_quantityPurchased       
,JSON_Value (p.value,'$.rewardsGroup'           ) AS r_rewardsGroup            
,JSON_Value (p.value,'$.rewardsProductPartnerId') AS r_rewardsProductPartnerId 
,JSON_Value (p.value,'$.userFlaggedBarcode'     ) AS r_userFlaggedBarcode      
,JSON_Value (p.value,'$.userFlaggedDescription' ) AS r_userFlaggedDescription  
,JSON_Value (p.value,'$.userFlaggedNewItem'	    ) AS r_userFlaggedNewItem	    
,JSON_Value (p.value,'$.userFlaggedPrice'       ) AS r_userFlaggedPrice        
,JSON_Value (p.value,'$.userFlaggedQuantity'    ) AS r_userFlaggedQuantity     
,JSON_Value (p.value,'$.pointsEarned'           ) AS r_pointsEarned	
,JSON_Value (p.value,'$.brandCode')                AS brandCode
,JSON_Value (c.value,'$.rewardsReceiptStatus'   ) AS rewardsReceiptStatus	
,CONVERT(MONEY,JSON_Value (c.value,'$.totalSpent'             )) AS totalSpent	
,JSON_Value (c.value,'$.userId'                 ) AS userId	
INTO #Receipts

FROM OPENJSON (@JSON3,'$.Receipts') as c
CROSS APPLY OPENJSON (c.value, '$.rewardsReceiptItemList') as p

-- Fields like finalPrice have data type NVARCHAR(String value) and I believe this field should be of type Money/Currency.
EXEC tempdb.dbo.sp_help @objname = N'#Receipts';
/*If you run below select query will give you records around 6,941
 We have two fields in Receipts data source purchasedItemCount (total number of items purchased in one receipt) and quantityPurchased (individual quantity of  item purchased in same receipt). Based on my analysis, the count should match for both these fields in a way that purchasedItemCount equals to sum of all quantityPurchased field for the same receipt.
i.e. purchasedItemCount=SUM(quantityPurchased)
But there are cases where counts of these fields are not matching. 
Example: The count for one of the receipt purchasedItemCount is 2 and sum of quantityPurchased is 4.
*/
SELECT purchasedItemCount,r_quantityPurchased,* FROM #Receipts WHERE id='5ff1e1d20a7214ada1000561'