-- What are the top 5 brands by receipts scanned for most recent month?

SELECT TOP 5
       Brands
	  ,MAX(rownum) AS 'Number of receipts scanned'
FROM 
(SELECT BD.sBrandName AS Brands
	   ,ROW_NUMBER() OVER(PARTITION BY BD.sBrandName ORDER BY BD.sBrandName) AS rownum
FROM dim_FactTable AS FB
JOIN dim_Date AS DD
ON   DD.iDate_id = FB.iDate_id
JOIN dim_Brands AS BD
ON   BD.iBrand_id = FB.iBrand_id
WHERE BD.bTopBrand = 1 
AND   MONTH(FB.dtIsDateScanned) = MONTH(GETDATE())
AND   YEAR(FB.dtIsDateScanned) = YEAR(GETDATE())
) AS t
GROUP BY Brands 
ORDER BY [Number of receipts scanned] DESC

-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

SELECT DATENAME(MONTH,Dates)
      ,Brands
	  ,counts
SELECT Brands
      ,MAX(rownum) as 'counts'
      ,Dates
	  ,ROW_NUMBER() OVER(PARTITION BY Dates ORDER BY Dates,MAX(rownum) DESC) as rowcounts
FROM
(SELECT BD.sBrandName AS Brands
       ,DD.dtDate AS Dates
	   ,ROW_NUMBER() OVER(PARTITION BY DD.iMonth,BD.sBrandName ORDER BY DD.iMonth,BD.sBrandName) AS rownum
FROM dim_FactTable AS FB
JOIN dim_Date AS DD
ON   DD.iDate_id = FB.iDate_id
JOIN dim_Brands AS BD
ON   BD.iBrand_id = FB.iBrand_id
WHERE BD.bTopBrand = 1 
AND   MONTH(FB.dtIsDateScanned) BETWEEN (MONTH(GETDATE())-1) AND MONTH(GETDATE())
AND   YEAR(FB.dtIsDateScanned) = YEAR(GETDATE())
) AS t
GROUP BY Brands,Dates) AS h
WHERE rowcounts<=5

-- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT RP.sRewardsReceiptStatus,AVG(FB.cTotalSpent) AS TotalSpent
FROM dim_FactTable AS FB
JOIN dim_Receipts AS RP
ON RP.iReceipt_id = FB.iReceipt_id
WHERE RP.sRewardsReceiptStatus in ('Accepted','Rejected')
ORDER BY TotalSpent DESC

--When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

SELECT RP.sRewardsReceiptStatus,SUM(FB.iPurchased_Item_Count) AS purchasedItemCount
FROM dim_FactTable AS FB
JOIN dim_Receipts AS RP
ON RP.iReceipt_id = FB.iReceipt_id
WHERE RP.sRewardsReceiptStatus in ('Accepted','Rejected')
ORDER BY purchasedItemCount DESC

--Which brand has the most spend among users who were created within the past 6 months?

SELECT TOP 1
        BD.sBrandName AS Brand
       ,SUM(FB.cTotalSpent) AS TotalSpend
FROM dim_FactTable AS FB
JOIN dim_Users AS US
ON   US.iUser_id = FB.iUser_id
JOIN dim_Date AS DD
ON   DD.iDate_id = FB.iDate_id
JOIN dim_Brands AS BD
ON   BD.iBrand_id = FB.iBrand_id 
WHERE CONVERT(DATE,FB.dtcreatedDate)>=  CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(m, -6,GETDATE())), 0))
ORDER BY TotalSpend DESC

--Which brand has the most transactions among users who were created within the past 6 months?
SELECT TOP 1
        BD.sBrandName AS Brand
       ,COUNT(FB.dtIspointsAwardedDate) AS 'Most Transactions'
FROM dim_FactTable AS FB
JOIN dim_Users AS US
ON   US.iUser_id = FB.iUser_id
JOIN dim_Date AS DD
ON   DD.iDate_id = FB.iDate_id
JOIN dim_Brands AS BD
ON   BD.iBrand_id = FB.iBrand_id 
WHERE FB.dtIspointsAwardedDate=1
AND   CONVERT(DATE,FB.dtcreatedDate)>=  CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(m, -6,GETDATE())), 0))
GROUP BY BD.sBrandName
ORDER BY [Most Transactions] DESC
