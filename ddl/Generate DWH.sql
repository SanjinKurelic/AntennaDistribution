CREATE TABLE d_date
(
  d_date_sid INT IDENTITY(1,1) NOT NULL,
  date DATETIME NOT NULL,
  year INT NOT NULL,
  quarter INT NOT NULL,
  month INT NOT NULL,
  week INT NOT NULL,
  day INT NOT NULL,
  workday INT NOT NULL,
  weekend INT NOT NULL,
  PRIMARY KEY (d_date_sid)
)
GO

CREATE TABLE d_customer
(
  d_customer_sid INT IDENTITY(1,1) NOT NULL,
  customer_id INT NOT NULL,
  customer_name NVARCHAR(100) NOT NULL,
  customer_phone NVARCHAR(15) NOT NULL,
  customer_email NVARCHAR(100) NOT NULL,
  customer_location_id INT NOT NULL,
  customer_location_x DECIMAL(9, 6) NOT NULL,
  customer_location_y DECIMAL(9, 6) NOT NULL,
  customer_region_id INT NOT NULL, 
  date_from DATETIME NOT NULL,
  date_to DATETIME,
  PRIMARY KEY (d_customer_sid)
)
GO

CREATE TABLE d_customer_type
(
  d_customer_type_sid INT IDENTITY(1,1) NOT NULL,
  customer_type_id INT NOT NULL,
  customer_type_name NVARCHAR(10) NOT NULL,
  customer_type_description NVARCHAR(50) NOT NULL,
  PRIMARY KEY (d_customer_type_sid)
)
GO

CREATE TABLE d_antenna
(
  d_antenna_sid INT IDENTITY(1,1) NOT NULL,
  antenna_id INT NOT NULL,
  antenna_radius INT NOT NULL,
  antenna_name NVARCHAR(20) NOT NULL,
  antenna_capacity INT NOT NULL,
  antenna_traffic INT NOT NULL,
  antenna_location_id INT NOT NULL,
  antenna_location_x DECIMAL(9, 6) NOT NULL,
  antenna_location_y DECIMAL(9, 6) NOT NULL,
  antenna_region_id INT NOT NULL,
  date_from DATETIME NOT NULL,
  date_to DATETIME,
  PRIMARY KEY (d_antenna_sid)
)
GO

CREATE TABLE d_region
(
  d_region_sid INT IDENTITY(1,1) NOT NULL,
  region_id INT NOT NULL,
  region_name NVARCHAR(50) NOT NULL,
  region_population INT NOT NULL,
  region_x DECIMAL(9, 6) NOT NULL,
  region_y DECIMAL(9, 6) NOT NULL,
  PRIMARY KEY (d_region_sid)
)
GO

CREATE TABLE f_antenna_coverage
(
  f_antenna_coverage_sid INT IDENTITY(1,1) NOT NULL,
  coverage_id INT NOT NULL,
  coverage_capacity INT NOT NULL,
  coverage_traffic INT NOT NULL,
  date_sid INT NOT NULL,
  antenna_sid INT NOT NULL,
  region_sid INT NOT NULL,
  PRIMARY KEY (f_antenna_coverage_sid),
  FOREIGN KEY (date_sid) REFERENCES d_date(d_date_sid),
  FOREIGN KEY (antenna_sid) REFERENCES d_antenna(d_antenna_sid),
  FOREIGN KEY (region_sid) REFERENCES d_region(d_region_sid)
)
GO

CREATE TABLE f_customer_activity
(
  f_customer_activity_sid INT IDENTITY(1,1) NOT NULL,
  activity_id INT NOT NULL,
  activity_traffic INT NOT NULL,
  activity_speed INT NOT NULL,
  customer_type_sid INT NOT NULL,
  customer_sid INT NOT NULL,
  antenna_sid INT NOT NULL,
  region_sid INT NOT NULL,
  activity_date_sid INT NOT NULL,
  PRIMARY KEY (f_customer_activity_sid),
  FOREIGN KEY (customer_type_sid) REFERENCES d_customer_type(d_customer_type_sid),
  FOREIGN KEY (customer_sid) REFERENCES d_customer(d_customer_sid),
  FOREIGN KEY (antenna_sid) REFERENCES d_antenna(d_antenna_sid),
  FOREIGN KEY (region_sid) REFERENCES d_region(d_region_sid),
  FOREIGN KEY (activity_date_sid) REFERENCES d_date(d_date_sid)
)
GO

-- Procedures

CREATE PROCEDURE [dbo].[sp_insert_unknown_member]
AS
DECLARE @tc VARCHAR(100), @ts VARCHAR(100), @tn VARCHAR(100)
DECLARE @cn VARCHAR(100), @dt VARCHAR(100), @cml VARCHAR(100)
DECLARE @sql_ins NVARCHAR(4000), @values NVARCHAR(4000)

DECLARE ctables CURSOR 
FOR
SELECT table_catalog, table_schema, table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_type = 'BASE TABLE'
AND table_schema = 'dbo'
AND table_name IN ('d_date', 'd_customer', 'd_customer_type', 'd_region', 'd_antenna')

OPEN ctables

FETCH NEXT FROM ctables INTO @tc, @ts, @tn

WHILE @@fetch_status = 0 
BEGIN
	SET @sql_ins = 'set identity_insert ' + @tc + '.' + @ts + '.' + @tn + ' on ' + CHAR(10) + CHAR(13)
	SET @sql_ins = @sql_ins + 'insert into ' + @tc + '.' + @ts + '.' + @tn + '('
	
	SET @values = CHAR(10) + 'values ('
	
	DECLARE cColumns CURSOR
	FOR
	SELECT column_name, data_type, character_maximum_length FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = @tn ORDER BY ordinal_position
	
	OPEN cColumns
	FETCH NEXT FROM ccolumns INTO @cn, @dt, @cml
	
	WHILE @@fetch_status = 0
	BEGIN
		SET @sql_ins = @sql_ins + '[' + @cn + '], '
		
		SET @values = @values + CASE WHEN @dt = 'int' THEN '-99'
			WHEN @dt LIKE 'date%' THEN '''19000101'''
			WHEN @dt LIKE '%varchar' AND cast(@cml AS INT) = 1 THEN ''''''
			WHEN @dt LIKE '%varchar' AND cast(@cml AS INT) > 1 THEN '''NA'''
			WHEN @dt LIKE 'bit' THEN '0'
			WHEN @dt LIKE 'decimal' OR @dt LIKE 'numeric' THEN '0'
			ELSE 'BUG'
			END 
		SET @values = @values + ', '
		
		FETCH NEXT FROM ccolumns INTO @cn, @dt, @cml
	END
	CLOSE ccolumns
	DEALLOCATE ccolumns
	
	
	-- remove last comma
	SET @sql_ins = left(@sql_ins, len(@sql_ins) - 1) + ')'
	SET @values = left(@values, len(@values) - 1) + ')'
	
	SET @sql_ins = @sql_ins + @values + CHAR(10) + CHAR(13) + 'set identity_insert ' + @tc + '.' + @ts + '.' + @tn + ' off ' + CHAR(10) + CHAR(13)
	
	PRINT @sql_ins
	
	EXEC sp_executesql @sql_ins
	
	FETCH NEXT FROM ctables INTO @tc, @ts, @tn
END

CLOSE ctables
DEALLOCATE ctables
GO

CREATE PROCEDURE [dbo].[sp_fill_d_date]
AS
DECLARE @dwh_db_name as nvarchar(128)
DECLARE @myDateLoop as datetime
DECLARE @myLoopTo as datetime
DECLARE @sql nvarchar(max), @param_def nvarchar(500)

SET @dwh_db_name = db_name()
SET @myDateLoop = cast( '01/01/2022' as datetime)
SET @myLoopTo = dateAdd(yy, 1, @myDateLoop)
SET @param_def = N'@myDate datetime'

SET DATEFIRST 1

WHILE @myDateLoop < @myLoopTo
BEGIN	
	SET @sql = N'set identity_insert ' + @dwh_db_name + N'.dbo.d_date on' + CHAR(10) + CHAR(13) +
	N'insert into ' + @dwh_db_name + N'.dbo.d_date
		(
            [d_date_sid]
           ,[date]
		   ,[year]
           ,[quarter]
           ,[month]
           ,[week]
           ,[day]
		   ,[workday]
		   ,[weekend])
	select year(@myDate) * 10000 + month(@mydate) * 100 + day(@mydate)
            ,@myDate -- date
			,year (@myDate) -- year
			,datepart(qq, @myDate) -- quarter
			,month(@myDate) -- month
			,datepart(wk, @myDate) -- week
			,day(@myDate) -- day
			,case when datepart(dw, @myDate) <= 5 then 1 else 0 end --workday
			,case when datepart(dw, @myDate) > 5 then 1 else 0 end --weekend'
	
	EXEC sp_executesql @sql, @param_def, @myDate = @myDateLoop

	SET @myDateLoop = dateAdd(dd, 1, @myDateLoop)

END

-- Call procedures

EXEC [dbo].[sp_fill_d_date] -- d_table
GO

EXEC [dbo].[sp_insert_unknown_member] -- insert_unknown_member
GO

-- Update historic records date_to attribute

UPDATE [dbo].[d_antenna] SET date_to = NULL WHERE d_antenna_sid = -99

UPDATE [dbo].[d_customer] SET date_to = NULL WHERE d_customer_sid = -99