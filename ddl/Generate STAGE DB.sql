CREATE TABLE Region
(
  Id INT NOT NULL,
  Name NVARCHAR(50) NOT NULL,
  Population INT NOT NULL,
  PositionX DECIMAL(9, 6) NOT NULL,
  PositionY DECIMAL(9, 6) NOT NULL,
  PRIMARY KEY (Id)
)
GO

CREATE TABLE Location
(
  Id INT NOT NULL,
  PositionX DECIMAL(9, 6) NOT NULL,
  PositionY DECIMAL(9, 6) NOT NULL,
  RegionId INT NOT NULL,
  PRIMARY KEY (Id),
  FOREIGN KEY (RegionId) REFERENCES Region(Id)
)
GO

CREATE TABLE Antenna
(
  Id INT NOT NULL,
  Name NVARCHAR(20) NOT NULL,
  Radius INT NOT NULL,
  Capacity INT NOT NULL,
  MaxTraffic INT NOT NULL,
  LocationId INT NOT NULL,
  PRIMARY KEY (Id),
  FOREIGN KEY (LocationId) REFERENCES Location(Id)
)
GO

CREATE TABLE CustomerType
(
  Id INT NOT NULL,
  Name NVARCHAR(10) NOT NULL,
  Description NVARCHAR(50) NOT NULL,
  PRIMARY KEY (Id),
  UNIQUE (Name)
)
GO

CREATE TABLE AntennaCoverage
(
  Id INT NOT NULL,
  Date DATETIME NOT NULL,
  Capacity INT NOT NULL,
  MaxTraffic INT NOT NULL,
  AntennaId INT NOT NULL,
  RegionId INT NOT NULL,
  PRIMARY KEY (Id),
  FOREIGN KEY (AntennaId) REFERENCES Antenna(Id),
  FOREIGN KEY (RegionId) REFERENCES Region(Id)
)
GO

CREATE TABLE Customer
(
  Id INT NOT NULL,
  Name NVARCHAR(100) NOT NULL,
  Phone NVARCHAR(15) NOT NULL,
  Email NVARCHAR(100) NOT NULL,
  LocationId INT NOT NULL,
  CustomerTypeId INT NOT NULL,
  PRIMARY KEY (Id),
  FOREIGN KEY (LocationId) REFERENCES Location(Id),
  FOREIGN KEY (CustomerTypeId) REFERENCES CustomerType(Id)
)
GO

CREATE TABLE Activity
(
  Id INT NOT NULL,
  Traffic INT NOT NULL,
  Speed INT NOT NULL,
  ActivityDate DATETIME NOT NULL,
  AntennaId INT NOT NULL,
  CustomerId INT NOT NULL,
  PRIMARY KEY (Id),
  FOREIGN KEY (AntennaId) REFERENCES Antenna(Id),
  FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
)
GO
