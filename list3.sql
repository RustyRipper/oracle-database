
-- ZAD 34

DECLARE
  fun Kocury.funkcja%TYPE:='&nazwa_funkcji';
BEGIN
  SELECT funkcja INTO fun
  FROM Kocury
  WHERE funkcja = UPPER(fun);
  DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || fun);
  
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || fun);
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota pelniacego funkcje ' || fun );
END;

-- ZAD 35

DECLARE
  przydzial NUMBER;
  imie Kocury.imie%TYPE;
  miesiac NUMBER;
BEGIN
  SELECT imie, (NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0))*12, EXTRACT(MONTH FROM w_stadku_od)
  INTO imie, przydzial, miesiac
  FROM Kocury
  WHERE pseudo = UPPER('&pseudoParam');

  IF przydzial > 700 THEN 
      DBMS_OUTPUT.PUT_LINE('Calkowity roczny przydzial myszy >700');
  ELSE 
      IF imie LIKE '%A%' THEN 
          DBMS_OUTPUT.PUT_LINE('Imie zawiera litere A');
      ELSE 
          IF miesiac = 5 THEN 
              DBMS_OUTPUT.PUT_LINE('Maj jest miesiacem przystapienia do stada');
          ELSE 
              DBMS_OUTPUT.PUT_LINE('Nie odpowiada kryteriom');
          END IF;
      END IF;
  END IF;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono takiego kota');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- ZAD 36

DECLARE
  sumaPrzydzialow NUMBER DEFAULT 0;
  liczbaZmian NUMBER DEFAULT 0;
  maxPrzydzial NUMBER DEFAULT 0;
   
  CURSOR kursor IS
	SELECT pseudo, przydzial_myszy, Kocury.funkcja, Funkcje.max_myszy maxPrzydzial
    FROM Kocury JOIN Funkcje ON Kocury.funkcja = Funkcje.funkcja
    ORDER BY przydzial_myszy 
    FOR UPDATE OF przydzial_myszy;

  wiersz kursor % ROWTYPE;
  
BEGIN
  SELECT SUM(przydzial_myszy) INTO sumaPrzydzialow 
  FROM Kocury;

  <<zewn>>LOOP
    OPEN kursor;
    LOOP
      FETCH kursor INTO wiersz;
      EXIT WHEN kursor % NOTFOUND;
      
      IF (1.1 * wiersz.przydzial_myszy <= wiersz.maxPrzydzial) THEN
		  UPDATE Kocury SET przydzial_myszy = ROUND(1.1 * wiersz.przydzial_myszy)
          WHERE wiersz.pseudo = pseudo;

		  liczbaZmian := liczbaZmian + 1;
          sumaPrzydzialow := sumaPrzydzialow + ROUND(0.1 * wiersz.przydzial_myszy);
      ELSE 
          IF(wiersz.przydzial_myszy != wiersz.maxPrzydzial) THEN
              UPDATE Kocury
              SET przydzial_myszy = wiersz.maxPrzydzial
              WHERE wiersz.pseudo=pseudo;
				
              liczbaZmian:=liczbaZmian + 1;
              sumaPrzydzialow := sumaPrzydzialow + (wiersz.maxPrzydzial-wiersz.przydzial_myszy);
          END IF;
      END IF;    
      EXIT zewn WHEN sumaPrzydzialow > 1050;
    END LOOP;
    CLOSE kursor;
  END LOOP zewn;
  DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || sumaPrzydzialow || '  Zmian - ' || liczbaZmian);
END;

SELECT imie, NVL(przydzial_myszy, 0) "Myszki po podwyzce" 
FROM Kocury;

ROLLBACK;

-- ZAD 37

DECLARE
  nr NUMBER DEFAULT 1;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr  Pseudonim  Zjada');
  DBMS_OUTPUT.PUT_LINE('--------------------');

  FOR kocur IN ( 
	SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) cal_przydzial
	FROM Kocury 
	ORDER BY cal_przydzial DESC) 
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(nr,3) || ' ' || RPAD(kocur.pseudo,10 )|| ' ' || LPAD(kocur.cal_przydzial,4));
    nr := nr + 1;
    EXIT WHEN nr > 5;
  END LOOP;
END;

-- ZAD 38

DECLARE
  maxPoziom NUMBER;
  poziom NUMBER DEFAULT 1;
  liczbaPoziomow NUMBER DEFAULT &liczbaSzefow;
  kocur Kocury % ROWTYPE;
  
BEGIN
  SELECT MAX(level) - 1 INTO maxPoziom 
  FROM Kocury 
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;
  liczbaPoziomow := LEAST(maxPoziom, liczbaPoziomow);
  
  DBMS_OUTPUT.PUT('Imie        ');
  FOR i IN 1..liczbaPoziomow 
  LOOP
    DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE();

  DBMS_OUTPUT.PUT('--------------');
  FOR i IN 1..liczbaPoziomow 
  LOOP
    DBMS_OUTPUT.PUT(' --------------');
  END LOOP;
  DBMS_OUTPUT.NEW_LINE();

  FOR wiersz IN (
	SELECT * 
	FROM Kocury 
	WHERE funkcja IN ('MILUSIA', 'KOT')) 
  LOOP
    poziom := 1;
    DBMS_OUTPUT.PUT(RPAD(wiersz.imie,14));
    kocur := wiersz;

    WHILE poziom <= liczbaPoziomow 
	LOOP
      IF kocur.szef IS NULL THEN
          DBMS_OUTPUT.PUT(RPAD('|  ',15));
      ELSE
          SELECT * INTO kocur
		  FROM Kocury 
		  WHERE kocur.szef = pseudo;
          DBMS_OUTPUT.PUT(RPAD( '|  ' || kocur.imie, 15 ));
      END IF;
      poziom := poziom + 1;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE();
  END LOOP;
END;

-- ZAD 39

DECLARE
  nrBandy NUMBER := &numer;
  nazwaBandy VARCHAR2(20) := UPPER ('&nazwa');
  terenBandy VARCHAR2(15) := UPPER ('&teren');
  blad VARCHAR2(100) := '';
  ileTakichBand NUMBER :=0;
  ujemna EXCEPTION;
  istnieje EXCEPTION;
BEGIN

  IF nrBandy <= 0 THEN RAISE ujemna;
  END IF;

  SELECT COUNT(nr_bandy) INTO ileTakichBand 
  FROM Bandy 
  WHERE nr_bandy = nrBandy;
  IF ileTakichBand > 0 THEN 
	  blad := TO_CHAR(nrBandy); 
  END IF;

  SELECT COUNT(nazwa) INTO ileTakichBand 
  FROM Bandy 
  WHERE nazwaBandy = nazwa;
  IF ileTakichBand > 0 THEN
      IF LENGTH(blad) > 0 THEN 
		  blad:= blad || ', ' || nazwaBandy;
      ELSE blad := nazwaBandy;
      END IF;
  END IF;
	
  SELECT COUNT(teren) INTO ileTakichBand
  FROM Bandy 
  WHERE terenBandy = teren;
  IF ileTakichBand > 0 THEN
      IF LENGTH(blad) > 0 THEN
		  blad := blad || ', ' || terenBandy;
      ELSE blad := terenBandy;
      END IF;
  END IF;

  IF LENGTH(blad) > 0 THEN RAISE istnieje; 
  END IF;

  INSERT INTO Bandy(nr_bandy, nazwa, teren) VALUES (nrBandy, nazwaBandy, terenBandy) ;

  EXCEPTION
  WHEN ujemna THEN DBMS_OUTPUT.PUT_LINE('Liczba musi byc dodatnia');
  WHEN istnieje THEN DBMS_OUTPUT.PUT_LINE( blad || ' : juz istnieje');
END;

ROLLBACK;

SELECT * FROM Bandy;

-- ZAD 40

CREATE OR REPLACE PROCEDURE dodanieBandy(
  nrBandy Bandy.nr_bandy%TYPE,
  nazwaBandy Bandy.nazwa%TYPE,
  terenBandy Bandy.teren%TYPE) IS
  
  blad VARCHAR2(100) := '';
  ileTakichBand NUMBER := 0;
  ujemna EXCEPTION;
  istnieje EXCEPTION;
BEGIN

  IF nrBandy <= 0 THEN RAISE ujemna;
  END IF;

  SELECT COUNT(nr_bandy) INTO ileTakichBand 
  FROM Bandy 
  WHERE nr_bandy = nrBandy;
  IF ileTakichBand > 0 THEN 
	  blad := TO_CHAR(nrBandy); 
  END IF;

  SELECT COUNT(nazwa) INTO ileTakichBand 
  FROM Bandy 
  WHERE nazwaBandy = nazwa;
  IF ileTakichBand > 0 THEN
      IF LENGTH(blad) > 0 THEN 
		  blad:= blad || ', ' || nazwaBandy;
      ELSE blad := nazwaBandy;
      END IF;
  END IF;
	
  SELECT COUNT(teren) INTO ileTakichBand
  FROM Bandy 
  WHERE terenBandy = teren;
  IF ileTakichBand > 0 THEN
      IF LENGTH(blad) > 0 THEN
		  blad := blad || ', ' || terenBandy;
      ELSE 
	      blad := terenBandy;
      END IF;
  END IF;

  IF LENGTH(blad) > 0 THEN RAISE istnieje; 
  END IF;

  INSERT INTO Bandy(nr_bandy, nazwa, teren) VALUES (nrBandy, nazwaBandy, terenBandy);

  EXCEPTION
  WHEN ujemna THEN DBMS_OUTPUT.PUT_LINE('Liczba musi byc dodatnia');
  WHEN istnieje THEN DBMS_OUTPUT.PUT_LINE( blad || ' : juz istnieje');
END;

ROLLBACK;

BEGIN
  dodanieBandy(1, 'SZEFOSTWO', 'SAD');
END;
SELECT * FROM Bandy;

DROP PROCEDURE dodanieBandy;

-- ZAD 41

CREATE OR REPLACE TRIGGER generujNrBandy
BEFORE INSERT ON Bandy
FOR EACH ROW
DECLARE 
  numer NUMBER DEFAULT 0;
BEGIN

  SELECT MAX(nr_bandy) + 1 INTO numer 
  FROM Bandy;
  
  :NEW.nr_bandy := numer;
END;

BEGIN
  dodanieBandy(10, 'bandka', 'terenik');
END;
    
SELECT * FROM Bandy;
ROLLBACK;
DROP TRIGGER generujNrBandy;

-- ZAD 42a

CREATE OR REPLACE PACKAGE zmienne AS
  przydzialTygrysa NUMBER DEFAULT 0;
  ileDodatkow NUMBER DEFAULT 0;
  ileKar NUMBER DEFAULT 0;
END;


CREATE OR REPLACE TRIGGER pobierzPrzydzialTygrysa
BEFORE UPDATE ON Kocury
BEGIN
  SELECT przydzial_myszy INTO zmienne.przydzialTygrysa
  FROM Kocury 
  WHERE pseudo = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER zmianyPrzydzialuMilus
BEFORE UPDATE ON Kocury
FOR EACH ROW
DECLARE
  wzrostPrzydzialu NUMBER DEFAULT 0;
BEGIN
  IF :NEW.funkcja = 'MILUSIA' THEN
      IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
          DBMS_OUTPUT.PUT_LINE('Nie obsluguje zmniejszenia');
          :NEW.przydzial_myszy := :OLD.przydzial_myszy;
      ELSE
          wzrostPrzydzialu := :NEW.przydzial_myszy - :OLD.przydzial_myszy;
          IF wzrostPrzydzialu < 0.1 * zmienne.przydzialTygrysa THEN
              zmienne.ileKar := zmienne.ileKar+1;
              :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1*zmienne.przydzialTygrysa;
              :NEW.myszy_extra := :NEW.myszy_extra + 5;
          ELSE
			  IF wzrostPrzydzialu > 0.1 * zmienne.przydzialTygrysa THEN
				  zmienne.ileDodatkow := zmienne.ileDodatkow+1;
			  END IF;  
          END IF;
      END IF;
  END IF;
END;

CREATE OR REPLACE TRIGGER zmianyTygrysaPoMilus
AFTER UPDATE ON Kocury
DECLARE
  liczba NUMBER DEFAULT 0;
BEGIN
  IF zmienne.ileKar > 0 THEN
      liczba:= zmienne.ileKar;
      zmienne.ileKar := 0;
	  
      UPDATE Kocury
	  SET przydzial_myszy = FLOOR(przydzial_myszy - przydzial_myszy * 0.1 * liczba) 
	  WHERE pseudo='TYGRYS';
  END IF;
  IF zmienne.ileDodatkow >0 THEN
      liczba := zmienne.ileDodatkow;
      zmienne.ileDodatkow:=0;
	  
      UPDATE Kocury
	  SET myszy_extra  = myszy_extra+(5 * liczba)
	  WHERE pseudo='TYGRYS';
  END IF;
END;

SELECT * FROM Kocury;
UPDATE Kocury
SET przydzial_myszy = (przydzial_myszy +9)
WHERE FUNKCJA='MILUSIA';
ROLLBACK;

DROP TRIGGER pobierzPrzydzialTygrysa;
DROP TRIGGER zmianyPrzydzialuMilus;
DROP TRIGGER zmianyTygrysaPoMilus;
DROP PACKAGE zmienne;

-- ZAD 42b

CREATE OR REPLACE TRIGGER wirusMilus
FOR UPDATE ON Kocury
COMPOUND TRIGGER
  przydzialTygrysa NUMBER DEFAULT 0;
  ileDodatkow NUMBER DEFAULT 0;
  ileKar NUMBER DEFAULT 0;
  wzrostPrzydzialu NUMBER DEFAULT 0;
  liczba NUMBER DEFAULT 0;

  BEFORE STATEMENT IS BEGIN
    SELECT przydzial_myszy INTO przydzialTygrysa
	FROM Kocury
	WHERE pseudo='TYGRYS';
  END BEFORE STATEMENT ;

  BEFORE EACH ROW IS 
  BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
        IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
            :NEW.przydzial_myszy := :OLD.przydzial_myszy;
        ELSE
            wzrostPrzydzialu := :NEW.przydzial_myszy - :OLD.przydzial_myszy;
            IF wzrostPrzydzialu < 0.1 * przydzialTygrysa THEN
                ileKar := ileKar+1;
                :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * przydzialTygrysa;
                :NEW.myszy_extra := :NEW.myszy_extra + 5;
            ELSE
			    IF wzrostPrzydzialu > 0.1 * przydzialTygrysa THEN
				    ileDodatkow := ileDodatkow+1;
		  	    END IF;  
            END IF;
        END IF;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS 
    BEGIN
    IF ileKar > 0 THEN
        liczba:= ileKar;
        ileKar := 0;
	  
        UPDATE Kocury
	    SET przydzial_myszy = FLOOR(przydzial_myszy - przydzial_myszy * 0.1 * liczba) 
	    WHERE pseudo='TYGRYS';
    END IF;
    IF ileDodatkow >0 THEN
        liczba := ileDodatkow;
        ileDodatkow:=0;
	  
        UPDATE Kocury
	    SET myszy_extra  = myszy_extra+(5 * liczba)
	    WHERE pseudo='TYGRYS';
    END IF;
  END AFTER STATEMENT;
END;

DROP TRIGGER wirusMilus;




-- ZAD 43 modyfikacja
DECLARE
                           
  CURSOR funkcjeSuma IS SELECT funkcja, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) sumaDlaFunkcji
						FROM Kocury
                        GROUP BY funkcja
                        ORDER BY funkcja;
  
  CURSOR bandyFunkcjePlcie IS SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) sumaDlaBandyPlciFunkcji, nazwa, plec, funkcja
							  FROM Kocury NATURAL JOIN Bandy
							  GROUP BY nazwa, plec, funkcja
							  ORDER BY nazwa, plec , funkcja;
							  
  CURSOR bandyPlcieIleSuma IS SELECT COUNT(*) iloscDlaBandyPlci, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) sumaDlaBandyPlci
                              FROM Kocury NATURAL JOIN Bandy
                              GROUP BY nazwa, plec
                              ORDER BY nazwa, plec;							  
							  
                        
  liczba NUMBER;
  bfp bandyFunkcjePlcie%ROWTYPE;
  bpis bandyPlcieIleSuma%ROWTYPE;
BEGIN
  DBMS_OUTPUT.PUT('NAZWA BANDY       PLEC   ILE ');
  FOR func IN funkcjeSuma
  LOOP
    DBMS_OUTPUT.PUT(LPAD(func.funkcja, 10));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(LPAD('SUMA', 10));
  DBMS_OUTPUT.PUT('---------------   ------ --- ');

  FOR func IN funkcjeSuma
  LOOP
    DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');


---------------------------------
  OPEN bandyFunkcjePlcie;
  OPEN bandyPlcieIleSuma;
  FETCH bandyFunkcjePlcie INTO bfp;
  FOR banda IN (SELECT nazwa, nr_bandy
				FROM Bandy
                WHERE szef_bandy IS NOT NULL
                ORDER BY nazwa) 
  LOOP
    FOR plecElem IN (SELECT plec
				     FROM Kocury
			         GROUP BY plec
                     ORDER BY plec) 
	LOOP
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN RPAD( banda.nazwa, 18 ) ELSE  RPAD( ' ', 18 ) END);
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN 'Kotka' ELSE 'Kocor' END);

		FETCH bandyPlcieIleSuma INTO bpis;
        DBMS_OUTPUT.PUT(LPAD(bpis.iloscDlaBandyPlci, 4));
        DBMS_OUTPUT.PUT(' ');
        
        FOR func IN funkcjeSuma 
		LOOP
          IF func.funkcja = bfp.funkcja AND banda.nazwa = bfp.nazwa AND plecElem.plec = bfp.plec THEN 
              DBMS_OUTPUT.PUT(LPAD(NVL(bfp.sumaDlaBandyPlciFunkcji, 0), 10));
              FETCH bandyFunkcjePlcie INTO bfp;
          ELSE
              DBMS_OUTPUT.PUT(LPAD(NVL(0, 0), 10));
          END IF;
        END LOOP;

        DBMS_OUTPUT.PUT(LPAD(NVL( bpis.sumaDlaBandyPlci, 0 ), 10 ));
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
  END LOOP;
  CLOSE bandyPlcieIleSuma;
  CLOSE bandyFunkcjePlcie;
  DBMS_OUTPUT.PUT('Z---------------- ------ --- ');
  FOR func IN funkcjeSuma
  LOOP 
    DBMS_OUTPUT.PUT(' ---------'); 
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');

  DBMS_OUTPUT.PUT('Zjada razem                 ');
  
  FOR func IN funkcjeSuma
  LOOP
      DBMS_OUTPUT.PUT(LPAD(NVL( func.sumaDlaFunkcji, 0 ), 10));
  END LOOP;

  SELECT SUM(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0)) INTO liczba
  FROM Kocury;
  
  DBMS_OUTPUT.PUT_LINE(LPAD(liczba, 10));
END;
-- ZAD 43 test
DECLARE
  CURSOR plcie IS SELECT plec
                  FROM Kocury
			      GROUP BY plec
                  ORDER BY plec;
                  
  CURSOR bandy IS SELECT nazwa, nr_bandy
				  FROM Bandy
                  WHERE szef_bandy IS NOT NULL
                  ORDER BY nazwa;
                  
  CURSOR funkcjeSuma IS SELECT funkcja, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) sumaDlaFunkcji
						FROM Kocury
                        GROUP BY funkcja
                        ORDER BY funkcja;
  
  CURSOR bandyFunkcjePlcie IS SELECT SUM(NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) sumaDlaBandyPlciFunkcji, Ban.nazwa, Koc.plec, Koc.funkcja,
							  (SELECT COUNT(*)
                                FROM Kocury Koc2,Bandy Ban2
                                WHERE Ban.nazwa = Ban2.nazwa AND Koc.plec = Koc2.plec AND Koc2.nr_bandy = Ban2.nr_bandy
                                GROUP BY Ban2.nazwa, Koc2.plec) iloscDlaBandyPlci, 
							  (SELECT SUM(NVL(Koc3.przydzial_myszy, 0) + NVL(Koc3.myszy_extra, 0))
                                FROM Kocury Koc3, Bandy Ban3
                                WHERE Ban.nazwa = Ban3.nazwa AND Koc.plec = Koc3.plec AND Koc3.nr_bandy = Ban3.nr_bandy
                                GROUP BY Ban3.nazwa, Koc3.plec) sumaDlaBandyPlci
							  FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
							  GROUP BY Ban.nazwa, Koc.plec, Koc.funkcja
							  ORDER BY Ban.nazwa, Koc.plec , Koc.funkcja;
							  
  liczba NUMBER;
  bfp bandyFunkcjePlcie%ROWTYPE;
BEGIN
  DBMS_OUTPUT.PUT('NAZWA BANDY       PLEC   ILE ');
  FOR func IN funkcjeSuma
  LOOP
    DBMS_OUTPUT.PUT(LPAD(func.funkcja, 10));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(LPAD('SUMA', 10));
  DBMS_OUTPUT.PUT('---------------   ------ --- ');

  FOR func IN funkcjeSuma
  LOOP
    DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');

  OPEN bandyFunkcjePlcie;
  FETCH bandyFunkcjePlcie INTO bfp;
  
  FOR banda IN bandy 
  LOOP
    FOR plecElem IN plcie 
	LOOP
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN RPAD( banda.nazwa, 18 ) ELSE  RPAD( ' ', 18 ) END);
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN 'Kotka' ELSE 'Kocor' END);

        DBMS_OUTPUT.PUT(LPAD(bfp.iloscDlaBandyPlci, 4));
        DBMS_OUTPUT.PUT(' ');
        liczba := bfp.sumaDlaBandyPlci;
        FOR func IN funkcjeSuma 
		LOOP
          IF func.funkcja = bfp.funkcja AND banda.nazwa = bfp.nazwa AND plecElem.plec = bfp.plec THEN 
              DBMS_OUTPUT.PUT(LPAD(NVL(bfp.sumaDlaBandyPlciFunkcji, 0), 10));
              FETCH bandyFunkcjePlcie INTO bfp;
          ELSE
              DBMS_OUTPUT.PUT(LPAD(NVL(0, 0), 10));
          END IF;
        END LOOP;

        DBMS_OUTPUT.PUT(LPAD(NVL( liczba, 0 ), 10 ));
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
  END LOOP;
  CLOSE bandyFunkcjePlcie;

  DBMS_OUTPUT.PUT('Z---------------- ------ --- ');
  FOR func IN funkcjeSuma
  LOOP 
    DBMS_OUTPUT.PUT(' ---------'); 
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');

  DBMS_OUTPUT.PUT('Zjada razem                 ');
  
  FOR func IN funkcjeSuma
  LOOP
      DBMS_OUTPUT.PUT(LPAD(NVL( func.sumaDlaFunkcji, 0 ), 10));
  END LOOP;

  SELECT SUM(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0)) INTO liczba
  FROM Kocury;
  
  DBMS_OUTPUT.PUT_LINE(LPAD(liczba, 10));
END;

-- ZAD 43

DECLARE
    CURSOR kursorFunkcje IS (SELECT funkcja
					   FROM funkcje);
    liczba NUMBER;
BEGIN
  DBMS_OUTPUT.PUT('NAZWA BANDY       PLEC   ILE ');
  FOR func IN kursorFunkcje
  LOOP
    DBMS_OUTPUT.PUT(LPAD(func.funkcja, 10));
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(LPAD('SUMA', 10));
  DBMS_OUTPUT.PUT('---------------   ------ --- ');

  FOR func IN kursorFunkcje 
  LOOP
    DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');

  FOR banda IN (SELECT nazwa, nr_bandy
				FROM Bandy) 
  LOOP
    FOR plecElem IN (SELECT plec
				     FROM Kocury
			         GROUP BY plec
                     ORDER BY plec) 
	LOOP
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN RPAD( banda.nazwa, 18 ) ELSE  RPAD( ' ', 18 ) END);
        DBMS_OUTPUT.PUT(CASE WHEN plecElem.plec = 'D' THEN 'Kotka' ELSE 'Kocor' END);

        SELECT COUNT(pseudo) INTO liczba
		FROM Kocury 
		WHERE Kocury.nr_bandy = banda.nr_bandy AND Kocury.plec = plecElem.plec;
        DBMS_OUTPUT.PUT(LPAD(liczba, 4));
        DBMS_OUTPUT.PUT(' ');
        
        FOR fun IN kursorFunkcje LOOP
          SELECT SUM(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0)) INTO liczba 
		  FROM Kocury Koc
          WHERE Koc.plec=plecElem.plec AND Koc.funkcja=fun.funkcja AND Koc.nr_bandy=banda.nr_bandy;
          DBMS_OUTPUT.PUT(LPAD(NVL( liczba, 0 ), 10 ));
        END LOOP;

        SELECT SUM(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0)) INTO liczba
		FROM Kocury Koc2 
		WHERE Koc2.nr_bandy=banda.nr_bandy AND plecElem.plec=Koc2.plec;
        DBMS_OUTPUT.PUT(LPAD(NVL( liczba, 0 ), 10 ));
        DBMS_OUTPUT.NEW_LINE();
    END LOOP;
  END LOOP;
  DBMS_OUTPUT.PUT('----------------- ------ --- ');
  FOR func IN kursorFunkcje
  LOOP 
    DBMS_OUTPUT.PUT(' ---------'); 
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');

  DBMS_OUTPUT.PUT('Zjada razem                 ');
  FOR func IN kursorFunkcje LOOP
      SELECT SUM(NVL( przydzial_myszy, 0 )+NVL( myszy_extra, 0 )) INTO liczba
	  FROM Kocury Koc3
	  WHERE Koc3.funkcja = func.funkcja;
      DBMS_OUTPUT.PUT(LPAD(NVL( liczba, 0 ), 10));
  END LOOP;

  SELECT SUM(NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0)) INTO liczba
  FROM Kocury;
  
  DBMS_OUTPUT.PUT_LINE(LPAD(liczba, 10));
END;

-- ZAD 44


CREATE OR REPLACE PACKAGE podatekPackage AS
  FUNCTION policzPodatek(pseudoParam Kocury.pseudo%TYPE) RETURN NUMBER;
  PROCEDURE dodanieBandy(nrBandy Bandy.nr_bandy%TYPE,
					     nazwaBandy Bandy.nazwa%TYPE,
					     terenBandy Bandy.teren%TYPE);
END podatekPackage;

CREATE OR REPLACE PACKAGE BODY podatekPackage AS
  FUNCTION policzPodatek (pseudoParam Kocury.pseudo%TYPE) RETURN NUMBER IS
    podatek NUMBER DEFAULT 0;
    ile NUMBER DEFAULT 0;
  BEGIN
    SELECT CEIL(0.05*(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) INTO podatek
    FROM Kocury
    WHERE pseudoParam = pseudo;
  
    SELECT COUNT(pseudo) INTO ile
    FROM Kocury
    WHERE szef = pseudoParam;
    IF ile <= 0 THEN 
  	    podatek := podatek + 2; 
    END IF;
    
    SELECT COUNT(pseudo) INTO ile
    FROM Wrogowie_kocurow 
    WHERE pseudo = pseudoParam;
    IF ile <= 0 THEN
        podatek := podatek + 1;
    END IF;
    
    SELECT COUNT(pseudo) INTO ile
    FROM Kocury 
    WHERE pseudoParam=pseudo AND plec='D';
    IF ile > 0 THEN
  	    podatek := podatek + 1; 
    END IF;
    RETURN podatek;
  END;

  PROCEDURE dodanieBandy(
    nrBandy Bandy.nr_bandy%TYPE,
    nazwaBandy Bandy.nazwa%TYPE,
    terenBandy Bandy.teren%TYPE) IS
    
    blad VARCHAR2(100) := '';
    ileTakichBand NUMBER := 0;
    ujemna EXCEPTION;
    istnieje EXCEPTION;
  BEGIN
  
    IF nrBandy <= 0 THEN RAISE ujemna;
    END IF;
  
    SELECT COUNT(nr_bandy) INTO ileTakichBand 
    FROM Bandy 
    WHERE nr_bandy = nrBandy;
    IF ileTakichBand > 0 THEN 
  	    blad := TO_CHAR(nrBandy); 
    END IF;
  
    SELECT COUNT(nazwa) INTO ileTakichBand 
    FROM Bandy 
    WHERE nazwaBandy = nazwa;
    IF ileTakichBand > 0 THEN
        IF LENGTH(blad) > 0 THEN 
  		    blad:= blad || ', ' || nazwaBandy;
        ELSE blad := nazwaBandy;
        END IF;
    END IF;
  	
    SELECT COUNT(teren) INTO ileTakichBand
    FROM Bandy 
    WHERE terenBandy = teren;
    IF ileTakichBand > 0 THEN
        IF LENGTH(blad) > 0 THEN
  		    blad := blad || ', ' || terenBandy;
        ELSE 
  	        blad := terenBandy;
        END IF;
    END IF;
  
    IF LENGTH(blad) > 0 THEN RAISE istnieje; 
    END IF;
  
    INSERT INTO Bandy(nr_bandy, nazwa, teren) VALUES (nrBandy, nazwaBandy, terenBandy);
  
    EXCEPTION
    WHEN ujemna THEN DBMS_OUTPUT.PUT_LINE('Liczba musi byc dodatnia');
    WHEN istnieje THEN DBMS_OUTPUT.PUT_LINE( blad || ' : juz istnieje');
  END;
END;

BEGIN
  DBMS_OUTPUT.PUT(RPAD('PSEUDO',10));
  DBMS_OUTPUT.PUT_LINE(LPAD('PODATKEK',10));
  DBMS_OUTPUT.PUT_LINE('--------------------');
  FOR kocur IN (SELECT pseudo FROM Kocury) 
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kocur.pseudo,10) || LPAD(podatekPackage.policzPodatek(kocur.pseudo), 10));
  END LOOP;
END;

DROP PACKAGE podatekPackage;

-- ZAD 45

CREATE TABLE Dodatki_extra(
  dod_id NUMBER(2) GENERATED BY DEFAULT ON NULL AS IDENTITY CONSTRAINT dod_pk_id PRIMARY KEY,
  pseudo VARCHAR2(15) CONSTRAINT dod_pseudo REFERENCES Kocury(pseudo),
  dod_extra NUMBER(3) NOT NULL
);
DROP TABLE Dodatki_extra;

CREATE OR REPLACE TRIGGER sprawdzDodanieMilus
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
  CURSOR milusie IS SELECT pseudo
					FROM Kocury 
					WHERE funkcja='MILUSIA';
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF :NEW.funkcja = 'MILUSIA' AND :NEW.przydzial_myszy > :OLD.przydzial_myszy AND LOGIN_USER != 'TYGRYS' THEN
      FOR milusia IN milusie
      LOOP  
        INSERT INTO Dodatki_extra(pseudo, dod_extra) VALUES ( milusia.pseudo, -10)  ;
      END LOOP;
      COMMIT;
  END IF;
END;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 10
WHERE funkcja = 'MILUSIA';

ROLLBACK;
DROP TRIGGER sprawdzDodanieMilus;

-- ZAD 46

CREATE TABLE Podejrzane_zmiany (
  zm_id NUMBER(2) GENERATED BY DEFAULT ON NULL AS IDENTITY CONSTRAINT zm_pk_id PRIMARY KEY,
  kto VARCHAR2(15) NOT NULL,
  kiedy DATE NOT NULL,
  komu VARCHAR2(15) CONSTRAINT komu_pseudo REFERENCES Kocury(pseudo),
  jakaOperacja VARCHAR2(15) NOT NULL
);

CREATE OR REPLACE TRIGGER sprawdzPrzydzialy
BEFORE UPDATE ON Kocury
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  maxMyszy NUMBER DEFAULT 0;
  minMyszy NUMBER DEFAULT 0;
  ktoT VARCHAR2(15) DEFAULT  ' ';
  komuT VARCHAR2(15) DEFAULT  ' ';
  operacjaT VARCHAR2(15) DEFAULT  'INSERT';
BEGIN
  SELECT max_myszy, min_myszy INTO maxMyszy, minMyszy 
  FROM Funkcje 
  WHERE funkcja = :NEW.funkcja;

  IF :NEW.przydzial_myszy > maxMyszy OR :NEW.przydzial_myszy < minMyszy THEN
      IF UPDATING THEN 
		  operacjaT := 'UPDATE';
	  END IF;
      
      ktoT := LOGIN_USER;
	  komuT := :NEW.pseudo;
	  
      INSERT INTO Podejrzane_zmiany(kto, kiedy, komu, jakaOperacja) VALUES (ktoT, SYSDATE, komuT, operacjaT);
      COMMIT;
	  RAISE_APPLICATION_ERROR(-9876, 'przydzial nieprawidlowy');
  END IF;
END;

UPDATE Kocury
SET przydzial_myszy = 59 --60-70
WHERE pseudo='PLACEK';

SELECT * FROM Podejrzane_zmiany;
ROLLBACK;
DROP TRIGGER sprawdzPrzydzialy;
DROP TABLE Podejrzane_zmiany;