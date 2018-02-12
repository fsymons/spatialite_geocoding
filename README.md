# spatialite_geocoding
Get the country etc a specimen falls within from GADM (http://gadm.org/version2) using spatialite on Windows

*Requires:*

* Spatialite.exe compiled for Windows
* Pre-populated spatialite database containing GADM administrative areas (~2 GB)
* BAT available here
* CSV files(s) with the appropriate layout (below)

Place all the components above in a folder. Double-click the BAT file. You should find a new CSV with "[filename] out.csv" for each input file. It will contain all input rows and any matches from GADM. A list of fields is at the top.

*Spatialite database*
This was created using postgres. I chopped each shape into one small enough to fit in spatialite's page size (4kb), and indexed the resulting data. GADM appears to have a unique id for each shape. It then has a system of ids for administrative areas levels 0-5 inclusive, where 0 = country (it also has an iso code for these). The combination of all these ids is unique for an area and is the equivalent of the unique shape id.

The BAT's hard-coded query returns the ISO country code and then each of the level 1 - 5 codes in separate columns.

*CSVs*
These should have the following columns in the following order:
1) longit: e.g. "-111.532". this should be a digital degree longitude in WGS 1984 against the standard datum (ESPG 4326)
2) lat: e.g. "-39.846". Latitude, restrictions as above
3) id: e.g. "1". An integer field which is used as the primary key so each number must be unique
4) notes: e.g. "specimen_1". Assumed to be text. Helps you to know what thing it is.
