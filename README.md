# Antenna Distribution

Antenna Distribution is a project that shows how to run business analysis tools on set of a data. Data is consistent of several informations:

- positions of 5G antennas on island of Krk (in data source locations are scrambled)
- information about each antenna (like capacity, radius, traffic etc.)
- list of every region on island, and how many antennas does cover it
- list of connected customers and their static locations (measuring homebox internet)

Data is stored in CSV files in data directory [here](https://github.com/SanjinKurelic/AntennaDistribution/tree/main/data).

Data will firstly be loaded to relation database, called *AntennaDistribution_STAGE*, using the ETL generator.  Extract, transform, load (ETL) is the general procedure of copying data from one or more sources into a destination system which represents the data differently from the source or in a different context than the source. After that ETL will transform data to dimensions and fact tables to another database called *AntennaDistribution_DWH*. Thous tables will be used in OLAP (Online analytical processing) and also as ground for showing graphical BI reports.

DDL for *STAGE* and *DWH* tables is located in ddl directory [here](https://github.com/SanjinKurelic/AntennaDistribution/tree/main/ddl).

Graphicall representation of tables is shown below.

#### ER diagram

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/AntennaDistribution_ER.png)

#### Relation Schema

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/AntennaDistribution_RS.png)

## Getting started

### Requirements

This project use MS SQL database to store data and some Visual Studio plugins for transforming the data. Also, graphical diagrams are done in Power Bi.

- MS SQL with Management studio
- Visual Studio, 2019 or newer, with Integration Services and Analysis Service for Multidimensional and data mining
- Power BI

### Running

Before any process is started DDL scripts for *STAGE* and *DWH* (mentioned above) should be created. DDL-s does not contain database creation so this step should be done manually.

#### ETL

*AntennaDistributionETL* directory contain Visual Studio solution which defines all ETL tasks. After opening the solution, connection sources should be updated. Pay attention to use same encoding as I did:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/flatFileConfig.png)

Run Stage, Dimensions and Fact tasks in mentioned order.

Some stages are graphically shown below:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/etlStage.png)

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/etlStageLoad.png)

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/etlDimensionLoad.png)

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/etlFact.png)

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/etlFactLoad.png)

#### OLAP

After ETL is done with filling required data to *DWH* database, OLAP analysis can be done. Directory *AntennaDistributionOLAP* contain Visual Studion solution which defines all dimension and fact tables and their relationships.

Star schema for given tables is show on picture below:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/AntennaDistribution_DWH.png)

By using this definitions, various reports could be easily done, ex:

**Analysis 1:** For given date-time period show capacity and max traffic of antenna in some region:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/antennaCoverage.png)

**Analysis 2:** For given customer in region connected to some antenna show speed and trafic in some period of time:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/antennaCoverage.png)

#### Power BI

File *AntennaDistributionReports.pbix* given in this repository can be opened in power BI application. In that application analysis can be presented to management by using diagrams and other graphical elements.

**Analysis 3:** Show various customer informations:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/powerBICustomerDetails.png)

**Analysis 4:** Show various antenna informations:

![](https://github.com/SanjinKurelic/AntennaDistribution/blob/main/image/powerBIAntennaDetails.png)

## Licence

See the LICENSE file. For every question write to kurelic@sanjin.eu