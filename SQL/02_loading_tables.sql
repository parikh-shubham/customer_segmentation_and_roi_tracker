CREATE OR ALTER PROCEDURE load_tables AS

BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME;

	BEGIN TRY

	-- 1. Uploading Orders Table

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.orders'
		TRUNCATE TABLE dbo.orders;

		PRINT '>> Inserting Data Into Table: orders'
		BULK INSERT dbo.orders
		FROM 'C:\Users\Ben Ten\OneDrive\Desktop\Projects\Final\Marketing\data\clean data\clean_orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ---------------------------------';

	-- 2. Uploading Responses Table

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.responses'
		TRUNCATE TABLE dbo.responses;

		PRINT '>> Inserting Data Into Table: responses'
		BULK INSERT dbo.responses
		FROM 'C:\Users\Ben Ten\OneDrive\Desktop\Projects\Final\Marketing\data\clean data\clean_responses.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ---------------------------------';

	-- 3. Uploading Customer Segment Table
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.customer_segmented'
		TRUNCATE TABLE dbo.customers;

		PRINT '>> Inserting Data Into Table: customer_segmented'
		BULK INSERT dbo.customers
		FROM 'C:\Users\Ben Ten\OneDrive\Desktop\Projects\Final\Marketing\data\RFM_Segmentation\customers_segmented.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ---------------------------------';

	-- 4. Uploading RFM Clustered Table
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.rfm_clustered'
		TRUNCATE TABLE dbo.rfm;

		PRINT '>> Inserting Data Into Table: rfm_clustered'
		BULK INSERT dbo.rfm
		FROM 'C:\Users\Ben Ten\OneDrive\Desktop\Projects\Final\Marketing\data\RFM_Segmentation\rfm_clustered.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ---------------------------------';

	-- 5. Uploading Campaign Table

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.campaigns'
		TRUNCATE TABLE dbo.campaigns;

		PRINT '>> Inserting Data Into Table: campaigns'
		BULK INSERT dbo.campaigns
		FROM 'C:\Users\Ben Ten\OneDrive\Desktop\Projects\Final\Marketing\data\clean data\campaigns.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ---------------------------------';


	END TRY

	BEGIN CATCH

		PRINT '================================================='
		PRINT 'ERROR OCCURED DURING LOADING TABLES'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================='

	END CATCH

END

-- EXEC load_tables;