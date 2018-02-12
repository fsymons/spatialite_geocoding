@echo off
setlocal enableDelayedExpansion
rem *****Geocoding against GADM*****
rem
rem version of GADM = 2.8 [hard coded in SQL query below]
rem DOS Batch file to construct spatialite commands / SQL queries, and run the code
rem To use: Place all the CSVs you want to process in the folder and double-click the spatialite.bat file
rem CSVs MUST have following cols, in the following order:
REM
REM 1) longit : e.g. "-111.532". this should be a digital degree longitude in WGS 1984 
rem                              against the standard datum (ESPG 4326)
REM 2) lat    : e.g. "-39.846". Latitude, restrictions as above
REM 3) id     : e.g. "1". An integer field which is used as the primary key so each number must be unique
REM 4) notes  : e.g. "specimen_1". Assumed to be text. Helps you to know what thing it is.
REM 
REM Requires:
REM
REM *  This BAT
REM *  gadm28s.sqlite [2GB pre-populated spatialite database]
REM *  spatialite.exe [program which interacts with the database]
REM
REM spatialite_gui.exe is not necessary but is a nice way of running your own SQL queries
REM The CSV you construct may or may not have the headers in: it doesn't matter.
REM There is no error checking in this geocoding. If an input row does not appear in the output,
REM this either means it's duff input or it means the location is in the sea. It's your job to check...
rem
rem By Fernley Symons 19:58 06 February 2018
rem	14:37 12 February 2018: FS: changed main query to be left join so outputs all input
rem       lines and any matches against the reference geography. Changed reference geog.
rem       outputs to be the iso code for the country + the ids for the next 5 admin. levels
rem       (so would need a look up to know what the english names of these are).
rem       Could change this to give english names, or [alternatively] just the unique id
rem       for the shape and use a lookup for everything else from country downwards.
rem       Made script more robust to spaces in paths/filenames
rem 
rem *** _Important note_: To be sure this will work, don't include spaces or other
rem      strange characters in your paths/filenames (chars like '&' etc)***
rem
rem Due to DOS constraints, I don't think the comments can go next to the things they 
rem describe below. Here they are:- they apply to each operation/set of operations 
rem terminated by a "&"
rem *  For each CSV file in turn do... ...grab the filename
rem *  Change it so it has unix-style back slashes [required by spatialite]
rem *  Create a new variable which is the same name but with "_out" appended.
rem *  Some SQL. Drop the pts table if it exists, and then create it
rem *  Switch the sqlite mode to CSV
rem *  Import the CSV to the table
rem *  Delete any header row which might exist in the body of the table and create the
rem    point geometry
rem *  Switch to CSV mode again
rem *  Set the output as the "_out" csv
rem *  Run the spatial point-in-polygon query, using GADM spatial index. The GADM ver is hard coded here
rem Send the query results to the file
rem Drop the geometry column 
rem Drop the pts table ready for the next file
IF EXIST "%~dp0spatialite.sql" del /F "%~dp0spatialite.sql"
for /f "delims=|" %%i in ('dir /b *.csv') do set "gadm='gadm2.8'" & set "f=%%~fi" & set "f=!f:\=/!" & set "a=!f:.csv=_out.csv!" & echo select DiscardGeometryColumn('pts','geom'); drop table if exists pts; create table pts(longit numeric, lat numeric, id int NOT NULL PRIMARY KEY, notes varchar); >> "%~dp0spatialite.sql" & echo .mode csv >> "%~dp0spatialite.sql" & echo .import "!f!" pts >> "%~dp0spatialite.sql" & echo delete from pts where longit='longit'; SELECT AddGeometryColumn('pts', 'geom', 4326, 'POINT', 'XY', 0); update pts set geom=setsrid(makepoint(longit,lat),4326); >> "%~dp0spatialite.sql" & echo .mode csv >> "%~dp0spatialite.sql" & echo .output "!a!" >> "%~dp0spatialite.sql" & echo select 'fields are:'; select 'longit','original input longitude in WGS 1984'; select 'lat','original input latitude in WGS 1984'; select 'id','original input unique id (integer)'; select 'notes','some text to help you know what the specimen is'; select 'ver','GADM version'; select 'iso','ISO country code'; select 'id_1','GADM level 1 id'; select 'id_2','GADM level 2 id'; select 'id_3','GADM level 3 id'; select 'id_4','GADM level 4 id'; select 'id_5','GADM level 5 id'; >> "%~dp0spatialite.sql" & echo select ''; select ''; select 'longit','lat','id','notes','ver','iso','id_1','id_2','id_3','id_4','id_5'; >> "%~dp0spatialite.sql" & echo select a.longit,a.lat,a.id,a.notes,!gadm! "ver", b.iso,b.id_1,b.id_2,b.id_3,b.id_4,b.id_5 from pts a left join (select a.id,b.iso,id_1,id_2,id_3,id_4,id_5 from pts a left join gadm28s b on within(a.geom,b.geometry) where b.ROWID IN (SELECT ROWID FROM SpatialIndex where f_table_name ='gadm28s'and search_frame=a.geom)) b on a.id=b.id; >> "%~dp0spatialite.sql" & echo .output stdout >> "%~dp0spatialite.sql" & echo select DiscardGeometryColumn('pts','geom') >> "%~dp0spatialite.sql"; & echo drop table pts; >> "%~dp0spatialite.sql"
rem Now run this file against the database.
rem Comment this out if you just want the command file "spatialite.sql" inc the sql statements.
"%~dp0spatialite.exe" "%~dp0gadm28s.sqlite" < "%~dp0spatialite.sql"