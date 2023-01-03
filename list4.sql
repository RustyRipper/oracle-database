-- ZAD 47

CREATE OR REPLACE TYPE KOCURY_T AS OBJECT(
	imie VARCHAR2(15),
	plec VARCHAR2(1),
	pseudo VARCHAR2(15),
	funkcja VARCHAR2(10),
	szef REF KOCURY_TYP,
	w_stadku_od DATE,
	przydzial_myszy NUMBER(3),
	myszy_extra NUMBER(3),
	nr_bandy NUMBER(3),
	MEMBER FUNCTION Dane RETURN VARCHAR2,
	MEMBER FUNCTION Dochod RETURN NUMBER,
	MEMBER FUNCTION WStadkuOd RETURN DATE
);
/

CREATE OR REPLACE TYPE BODY KOCURY_T AS
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN (CASE plec WHEN 'M' THEN 'Kot ' ELSE 'Kotka ' END)|| imie;
    END;
    MEMBER FUNCTION Dochod RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy,0)+NVL(myszy_extra,0);
    END;
    MEMBER FUNCTION WStadkuOd RETURN DATE IS
    BEGIN
        RETURN TO_CHAR(w_stadku_od, 'YYYY-MM-DD');
    END;
END;
/

CREATE OR REPLACE TYPE PLEBS_T AS OBJECT
(
	id_plebsu NUMBER,
	kocur REF KOCURY_T
);
/

CREATE OR REPLACE TYPE ELITA_T AS OBJECT
(
	id_elity NUMBER,
	kocur REF KOCURY_T,
	sluga REF PLEBS_T
);
/

CREATE OR REPLACE TYPE KONTO_T AS OBJECT
(
	id_akcji NUMBER,
	wlasciciel_konta REF ELITA_T,
	data_wprowadzenia DATE,
	data_usuniecia DATE,
	MEMBER PROCEDURE dodaj_mysz,
	MEMBER PROCEDURE usun_mysz
);
/

CREATE OR REPLACE TYPE BODY KONTO_T AS
    MEMBER PROCEDURE dodaj_mysz IS
    BEGIN
        data_wprowadzenia:=CURRENT_DATE;
    END;
    MEMBER PROCEDURE usun_mysz IS
    BEGIN
        data_usuniecia:=CURRENT_DATE;
    END;
END;
/

CREATE OR REPLACE TYPE INCYDENTY_T AS OBJECT
(
	id_incydentu NUMBER,
	ofiara REF KOCURY_T,
	imie_wroga VARCHAR2(15),
	data_incydentu DATE,
	opis_incydentu VARCHAR2(50),
	MEMBER FUNCTION Dane RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY INCYDENTY_T AS
    MEMBER FUNCTION Dane RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Incydent z '|| imie_wroga ||' w dniu '|| data_incydentu;
    END;
END;
/

CREATE TABLE KocuryR OF KOCURY_T
(
	CONSTRAINT kocr_pseudo_pk PRIMARY KEY (pseudo),
	CONSTRAINT kocr_func_fk FOREIGN KEY (funkcja) REFERENCES Funkcje(funkcja),
	CONSTRAINT kocr_banda_fk FOREIGN KEY (nr_bandy) REFERENCES Bandy(nr_bandy)
);

CREATE TABLE Plebs OF PLEBS_T
(
	CONSTRAINT plebs_pk PRIMARY KEY(id_plebsu),
	kocur NOT NULL
);

CREATE TABLE Elita OF ELITA_T
(
	CONSTRAINT elita_pk PRIMARY KEY(id_elity)
	kocur NOT NULL,
	sluga SCOPE IS Plebs,
);

CREATE TABLE Konto OF KONTO_T
(
	CONSTRAINT konto_pk PRIMARY KEY(id_akcji),
	wlasciciel_konta SCOPE IS Elita,
	CONSTRAINT konto_dw CHECK(data_wprowadzenia IS NOT NULL),
	CONSTRAINT konto_du CHECK(data_wprowadzenia >= data_usuniecia)
);

CREATE TABLE Incydenty OF INCYDENTY_T
(
	CONSTRAINT inc_pk PRIMARY KEY (id_incydentu),
	ofiara SCOPE IS KocuryR,
	imie_wroga NOT NULL,
	CONSTRAINT inc_wrog_fk FOREIGN KEY (imie_wroga) REFERENCES Wrogowie(imie_wroga),
	data_incydentu NOT NULL
);

DELETE Incydenty;
DELETE Konto;
DELETE Elita;
DELETE Plebs;
DELETE KocuryR;

DROP TABLE Incydenty;
DROP TABLE Konto;
DROP TABLE Elita;
DROP TABLE Plebs;
DROP TABLE KocuryR;
DROP TYPE BODY INCYDENTY_T;
DROP TYPE INCYDENTY_T;
DROP TYPE BODY KONTO_T;
DROP TYPE KONTO_T;
DROP TYPE ELITA_T;
DROP TYPE PLEBS_T;
DROP TYPE BODY KOCURY_T;
DROP TYPE KOCURY_T;

------INSERT-------------------------------------------------------------------------------
INSERT INTO KocuryR VALUES('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);

INSERT ALL
	INTO KocuryR VALUES('MICKA','D','LOLA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2009-10-14',25,47,1)
	INTO KocuryR VALUES('CHYTRY','M','BOLEK','DZIELCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2002-05-05',50,NULL,1)
	INTO KocuryR VALUES('KOREK','M','ZOMBI','BANDZIOR',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2004-03-16',75,13,3)
    INTO KocuryR VALUES('BOLEK','M','LYSY','BANDZIOR',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-08-15',72,21,2)
    INTO KocuryR VALUES('RUDA','D','MALA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-09-17',22,42,1)
    INTO KocuryR VALUES('PUCEK','M','RAFA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'2006-10-15',65,NULL,4)
SELECT * FROM DUAL;

INSERT ALL
    INTO KocuryR VALUES('JACEK','M','PLACEK','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2008-12-01',67,NULL,2)
    INTO KocuryR VALUES('BARI','M','RURA','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2009-09-01',56,NULL,2)
    INTO KocuryR VALUES('SONIA','D','PUSZYSTA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),'2010-11-18',20,35,3)
	INTO KocuryR VALUES('LATKA','D','UCHO','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2011-01-01',40,NULL,4)
    INTO KocuryR VALUES('DUDEK','M','MALY','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2011-05-15',40,NULL,4)
    INTO KocuryR VALUES('ZUZIA','D','SZYBKA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2006-07-21',65,NULL,2)
    INTO KocuryR VALUES('PUNIA','D','KURKA','LOWCZY',(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),'2008-01-01',61,NULL,3)
    INTO KocuryR VALUES('BELA','D','LASKA','MILUSIA',(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'2008-02-01',24,28,2)
    INTO KocuryR VALUES('KSAWERY','M','MAN','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2008-07-12',51,NULL,4)
    INTO KocuryR VALUES('MELA','D','DAMA','LAPACZ',(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),'2008-11-01',51,NULL,4)
SELECT * FROM DUAL;

INSERT INTO KocuryR VALUES('LUCEK','M','ZERO','KOT',(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'),'2010-03-01',43,NULL,3);

INSERT ALL
    INTO Plebs VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PLACEK'))
    INTO Plebs VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RURA'))
	INTO Plebs VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PUSZYSTA'))
	INTO Plebs VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='UCHO'))
    INTO Plebs VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALY'))
    INTO Plebs VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='SZYBKA'))
    INTO Plebs VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'))
    INTO Plebs VALUES(8,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'))
    INTO Plebs VALUES(9,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MAN'))
    INTO Plebs VALUES(10,(SELECT REF(K) FROM KocuryR K WHERE pseudo='DAMA'))
	INTO Plebs VALUES(11,(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZERO'))
SELECT * FROM DUAL;

INSERT ALL
    INTO Elita VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=1))
    INTO Elita VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LOLA'),NULL)
    INTO Elita VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=1))
    INTO Elita VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=2))
    INTO Elita VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=3))
    INTO Elita VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALA'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=4))
    INTO Elita VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RAFA'),(SELECT REF(P) FROM Plebs P WHERE id_plebsu=5))
SELECT * FROM DUAL;

INSERT ALL
    INTO Konto VALUES(1,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(2,(SELECT REF(E) FROM Elita E WHERE id_elity=2),SYSDATE,NULL)
    INTO Konto VALUES(3,(SELECT REF(E) FROM Elita E WHERE id_elity=3),SYSDATE,NULL)
    INTO Konto VALUES(4,(SELECT REF(E) FROM Elita E WHERE id_elity=4),SYSDATE,NULL)
    INTO Konto VALUES(5,(SELECT REF(E) FROM Elita E WHERE id_elity=4),SYSDATE,NULL)
    INTO Konto VALUES(6,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(7,(SELECT REF(E) FROM Elita E WHERE id_elity=6),SYSDATE,NULL)
    INTO Konto VALUES(8,(SELECT REF(E) FROM Elita E WHERE id_elity=1),SYSDATE,NULL)
    INTO Konto VALUES(9,(SELECT REF(E) FROM Elita E WHERE id_elity=4),SYSDATE,NULL)
    INTO Konto VALUES(10,(SELECT REF(E) FROM Elita E WHERE id_elity=4),SYSDATE,NULL)
SELECT * FROM DUAL;

INSERT ALL
    INTO Incydenty VALUES(1,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY')
	INTO Incydenty VALUES(2,(SELECT REF(K) FROM KocuryR K WHERE pseudo='ZOMBI'),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY')
    INTO Incydenty VALUES(3,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM')
	INTO Incydenty VALUES(4,(SELECT REF(K) FROM KocuryR K WHERE pseudo='SZYBKA'),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI')
    INTO Incydenty VALUES(5,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALA'),'CHYTRUSEK','2007-03-07','ZALECAL SIE')
    INTO Incydenty VALUES(6,(SELECT REF(K) FROM KocuryR K WHERE pseudo='TYGRYS'),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA')
    INTO Incydenty VALUES(7,(SELECT REF(K) FROM KocuryR K WHERE pseudo='BOLEK'),'DZIKI BILL','2007-11-10','ODGRYZL UCHO')
    INTO Incydenty VALUES(8,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
    INTO Incydenty VALUES(9,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LASKA'),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
    INTO Incydenty VALUES(10,(SELECT REF(K) FROM KocuryR K WHERE pseudo='DAMA'),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
    INTO Incydenty VALUES(11,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MAN'),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
    INTO Incydenty VALUES(12,(SELECT REF(K) FROM KocuryR K WHERE pseudo='LYSY'),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
    INTO Incydenty VALUES(13,(SELECT REF(K) FROM KocuryR K WHERE pseudo='RURA'),'DZIKI BILL','2009-09-03','ODGRYZL OGON')
    INTO Incydenty VALUES(14,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PLACEK'),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
    INTO Incydenty VALUES(15,(SELECT REF(K) FROM KocuryR K WHERE pseudo='PUSZYSTA'),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI')
    INTO Incydenty VALUES(16,(SELECT REF(K) FROM KocuryR K WHERE pseudo='KURKA'),'BUREK','2010-12-14','POGONIL')
    INTO Incydenty VALUES(17,(SELECT REF(K) FROM KocuryR K WHERE pseudo='MALY'),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA')
    INTO Incydenty VALUES(18,(SELECT REF(K) FROM KocuryR K WHERE pseudo='UCHO'),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM DUAL;

COMMIT;

-----Referencja

SELECT Elit.kocur.Dane() "Dane wlasciciela konta", Kon.data_wprowadzenia "Data wprowadzenia"
FROM Elita Elit LEFT JOIN Konto Kon ON K.wlasciciel_konta=REF(Elit)
WHERE Kon.data_wprowadzenia > Kon.data_usuniecia OR Kon.data_usuniecia IS NULL;

-----Podzapytanie

SELECT Pleb.kocur.imie "Imie", Pleb.kocur.funkcja, 
	NVL(Pleb.kocur.przydzial_myszy,0)+NVL(Pleb.kocur.myszy_extra,0) "Dochod"
FROM Plebs Pleb
WHERE P.kocur.pseudo IN (SELECT Elit.sluga.kocur.pseudo
                         FROM Elita Elit);
						 
-----Grupowanie

SELECT Kon.wlasciciel_konta.kocur.pseudo "Wlasciciel konta", COUNT(*) "Ile ma myszy"
FROM Konto Kon
WHERE Kon.data_wprowadzenia > Kon.data_usuniecia OR Kon.data_usuniecia IS NULL
GROUP BY Kon.wlasciciel_konta.kocur.pseudo
ORDER BY COUNT(*) DESC;

----ZADANIA LISTA 2---------------------------------------

-- ZAD 18

SELECT Koc.imie, Koc.WStadkuOd() "POLUJE OD"
FROM KocuryR Koc, KocuryR Koc2
WHERE Koc2.imie = 'JACEK' AND Koc.w_stadku_od < Koc2.w_stadku_od
ORDER BY Koc.w_stadku_od DESC;

-- ZAD 26      
                    
SELECT Koc.funkcja "Funkcja", ROUND(AVG(Koc.Dochod())) "Srednio najw. i najm. myszy"
FROM KocuryR Koc
WHERE Koc.funkcja <> 'SZEFUNIO'
GROUP BY Koc.funkcja
HAVING ROUND(AVG(Koc.Dochod())) IN (
    (
        SELECT MAX(ROUND(AVG(Koc2.Dochod())))
        FROM KocuryR Koc2
        WHERE Koc2.funkcja <> 'SZEFUNIO'
        GROUP BY Koc2.funkcja
    ),
    (
        SELECT MIN(ROUND(AVG(Koc3.Dochod())))
        FROM KocuryR Koc3
        WHERE Koc3.funkcja <> 'SZEFUNIO'
        GROUP BY Koc3.funkcja
    )
);
----ZADANIA LISTA 3---------------------------------------

-- ZAD 34

DECLARE
  fun KocuryR.funkcja%TYPE:='&nazwa_funkcji';
BEGIN
  SELECT funkcja INTO fun
  FROM KocuryR
  WHERE funkcja = UPPER(fun);
  DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || fun);
  
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || fun);
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota pelniacego funkcje ' || fun );
END;

-- ZAD 37

DECLARE
  nr NUMBER DEFAULT 1;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim  Zjada');
  DBMS_OUTPUT.PUT_LINE('--------------------');

  FOR kocur IN ( 
	SELECT Koc.pseudo, Koc.Dochod() cal_przydzial
	FROM KocuryR Koc
	ORDER BY cal_przydzial DESC) 
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(nr,3) || ' ' || RPAD(kocur.pseudo,10 )|| ' ' || LPAD(kocur.cal_przydzial,4));
    nr := nr + 1;
    EXIT WHEN nr > 5;
  END LOOP;
END;


---------END 47--------------------------------------------------

-- ZAD49

CREATE TABLE Myszy 
(
	nr_myszy NUMBER CONSTRAINT myszy_pk PRIMARY KEY,
	lowca VARCHAR2(15) CONSTRAINT lowca_fk REFERENCES Kocury(pseudo),
	zjadacz VARCHAR2(15) CONSTRAINT zjadacz_fk REFERENCES Kocury(pseudo),
	waga_myszy NUMBER(3),
	data_zlowienia DATE,
	data_wydania DATE
);
