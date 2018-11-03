DROP TABLE IF EXISTS Supermercati;
CREATE TABLE Supermercati(
CodiceS VARCHAR(20) PRIMARY KEY,
Citta VARCHAR(50) NOT NULL,
Via VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS TipoReparti;
CREATE TABLE TipoReparti(
Codice VARCHAR(20) PRIMARY KEY,
Descrizione ENUM('Gastronomia','Macelleria','Casse','Ortofrutta','Pescheria','Pasticceria','Scatolame','NonAssegnato') NOT NULL
);

DROP TABLE IF EXISTS Reparti;
CREATE TABLE Reparti(
CodiceR VARCHAR(20),
Supermercato VARCHAR(20),
FOREIGN KEY(CodiceR) REFERENCES TipoReparti(Codice),
FOREIGN KEY(Supermercato) REFERENCES Supermercati(CodiceS),
PRIMARY KEY(CodiceR,Supermercato)
);

DROP TABLE IF EXISTS TipoDipendenti;
CREATE TABLE TipoDipendenti(
Codice INTEGER PRIMARY KEY,
Descrizione ENUM('Direttore','CapoReparto','Magazziniere','ImpiegatoSpecializzato','AddettoCorsia') NOT NULL
);

DROP TABLE IF EXISTS Dipendenti;
CREATE TABLE Dipendenti(
CodiceD VARCHAR(20) PRIMARY KEY,
Nome VARCHAR(30) NOT NULL,
Cognome VARCHAR(30) NOT NULL,
Citta VARCHAR(50), 
DataAssunzione DATE NOT NULL,
Salario DECIMAL(7,2) UNSIGNED NOT NULL,
Tipologia INTEGER,
RepartoAssegnato VARCHAR(20) NOT NULL,
Supermercato VARCHAR(20) NOT NULL,
FOREIGN KEY(Tipologia) REFERENCES TipoDipendenti(Codice),
FOREIGN KEY(RepartoAssegnato, Supermercato) REFERENCES Reparti(CodiceR,Supermercato)
);

DROP TABLE IF EXISTS Turni;
CREATE TABLE  Turni(
Dipendente VARCHAR(20),
DataInizio DATE NOT NULL,
DataFine DATE NOT NULL ,
OraInizio TIME NOT NULL,
OraFine TIME NOT NULL,
PRIMARY KEY(Dipendente,DataInizio),
FOREIGN KEY (Dipendente) REFERENCES Dipendenti(CodiceD)
);

DROP TABLE IF EXISTS Categorie;
CREATE TABLE Categorie(
CodiceCategoria VARCHAR(20) PRIMARY KEY,
Descrizione VARCHAR(50) NOT NULL,
IVA TINYINT UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS Prodotti;
CREATE TABLE Prodotti(
CodiceProdotto VARCHAR(20) PRIMARY KEY,
Nome VARCHAR(50) NOT NULL,
Prezzo DECIMAL(10,2) UNSIGNED NOT NULL,
Fresco BOOLEAN NOT NULL,
Categoria VARCHAR(20),
FOREIGN KEY (Categoria) REFERENCES Categorie(CodiceCategoria)
);

DROP TABLE IF EXISTS Magazzini;
CREATE TABLE Magazzini(
Supermercato VARCHAR(20),
Prodotto VARCHAR(20),
Quantita MEDIUMINT UNSIGNED NOT NULL,
PRIMARY KEY(Supermercato, Prodotto),
FOREIGN KEY (Supermercato) REFERENCES Supermercati(CodiceS),
FOREIGN KEY (Prodotto) REFERENCES Prodotti(CodiceProdotto)
);

DROP TABLE IF EXISTS Casse;
CREATE TABLE Casse(
Supermercato VARCHAR(20) ,
NumeroCassa TINYINT UNSIGNED,
FOREIGN KEY(Supermercato) REFERENCES Supermercati(CodiceS),
PRIMARY KEY (Supermercato, NumeroCassa)
);

DROP TABLE IF EXISTS Scontrino;
CREATE TABLE Scontrino(
NumeroScontrino INTEGER AUTO_INCREMENT,
Supermercato VARCHAR(20),
NumeroCassa TINYINT UNSIGNED,
Data DATE,
Ora TIME NOT NULL,
PRIMARY KEY(NumeroScontrino,Supermercato),
FOREIGN KEY(Supermercato,NumeroCassa) REFERENCES Casse(Supermercato,NumeroCassa)
);

DROP TABLE IF EXISTS Corsie;
CREATE TABLE Corsie(
NumeroCorsia TINYINT UNSIGNED PRIMARY KEY,
Descrizione VARCHAR(255)
);

DROP TABLE IF EXISTS Suddivisione;
CREATE TABLE Suddivisione(
Corsia TINYINT UNSIGNED,
Reparto VARCHAR(20) DEFAULT 'R02',
Supermercato VARCHAR(20),
FOREIGN KEY(Corsia) REFERENCES Corsie(NumeroCorsia),
FOREIGN KEY(Reparto,Supermercato) REFERENCES Reparti(CodiceR,Supermercato),
PRIMARY KEY(Corsia, Supermercato)
);

DROP TABLE IF EXISTS Vendite;
CREATE TABLE Vendite(
Scontrino INTEGER,
Supermercato VARCHAR(20),
Prodotto VARCHAR(20),
Quantita MEDIUMINT UNSIGNED NOT NULL,
FOREIGN KEY(Scontrino, Supermercato) REFERENCES Scontrino(NumeroScontrino, Supermercato),
FOREIGN KEY(Prodotto) REFERENCES Prodotti(CodiceProdotto),
PRIMARY KEY(Scontrino, Supermercato, Prodotto)
);

DROP TABLE IF EXISTS Ordini;
CREATE TABLE Ordini(
CapoReparto VARCHAR(20),
Data DATE NOT NULL,
Prodotto VARCHAR(20),
Quantita MEDIUMINT UNSIGNED NOT NULL,
FOREIGN KEY(CapoReparto) REFERENCES Dipendenti(CodiceD),
FOREIGN KEY(Prodotto) REFERENCES Prodotti(CodiceProdotto),
PRIMARY KEY(CapoReparto, Data, Prodotto)
);

DROP TABLE IF EXISTS Collocazione;
CREATE TABLE Collocazione(
Reparto VARCHAR(20),
Supermercato VARCHAR(20),
Prodotto VARCHAR(20),
Quantita MEDIUMINT UNSIGNED NOT NULL,
FOREIGN KEY(Prodotto) REFERENCES Prodotti(CodiceProdotto),
FOREIGN KEY(Reparto, Supermercato) REFERENCES Reparti(CodiceR, Supermercato),
PRIMARY KEY(Reparto, Supermercato, Prodotto)
);

DROP TABLE IF EXISTS TurniCasse;
CREATE TABLE TurniCasse(
AddettoCassa VARCHAR(20),
Supermercato VARCHAR(20),
Cassa TINYINT UNSIGNED,
DataT DATE,
OraInizio TIME,
OraFine TIME,
FOREIGN KEY(Supermercato,Cassa) REFERENCES Casse(Supermercato,NumeroCassa),
FOREIGN KEY(AddettoCassa) REFERENCES Dipendenti(CodiceD),
PRIMARY KEY(AddettoCassa, Cassa, DataT, OraInizio)
);

DROP TABLE IF EXISTS TurniCorsie;
CREATE TABLE TurniCorsie(
AddettoCorsia VARCHAR(20),
Corsia TINYINT UNSIGNED ,
Supermercato VARCHAR(20),
DataT DATE,
OraInizio TIME,
OraFine TIME,
FOREIGN KEY(Corsia,Supermercato) REFERENCES Suddivisione(Corsia,Supermercato),
FOREIGN KEY(AddettoCorsia) REFERENCES Dipendenti(CodiceD),
PRIMARY KEY(AddettoCorsia, Corsia, DataT, OraInizio)
);

DROP TRIGGER IF EXISTS CheckAssegnazioneR;
DELIMITER !!
CREATE TRIGGER CheckAssegnazioneR
BEFORE INSERT ON Dipendenti
FOR EACH ROW
BEGIN
DECLARE t ENUM('Direttore','CapoReparto','Magazziniere','ImpiegatoSpecializzato','AddettoCorsia');
SELECT Descrizione INTO t FROM TipoDipendenti WHERE Codice=New.Tipologia;
IF t='Direttore' OR t='Magazziniere' OR t='AddettoCorsia' THEN
SET New.RepartoAssegnato='R99';
END IF;
END !!
DELIMITER ;

DROP TRIGGER IF EXISTS OeDTurni;
DELIMITER !!
CREATE TRIGGER OeDTurni BEFORE INSERT ON Turni
FOR EACH ROW
BEGIN
DECLARE datass DATE;
DECLARE d VARCHAR(20);
DECLARE msg VARCHAR(255);
SELECT Dipendente INTO d FROM Turni WHERE Dipendente=New.Dipendente AND New.DataInizio>=DataInizio AND New.DataInizio<=DataFine;
SELECT DataAssunzione INTO datass FROM Dipendenti WHERE CodiceD=New.Dipendente;
IF New.OraInizio >= New.OraFine OR New.DataInizio > New.DataFine OR datass>New.DataInizio  THEN
SET New.OraInizio = NULL; 
ELSEIF d IS NOT NULL THEN
SET msg="Turno inserito errato. Data di inizio inserita presente in un altro turno";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END!!
DELIMITER ;

DROP TRIGGER IF EXISTS ControlloTurniCorsie;
DELIMITER !!
CREATE TRIGGER ControlloTurniCorsie BEFORE INSERT ON TurniCorsie
FOR EACH ROW
BEGIN
DECLARE ultimo DATE;
DECLARE c TINYINT UNSIGNED;
DECLARE tipo ENUM('Direttore','CapoReparto','Magazziniere','ImpiegatoSpecializzato','AddettoCorsia');
DECLARE datass DATE;
DECLARE maxul TIME;
DECLARE d VARCHAR(255);
DECLARE msg VARCHAR(255);
DECLARE oraf TIME;
SELECT AddettoCassa INTO d FROM TurniCasse T WHERE T.AddettoCassa=New.AddettoCorsia AND T.DataT=New.DataT AND New.OraInizio>=T.OraInizio AND New.OraFine<=T.OraFine;
SELECT MAX(OraFine) INTO maxul FROM TurniCorsie WHERE AddettoCorsia=New.AddettoCorsia AND DataT=New.DataT;
SELECT DataAssunzione INTO datass FROM Dipendenti WHERE CodiceD=New.AddettoCorsia;
SELECT MAX(DataFine) INTO ultimo FROM Turni WHERE Dipendente=New.AddettoCorsia;
SELECT Descrizione INTO tipo FROM Dipendenti, TipoDipendenti WHERE CodiceD= New.AddettoCorsia AND Tipologia=Codice;
SELECT Corsia INTO c FROM Suddivisione JOIN Dipendenti ON Suddivisione.Supermercato = Dipendenti.Supermercato WHERE CodiceD=New.AddettoCorsia AND Corsia=New.Corsia;
SELECT OraFine INTO oraf FROM Turni WHERE Dipendente=New.AddettoCorsia AND New.DataT>=DataInizio AND New.DataT<=DataFine;
IF c IS NULL THEN
SET msg="Corsia non presente nel supermercato";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF ((New.OraInizio >= New.OraFine)) THEN
SET msg="Orari inseriti errati";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (tipo<>'AddettoCorsia') THEN
SET msg="Il dipendente inserito non è un addetto alle corsie";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF ((ultimo IS NULL) OR (New.DataT>ultimo)  OR (New.DataT<datass)) THEN
SET msg="Data errata: turno non presente nella tabella Turni oppure la data inserita non è corretta";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (New.OraInizio<maxul) THEN
SET msg="Orario di inizio inserito errato. Turno già assegnato";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (New.OraInizio>=oraf OR New.OraFine>oraf) THEN
SET msg="Orari del turno della corsia inseriti errati, sono maggiori dell orario di fine del turno";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (d IS NOT NULL) THEN
SET msg="Orari del turno inseriti errati. Il turno inserito è in sovrapposizione con un turno già presente nella tabella TurniCasse";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END!!
DELIMITER ;

DROP TRIGGER IF EXISTS CheckTurniCasse; 
DELIMITER !!
CREATE TRIGGER CheckTurniCasse BEFORE INSERT ON TurniCasse
FOR EACH ROW 
BEGIN
DECLARE ultimo DATE;
DECLARE fineT TIME;
DECLARE c TINYINT UNSIGNED;
DECLARE tipo ENUM('Direttore','CapoReparto','Magazziniere','ImpiegatoSpecializzato','AddettoCorsia');
DECLARE datass DATE;
DECLARE maxul TIME;
DECLARE msg VARCHAR(255);
DECLARE d VARCHAR(255);
DECLARE oraf TIME;
SELECT AddettoCorsia INTO d FROM TurniCorsie T WHERE T.AddettoCorsia=New.AddettoCassa AND T.DataT=New.DataT AND New.OraInizio>=T.OraInizio AND New.OraFine<=T.OraFine;
SELECT OraFine INTO oraf FROM Turni WHERE Dipendente=New.AddettoCassa AND New.DataT>=DataInizio AND New.DataT<=DataFine;
SELECT MAX(OraFine) INTO maxul FROM TurniCasse WHERE AddettoCassa=New.AddettoCassa AND DataT=New.DataT;
SELECT DataAssunzione INTO datass FROM Dipendenti WHERE CodiceD=New.AddettoCassa;
SELECT MAX(DataFine) INTO ultimo FROM Turni WHERE Dipendente=New.AddettoCassa;
SELECT Descrizione INTO tipo FROM Dipendenti, TipoDipendenti WHERE CodiceD= New.AddettoCassa AND Tipologia=Codice;
SELECT NumeroCassa INTO c FROM Casse JOIN Dipendenti ON Casse.Supermercato = Dipendenti.Supermercato WHERE CodiceD=New.AddettoCassa AND NumeroCassa=New.Cassa;
IF c IS NULL THEN
SET msg="Cassa non presente nel supermercato";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF ((New.OraInizio >= New.OraFine)) THEN
SET msg="Orari inseriti errati";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (tipo<>'AddettoCorsia') THEN
SET msg="Il dipendente inserito non è un addetto alle corsie";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF ((ultimo IS NULL) OR (New.DataT>ultimo)  OR (New.DataT<datass)) THEN
SET msg="Data errata: turno non presente nella tabella Turni oppure la data inserita non è corretta";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (New.OraInizio<maxul) THEN
SET msg="Orario di inizio inserito errato. Turno già assegnato";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (New.OraInizio>=oraf OR New.OraFine>oraf) THEN
SET msg="Orari del turno della cassa inseriti errati, sono maggiori dell orario di fine del turno";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF (d IS NOT NULL) THEN
SET msg="Orari del turno inseriti errati. Il turno inserito è in sovrapposizione con un turno già presente nella tabella TurniCorsie";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END!!
DELIMITER ;

DROP TRIGGER IF EXISTS DiminuzioneScorte;
DELIMITER !!
CREATE TRIGGER DiminuzioneScorte  BEFORE INSERT ON Ordini
FOR EACH ROW
BEGIN
DECLARE nuovoQ MEDIUMINT UNSIGNED;
DECLARE vecchioQ MEDIUMINT UNSIGNED;
DECLARE p VARCHAR(20);
DECLARE s VARCHAR(20);
DECLARE msg VARCHAR(255);
DECLARE t BOOLEAN;
DECLARE r ENUM('Gastronomia','Macelleria','Casse','Ortofrutta','Pescheria','Pasticceria','Scatolame','NonAssegnato');
DECLARE tipo
ENUM('Direttore','CapoReparto','Magazziniere','ImpiegatoSpecializzato','AddettoCorsia');
DECLARE datass DATE;
SELECT DataAssunzione INTO datass FROM Dipendenti WHERE CodiceD=New.CapoReparto;
SELECT Descrizione INTO tipo FROM Dipendenti, TipoDipendenti WHERE CodiceD= New.CapoReparto AND Tipologia=Codice;
SELECT Quantita INTO vecchioQ FROM Magazzini WHERE Prodotto=New.Prodotto AND Supermercato=(SELECT Supermercato FROM Dipendenti WHERE CodiceD= New.CapoReparto);
SELECT Supermercato INTO s FROM Dipendenti WHERE CodiceD = New.CapoReparto;
SELECT Prodotto INTO p FROM Magazzini WHERE Prodotto= New.Prodotto AND Supermercato= s;
SELECT Fresco INTO t FROM Prodotti WHERE CodiceProdotto=New.Prodotto;
SELECT Descrizione INTO r FROM TipoReparti, Dipendenti WHERE CodiceD=New.CapoReparto AND Codice=RepartoAssegnato;
SET nuovoQ=vecchioQ-New.Quantita;
IF ( tipo<>'CapoReparto' OR (tipo='CapoReparto' AND (r='Casse' OR r='NonAssegnato')) OR ( tipo='CapoReparto' AND r='Scatolame' AND t=TRUE) OR ( tipo='CapoReparto' AND r<>'Scatolame' AND t=FALSE)) THEN 
set msg = "Ordine effettuato da personale non autorizzato"; 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF p IS NULL  THEN
set msg = "Prodotto non presente in magazzino"; 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF nuovoQ<0 THEN
SET msg="Quantita ordinata maggiore della quantita disponibile in magazzino";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF New.Data<datass THEN
SET msg="Data inserita non valida";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSE
UPDATE Magazzini SET Quantita = nuovoQ WHERE Prodotto=New.Prodotto AND Supermercato=(SELECT Supermercato FROM Dipendenti WHERE CodiceD= New.CapoReparto);
END IF;
END!!
DELIMITER ;

DROP TRIGGER IF EXISTS CollocaProdotti;
DELIMITER !!
CREATE TRIGGER CollocaProdotti AFTER INSERT ON Ordini
FOR EACH ROW
BEGIN 
DECLARE p VARCHAR(20);
DECLARE VQ MEDIUMINT UNSIGNED;
DECLARE s VARCHAR(20);
DECLARE r VARCHAR(20);
SELECT Supermercato INTO s FROM Dipendenti WHERE CodiceD = New.CapoReparto;
SELECT RepartoAssegnato INTO r FROM Dipendenti WHERE CodiceD = New.CapoReparto;
SELECT Prodotto INTO p FROM Collocazione WHERE Prodotto= New.Prodotto AND Supermercato = s AND Reparto =r;
IF p IS NOT NULL THEN
SELECT Quantita INTO VQ FROM Collocazione WHERE Prodotto = New.Prodotto AND Supermercato=s AND Reparto=r;
UPDATE Collocazione SET Quantita= VQ+New.Quantita WHERE Prodotto = New.Prodotto AND Supermercato = s AND Reparto = r;
ELSE
INSERT INTO Collocazione() VALUES(r,s,New.Prodotto, New.Quantita);
END IF;
END !!
DELIMITER ;

DROP TRIGGER IF EXISTS CheckCollocazione;
DELIMITER !!
CREATE TRIGGER CheckCollocazione BEFORE INSERT ON Collocazione
FOR EACH ROW
BEGIN
DECLARE s VARCHAR(20);
DECLARE msg VARCHAR(255);
DECLARE r VARCHAR(20);
SELECT Reparto INTO r FROM Collocazione WHERE Supermercato=New.Supermercato AND Prodotto=New.Prodotto;
SELECT Supermercato INTO s FROM Collocazione WHERE Supermercato=New.Supermercato AND Prodotto=New.Prodotto;
IF s IS NOT NULL AND New.Reparto<>r THEN
SET msg="Prodotto assegnato ad un altro reparto";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF s IS NOT NULL AND New.Reparto=r THEN
SET msg="Prodotto gia assegnato a questo reparto";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END!!
DELIMITER ;

DROP TRIGGER IF EXISTS DiminuzioneCollocazione;
DELIMITER !!
CREATE TRIGGER DiminuzioneCollocazione BEFORE INSERT ON Vendite
FOR EACH ROW
BEGIN
DECLARE msg VARCHAR(255);
DECLARE qVecchia MEDIUMINT UNSIGNED;
DECLARE qAcquistata MEDIUMINT UNSIGNED;
DECLARE r VARCHAR(20);
DECLARE s VARCHAR(20);
SET qAcquistata=New.Quantita;
SET s=New.Supermercato;
SELECT Reparto INTO r FROM Collocazione WHERE Supermercato=s AND Prodotto=New.Prodotto;
SELECT Quantita INTO qVecchia FROM Collocazione WHERE Supermercato=s AND Prodotto=New.Prodotto;
IF r IS NULL THEN
SET msg="Prodotto non presente nel supermercato";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
ELSEIF qVecchia>=qAcquistata THEN
UPDATE Collocazione SET Quantita=qVecchia-qAcquistata WHERE Prodotto = New.Prodotto AND Supermercato = s AND Reparto = r; 
ELSE
SET msg="Quantita venduta maggiore della quantita disponibile nel reparto, ricontrollare inserimento";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END !!
DELIMITER ;

DROP TRIGGER IF EXISTS CheckScontrino;
DELIMITER !!
CREATE TRIGGER CheckScontrino  BEFORE INSERT ON Scontrino
FOR EACH ROW
BEGIN
DECLARE d VARCHAR(20);
DECLARE msg VARCHAR(255);
SELECT AddettoCassa INTO d FROM TurniCasse T WHERE T.Cassa=New.NumeroCassa AND T.DataT=New.Data AND T.Supermercato=New.Supermercato AND  New.Ora>=T.OraInizio AND New.Ora <=T.OraFine;
IF d IS NULL THEN
SET msg="Cassa chiusa, nessuno addetto assegnato a questa cassa";
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;
END!!
DELIMITER ;

DROP FUNCTION IF EXISTS TotaleGiornata;
DELIMITER !!
CREATE FUNCTION TotaleGiornata(sup VARCHAR(20),d DATE) RETURNS DECIMAL(12,2)
BEGIN
DECLARE Totale DECIMAL(12,2);
SELECT SUM(V.Quantita*P.Prezzo) INTO Totale
FROM (Scontrino AS S JOIN Vendite AS V ON S.NumeroScontrino=V.Scontrino)
JOIN Prodotti AS P ON V.Prodotto=P.CodiceProdotto
WHERE  S.Supermercato=sup AND S.Data=d;
IF Totale IS NULL THEN
SET Totale=0;
END IF;
RETURN Totale;
END!!
DELIMITER ;

DROP FUNCTION IF EXISTS TotScontrino;
DELIMITER !!
CREATE FUNCTION TotScontrino(IdSC INTEGER,s VARCHAR(20)) RETURNS DECIMAL(7,2)
BEGIN
DECLARE Totale DECIMAL(7,2);
SELECT SUM(Quantita*Prezzo) INTO Totale
FROM Vendite  JOIN Prodotti  ON Prodotto=CodiceProdotto
WHERE  Scontrino=IdSC AND Supermercato=s;
IF Totale IS NULL THEN
SET Totale=0;
END IF;
RETURN Totale;
END!!
DELIMITER ;

DROP FUNCTION IF EXISTS TotaleGiornata;
DELIMITER !!
CREATE FUNCTION TotaleGiornata(sup VARCHAR(20),d DATE) RETURNS DECIMAL(12,2)
BEGIN
DECLARE Totale DECIMAL(12,2);
SELECT SUM(V.Quantita*P.Prezzo) INTO Totale
FROM (Scontrino AS S JOIN Vendite AS V ON S.NumeroScontrino=V.Scontrino)
JOIN Prodotti AS P ON V.Prodotto=P.CodiceProdotto
WHERE  S.Supermercato=sup AND S.Data=d;
IF Totale IS NULL THEN
SET Totale=0;
END IF;
RETURN Totale;
END!!
DELIMITER ;

DROP FUNCTION IF EXISTS ScorporoIva;
DELIMITER !!
CREATE FUNCTION ScorporoIva(p VARCHAR(20)) RETURNS DECIMAL(10,2)
BEGIN
DECLARE i TINYINT;
DECLARE pr DECIMAL(10,2);
DECLARE risultato DECIMAL(10,2);
SELECT IVA INTO i FROM Categorie JOIN Prodotti ON CodiceCategoria=Categoria WHERE CodiceProdotto=p;
SELECT Prezzo INTO pr FROM Prodotti WHERE CodiceProdotto=p;
SET risultato=(pr/(1+(i/100)))*(i/100);
RETURN risultato;
END !!
DELIMITER ;

DROP FUNCTION IF EXISTS IvaScontrino;
DELIMITER !!
CREATE FUNCTION IvaScontrino(s VARCHAR(20), n INTEGER) RETURNS DECIMAL(10,2) UNSIGNED
BEGIN
DECLARE totale DECIMAL(10,2) UNSIGNED;
DECLARE p VARCHAR(20);
SELECT SUM( ScorporoIva(Prodotto)*Quantita) INTO totale FROM Vendite WHERE Supermercato=s AND Scontrino=n;
RETURN totale;
END !!
DELIMITER ;



DROP VIEW IF EXISTS TotaleProdottiVendutiSupermercato;
CREATE VIEW TotaleProdottiVendutiSupermercato AS
SELECT Supermercato, Prodotto, SUM(Quantita) AS QuantitaTot
FROM Vendite
GROUP BY Supermercato, Prodotto;

DROP VIEW IF EXISTS MaxProdottiVendutiSupermercato;
CREATE VIEW MaxProdottiVendutiSupermercato AS
SELECT Supermercato, MAX(QuantitaTot) AS Massimo
FROM TotaleProdottiVendutiSupermercato
GROUP BY Supermercato;

DROP PROCEDURE IF EXISTS CercaDipScontrino;
DELIMITER !!
CREATE PROCEDURE CercaDipScontrino(IdSC INTEGER,s VARCHAR(20))
BEGIN
SELECT  AddettoCassa,Cognome,Nome
FROM (TurniCasse T  JOIN Scontrino S ON(T.DataT=S.Data AND T.Cassa=S.NumeroCassa AND T.Supermercato=S.Supermercato)) JOIN Dipendenti ON CodiceD=AddettoCassa
WHERE NumeroScontrino=IdSC AND T.Supermercato=s AND S.Ora>=T.OraInizio AND S.Ora<=T.OraFine;
END !!
DELIMITER ;

DROP PROCEDURE IF EXISTS PresenzaPersonale;
DELIMITER !!
CREATE PROCEDURE PresenzaPersonale(s VARCHAR(20), d DATE)
BEGIN
SELECT CodiceD, Nome, Cognome 
FROM Dipendenti, Turni
WHERE Supermercato=s AND DataInizio<=d AND DataFine>=d AND CodiceD=Dipendente;
END !!
DELIMITER ;

DROP PROCEDURE IF EXISTS IvaADebitoMensile;
DELIMITER !!
CREATE PROCEDURE IvaADebitoMensile(s VARCHAR(20), m INTEGER, a INTEGER)
BEGIN
SELECT SUM(IvaScontrino(s,NumeroScontrino)) AS IVAaDebito FROM Scontrino
WHERE YEAR(Data)=a AND MONTH(Data)=m AND Supermercato=s;
END !!
DELIMITER ;


INSERT INTO Supermercati() VALUES('S01','Padova','Via Verga, 1'),
('S02','Abano','Via Calle Pace, 10'),
('S03','Bologna','Via Roma, 7'),
('S04','Roma','Via Giovanni Paolo II, 5'),
('S05','Caltanissetta','Via dei Matti, 292');

INSERT INTO TipoDipendenti() VALUES(1,'Direttore'),
(2,'CapoReparto'),
(3,'Magazziniere'),
(4,'AddettoCorsia'),
(5,'ImpiegatoSpecializzato');

INSERT INTO TipoReparti() VALUES('R01','Casse'),
('R02','Scatolame'),
('R03','Gastronomia'),
('R04','Macelleria'),
('R05','Ortofrutta'),
('R06','Pescheria'),
('R07','Pasticceria'),
('R99','NonAssegnato');

INSERT INTO Reparti() VALUES('R01','S01'),('R02','S01'),('R03','S01'),
('R04','S01'),('R05','S01'),('R06','S01'),('R07','S01'),('R99','S01'),
('R01','S02'),('R02','S02'),('R99','S02'),('R05','S02'),('R03','S02');

INSERT INTO Dipendenti() VALUES
('D001','Paolo','Rossi','Padova','2014-03-02',1700,1,'R99','S01'),
('D005','Mario','Veronesi','Padova','2014-03-02',1700,1,'R99','S02'),
('D002','Gino','Verdi','Montegrotto','2014-03-02',1200,3,'R99','S01'),
('D003','Paola','Blu','Abano','2014-05-02',1200,2,'R01','S01'),
('D004','Pippo','Pluto','Padova','2014-06-10',1200,2,'R02','S01'),
('D006','Jack','Reaper','Abano','2014-05-02',1200,2,'R04','S01'),
('D007','Moby','Dick','Padova','2014-06-10',1200,2,'R06','S01'),
('D008','Paolo','Gentile','Padova','2014-02-14',1200,4,'R99','S01'),
('D009','Giacomo','Soffiato','Padova','2013-06-10',1200,4,'R99','S01');

INSERT INTO Turni() VALUES('D001','2015-1-14','2015-1-21',080000,160000),
('D003','2015-1-17','2015-1-24',080000,120000),('D008','2015-03-03','2015-03-10',080000,180000),
('D009','2015-03-04','2015-03-11',080000,120000);

INSERT INTO Corsie() VALUES(1,'Prodotti per la casa'),
(2,'Igene intima'),(3,'Panificati'),(4,'Alcolici'),(5,'Giochi');

INSERT INTO Categorie() VALUES('C01','Prodotti per la casa',22),
('C02',"Carne di Pollo",10),('C03',"Pesce d acqua salata",10);

INSERT INTO Prodotti() VALUES('P01','Dash detersivo',9.90, FALSE, 'C01'),
 ('P02','Ajax sgrassatore',2.50, FALSE, 'C01'),
 ('P03',"Petto di pollo",5.9,TRUE,'C02'),
 ('P04',"Filetto pesce spada",19.9,TRUE,'C03');
 
INSERT INTO Magazzini() VALUES('S01','P01',200),('S01','P02',150),
('S01','P03',75),('S01','P04',50),('S02','P01',100),('S02','P03',35);

INSERT INTO Casse() VALUES('S01',1),('S01',2),('S01',3),('S01',4),('S01',5),
('S01',6),('S01',7),('S01',8),('S01',9),('S01',10),('S02',1),('S02',2),
('S02',3),('S02',4),('S02',5);

INSERT INTO Suddivisione(Corsia,Supermercato)VALUES(1,'S01'),(2,'S01'),
(3,'S01'),(4,'S01'),(5,'S01'),(1,'S02');

INSERT INTO Collocazione() VALUES('R02','S01','P01',45),
('R02','S01','P02',50),('R04','S01','P03',40),
('R02','S02','P01',40);
	

INSERT INTO TurniCasse() VALUES('D008','S01',1,'2015-03-09',140000,160000),
('D009','S01',4,'2015-03-10',080000,110000);

INSERT INTO TurniCorsie() VALUES('D009',4,'S01','2015-03-10',110001,120000),
('D008',4,'S01','2015-03-10',160001,180000);

INSERT INTO Scontrino VALUES(1,'S01',1,'2015-03-09',150000),
(2,'S01',1,'2015-03-09',153000),
(3,'S01',1,'2015-03-09',140001);

INSERT INTO Vendite() VALUES(1,'S01','P01',5),(1,'S01','P02',2),
(2,'S01','P03',2);

INSERT INTO Ordini() VALUES('D004','2014-10-06','P01',50);

INSERT INTO Turni() VALUES('D008','2015-10-01','2015-10-08',080000,180000);
INSERT INTO TurniCasse() VALUES('D008','S01',1,'2015-10-02',080000,100000),
('D008','S01',4,'2015-10-02',120001,160000);
INSERT INTO TurniCorsie() VALUES('D008',4,'S01','2015-10-02',100001,120000),
('D008',4,'S01','2015-10-02',160001,180000);

INSERT INTO TurniCasse() VALUES('D008','S01',1,'2015-10-01',080000,100000),
('D008','S01',4,'2015-10-01',120001,160000);

INSERT INTO TurniCorsie() VALUES('D008',5,'S01','2015-10-01',100001,120000),
('D008',2,'S01','2015-10-01',160001,180000);

INSERT INTO Vendite VALUES (3,'S01','P03',10);

INSERT INTO Collocazione() VALUES('R06','S01','P04',45);

INSERT INTO Turni() VALUES('D009','2015-05-01','2015-05-08',080000,180000);

INSERT INTO TurniCasse() VALUES('D009','S01',6,'2015-05-02',080000,100000);

INSERT INTO Scontrino VALUES(4,'S01',6,'2015-05-02',090000);

INSERT INTO Vendite() VALUES(4,'S01','P01',5),(4,'S01','P02',1),
(4,'S01','P04',2);

INSERT INTO Turni() VALUES('D001','2015-03-03','2015-03-10',080000,180000),
('D002','2015-03-03','2015-03-10',080000,180000),
('D003','2015-03-03','2015-03-10',080000,180000),
('D004','2015-03-03','2015-03-10',080000,180000);
