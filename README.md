# spatialite_geocoding
Get the country etc a specimen falls within from GADM using spatialite on Windows

Requires:
=========
* Spatialite.exe compiled for Windows
* Pre-populated spatialite database containing GADM administrative areas (~2 GB)
* BAT available here
* CSV files(s) with the appropriate layout (below)

Place all the components above in a folder. Double-click the BAT file. You should find a new CSV with [filename] out.csv for each input file. It will contain all input rows and any matches from GADM. A list of fields is at the top.
