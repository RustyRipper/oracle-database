-- ZAD 17

SELECT pseudo "POLUJE W POLU", przydzial_myszy "PRZYDZIAL MYSZY", nazwa "BANDY"
FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE przydzial_myszy > 50 AND (teren ='POLE' OR teren = 'CALOSC');

-- ZAD 18

SELECT Koc.imie, TO_CHAR(Koc.w_stadku_od, 'YYYY-MM-DD') "POLUJE OD"
FROM Kocury Koc, Kocury Koc2
WHERE Koc2.imie = 'JACEK' AND Koc.w_stadku_od < Koc2.w_stadku_od
ORDER BY Koc.w_stadku_od DESC;

-- ZAD 19
-- a)
SELECT Koc.imie "Imie",' | ' " ", Koc.funkcja "Funkcja",' | ' " ", NVL(Koc2.imie, ' ') "Szef 1",
    ' | ' " ", NVL(Koc3.imie, ' ') "Szef 2",' | ' " ", NVL(Koc4.imie, ' ') "Szef 3"
FROM Kocury Koc LEFT JOIN Kocury Koc2 ON Koc.szef = Koc2.pseudo
                LEFT JOIN Kocury Koc3 ON Koc2.szef = Koc3.pseudo
                LEFT JOIN Kocury Koc4 ON Koc3.szef = Koc4.pseudo
WHERE Koc.funkcja IN ('MILUSIA', 'KOT');

-- b)
SELECT imie_kota "Imie",' | ' " ", fun "Funkcja",' | ' " ", NVL(imie_szef1, ' ') "Szef 1",
    ' | ' " ", NVL(imie_szef2, ' ') "Szef 2",' | ' " ", NVL(imie_szef3, ' ') "Szef 3"
FROM (
    SELECT CONNECT_BY_ROOT imie imie_kota, imie, CONNECT_BY_ROOT funkcja fun, level lvl
    FROM Kocury
    CONNECT BY PRIOR szef = pseudo
    START WITH funkcja IN ('KOT', 'MILUSIA'))
PIVOT (MAX(imie) FOR lvl IN (2 imie_szef1, 3 imie_szef2, 4 imie_szef3));

    SELECT CONNECT_BY_ROOT imie imie_kota, imie, CONNECT_BY_ROOT funkcja fun, level lvl
    FROM Kocury
    CONNECT BY PRIOR szef = pseudo
    START WITH funkcja IN ('KOT', 'MILUSIA');
-- c)

SELECT imie_kota "Imie" ,' | ' " ", fun "Funkcja", SUBSTR(MAX(szefowie), 14) "Imiona kolejnych szefów"
FROM (
    SELECT CONNECT_BY_ROOT imie imie_kota, CONNECT_BY_ROOT funkcja fun, 
        SYS_CONNECT_BY_PATH(RPAD(imie, 10), ' | ') || ' |' szefowie
    FROM Kocury
    CONNECT BY pseudo = PRIOR szef
    START WITH funkcja IN ('KOT', 'MILUSIA'))
GROUP BY imie_kota, fun;
    
    
-- ZAD 20

SELECT imie "Imie kotki", nazwa "Nazwa bandy", imie_wroga "Imie Wroga",
    stopien_wrogosci "Ocena wroga", TO_CHAR(data_incydentu, 'YYYY-MM-DD') "Data inc."
FROM Kocury NATURAL JOIN Wrogowie_kocurow NATURAL JOIN Bandy NATURAL JOIN Wrogowie
WHERE data_incydentu > '2007-01-01' AND plec='D';

-- ZAD 21

SELECT nazwa "Nazwa bandy", COUNT(DISTINCT pseudo) "Koty z wrogami"
FROM Kocury
    NATURAL JOIN Bandy
    NATURAL JOIN Wrogowie_kocurow
GROUP BY nazwa;

-- ZAD 22

SELECT funkcja "Funkcja", pseudo "Pseudonim kota", COUNT(pseudo) "Liczba wrogow"
FROM Kocury
    NATURAL JOIN Wrogowie_kocurow
GROUP BY pseudo, funkcja
HAVING COUNT(pseudo) > 1;

-- ZAD 23
SELECT *
FROM (
    SELECT imie, NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
    FROM Kocury
    WHERE NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 > 864 AND myszy_extra IS NOT NULL
    UNION
    SELECT imie, NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 "DAWKA ROCZNA", '        864' "DAWKA"
    FROM Kocury
    WHERE NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 = 864 AND myszy_extra IS NOT NULL
    UNION
    SELECT imie, NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
    FROM Kocury
    WHERE NVL(przydzial_myszy, 0)*12 + NVL(myszy_extra, 0)*12 < 864 AND myszy_extra IS NOT NULL)
ORDER BY "DAWKA ROCZNA" DESC;

-- ZAD 24

SELECT Bandy.nr_bandy "NR BANDY", nazwa, teren
FROM Bandy
    LEFT JOIN Kocury ON Bandy.nr_bandy = Kocury.nr_bandy
WHERE Kocury.pseudo IS NULL;    

    
SELECT nr_bandy "NR BANDY", nazwa, teren
FROM Bandy
    NATURAL JOIN (SELECT nr_bandy
                  FROM Bandy
                  MINUS
                  SELECT nr_bandy
                  FROM Kocury);
                                   
-- ZAD 25          

SELECT imie, funkcja, NVL(przydzial_myszy, 0) "PRZYDZIAL MYSZY"
FROM Kocury 
WHERE NVL(przydzial_myszy, 0) >= 3 * (
      SELECT NVL(przydzial_myszy, 0)
      FROM ( SELECT * 
             FROM Kocury ORDER BY przydzial_myszy DESC
            )
        LEFT JOIN Bandy USING(nr_bandy)
      WHERE funkcja = 'MILUSIA'  AND teren in ('CALOSC','SAD') AND ROWNUM =1);
 
-- ZAD 26      
                    
SELECT funkcja "Funkcja", ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "Srednio najw. i najm. myszy"
FROM Kocury
WHERE funkcja <> 'SZEFUNIO'
GROUP BY funkcja
HAVING ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) IN (
    (
        SELECT MAX(ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))))
        FROM Kocury
        WHERE funkcja <> 'SZEFUNIO'
        GROUP BY funkcja
    ),
    (
        SELECT MIN(ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))))
        FROM Kocury
        WHERE Funkcja <> 'SZEFUNIO'
        GROUP BY funkcja
    )
);

-- ZAD 27
-- a)
SELECT pseudo, (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) "ZJADA"
FROM Kocury Koc
WHERE &n > (
    SELECT COUNT(DISTINCT (NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0)))
    FROM Kocury Koc2
    WHERE ((NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) < (NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0))))
ORDER BY (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) DESC;

-- b)
SELECT pseudo, (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) "ZJADA"
FROM Kocury Koc
WHERE (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) IN
    (
    SELECT *
    FROM (
        SELECT DISTINCT (NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0)) cal_przy  
        FROM Kocury Koc2
        ORDER BY cal_przy DESC)
    WHERE ROWNUM <= &n
    );
    
-- c)
SELECT Koc.pseudo, MAX(NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) "ZJADA", Koc.w_stadku_od
FROM Kocury Koc, Kocury Koc2 
WHERE (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) <= (NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0))
GROUP BY Koc.pseudo, Koc.w_stadku_od
HAVING COUNT(DISTINCT (NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0))) <= &n
ORDER BY MAX(NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) DESC;

-- d)
SELECT pseudo, cal_przy "ZJADA"
FROM (
    SELECT pseudo, (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) cal_przy, 
        DENSE_RANK() OVER (
            ORDER BY(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) DESC) num
    FROM Kocury)
WHERE &n >= num;

-- ZAD 28
                
SELECT TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK", COUNT(pseudo) "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING COUNT(pseudo) IN (
    (
        SELECT MIN(liczba)
        FROM (
            SELECT DISTINCT COUNT(pseudo)liczba
            FROM Kocury
            GROUP BY EXTRACT(YEAR FROM w_stadku_od)
            HAVING COUNT(pseudo) > (
                SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                FROM Kocury
                GROUP BY EXTRACT(YEAR FROM w_stadku_od)
            )         
        )

    ),
    (
        SELECT MAX(liczba2)
        FROM (
            SELECT DISTINCT COUNT(pseudo)liczba2
            FROM Kocury
            GROUP BY EXTRACT(YEAR FROM w_stadku_od)
            HAVING COUNT(pseudo) < (
                SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od)))
                FROM Kocury
                GROUP BY EXTRACT(YEAR FROM w_stadku_od)
            )
        )
    )
)
UNION ALL
SELECT 'Srednia', ROUND(AVG(COUNT(pseudo)),7)
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
ORDER BY "LICZBA WSTAPIEN" ;

-- ZAD 29

-- a)
SELECT Koc.imie, MIN(NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) "ZJADA",
    Koc.nr_bandy "NR BANDY", LPAD(TO_CHAR(AVG(NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0)), '00.00'), 10) "SREDNIA BANDY"
FROM Kocury Koc JOIN Kocury Koc2 ON Koc.nr_bandy = Koc2.nr_bandy
WHERE Koc.plec='M'
GROUP BY Koc.imie, Koc.nr_bandy
HAVING MIN(NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0))<= 
    AVG(NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0));

-- b)
SELECT imie, (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) "ZJADA", nr_bandy, LPAD(TO_CHAR(srednia_bandy, '00.00'), 10) "SREDNIA BANDY"
FROM (
    SELECT nr_bandy, AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) srednia_bandy
    FROM Kocury 
    GROUP BY nr_bandy
  )JOIN Kocury USING (nr_bandy)
WHERE srednia_bandy >= (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))  AND plec='M';

-- c)
SELECT Koc.imie, (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) "ZJADA" , Koc.nr_bandy,
    LPAD(TO_CHAR((   SELECT AVG(NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0))
        FROM Kocury Koc2
        WHERE Koc.nr_bandy=Koc2.nr_bandy),'00.00'), 10)  "SREDNIA BANDY"
FROM Kocury Koc
WHERE plec='M' AND (NVL(Koc.przydzial_myszy, 0) + NVL(Koc.myszy_extra, 0)) <= 
    (   SELECT AVG(NVL(Koc2.przydzial_myszy, 0) + NVL(Koc2.myszy_extra, 0)) "SREDNIA BANDY"
        FROM Kocury Koc2
        WHERE Koc.nr_bandy = Koc2.nr_bandy);
        
-- ZAD 30

SELECT Koc.imie, TO_CHAR(Koc.w_stadku_od, 'YYYY-MM-DD') "WSTAPIL DO STADKA", '<--- NAJSTARSZY STAZEM W BANDZIE '|| nazwa " "
FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
WHERE w_stadku_od = (
    SELECT MAX(Koc2.w_stadku_od)
    FROM Kocury Koc2
    WHERE Koc.nr_bandy = Koc2.nr_bandy)
UNION All
SELECT Koc.imie, TO_CHAR(Koc.w_stadku_od, 'YYYY-MM-DD')  "WSTAPIL DO STADKA", '<--- NAJMLODSZY STAZEM W BANDZIE '|| nazwa " "
FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
WHERE Koc.w_stadku_od = (
    SELECT MIN(Koc2.w_stadku_od)
    FROM Kocury Koc2
    WHERE Koc.nr_bandy = Koc2.nr_bandy)
UNION All
SELECT Koc.imie, TO_CHAR(Koc.w_stadku_od, 'YYYY-MM-DD')  "WSTAPIL DO STADKA", ' ' " "
FROM Kocury Koc
WHERE Koc.w_stadku_od != (
    SELECT MIN(Koc2.w_stadku_od)
    FROM Kocury Koc2
    WHERE Koc.nr_bandy = Koc2.nr_bandy
    ) AND w_stadku_od != (
        SELECT MAX(Koc2.w_stadku_od)
        FROM Kocury Koc2
        WHERE Koc.nr_bandy = Koc2.nr_bandy);
        
-- ZAD 31

CREATE VIEW Perspektywa31 (nazwa_bandy, sre_spoz, max_spoz ,min_spoz, koty, koty_z_dod)
  AS
  SELECT Ban.nazwa, AVG(NVL(Koc.przydzial_myszy, 0)), MAX(NVL(Koc.przydzial_myszy, 0)),
    MIN(NVL(Koc.przydzial_myszy, 0)), COUNT(Koc.pseudo), COUNT(NVL(Koc.myszy_extra, 0))
  FROM Bandy Ban LEFT JOIN Kocury Koc ON Ban.nr_bandy = Koc.nr_bandy
  GROUP BY Ban.nazwa
  HAVING COUNT(Koc.pseudo) > 0;

SELECT *
FROM Perspektywa31;

SELECT Koc.pseudo "PSEUDONIM", Koc.imie, Koc.funkcja, NVL(Koc.przydzial_myszy, 0) "ZJADA",
    'OD ' || P31.min_spoz || ' DO  ' || P31.max_spoz "GRANICE SPOZYCIA",
    TO_CHAR(Koc.w_stadku_od, 'YYYY-MM-DD') "LOWI OD"
FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
    LEFT JOIN Perspektywa31 P31 ON Ban.nazwa = P31.nazwa_bandy
WHERE Koc.pseudo = '&pseudonim';

-- ZAD 32
-- przed
SELECT pseudo "Pseudonim", plec "Plec", NVL(przydzial_myszy, 0) "Myszy przed podw.", NVL(myszy_extra, 0) "Extra przed podw."
FROM Kocury LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE pseudo IN (
    SELECT * 
    FROM (
        SELECT pseudo
        FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
        WHERE Ban.nazwa = 'CZARNI RYCERZE'
        ORDER BY w_stadku_od)
    WHERE ROWNUM <= 3
    UNION ALL
    SELECT * 
    FROM (
        SELECT pseudo
        FROM Kocury Koc LEFT JOIN Bandy Ban ON Koc.nr_bandy = Ban.nr_bandy
        WHERE Ban.nazwa = 'LACIACI MYSLIWI'
        ORDER BY w_stadku_od)
    WHERE ROWNUM <= 3);
-- podwyzka
UPDATE Kocury
SET przydzial_myszy = CASE plec
    WHEN 'M' THEN NVL(przydzial_myszy, 0) + 10
    ELSE (NVL(przydzial_myszy, 0) + (
        SELECT MIN(NVL(Koc.przydzial_myszy, 0))
        FROM Kocury Koc) * 0.1) 
    END,
    myszy_extra = NVL(myszy_extra, 0) + FLOOR(
        (
            SELECT AVG(NVL(Koc2.myszy_extra, 0))
            FROM Kocury Koc2
            WHERE Kocury.nr_bandy = Koc2.nr_bandy) * 0.15)
    WHERE pseudo IN (
        SELECT *
        FROM (
            SELECT Koc3.pseudo
            FROM Kocury Koc3 LEFT JOIN Bandy Ban ON Koc3.nr_bandy = Ban.nr_bandy
            WHERE Ban.nazwa = 'CZARNI RYCERZE'
            ORDER BY Koc3.w_stadku_od)
        WHERE ROWNUM <= 3
        UNION ALL
    
        SELECT *
        FROM (
            SELECT Koc4.pseudo
            FROM Kocury Koc4 LEFT JOIN Bandy Ban2 ON Koc4.nr_bandy = Ban2.nr_bandy
            WHERE Ban2.nazwa = 'LACIACI MYSLIWI'
            ORDER BY Koc4.w_stadku_od)
        WHERE ROWNUM <= 3);
        
ROLLBACK;       
SELECT NVL(Koc2.myszy_extra, 0), Ban.nazwa, Ban.nr_bandy, Koc2.pseudo
FROM Kocury Koc2 LEFT JOIN Bandy Ban ON Koc2.nr_bandy = Ban.nr_bandy;

-- ZAD 33
-- a)
SELECT *
FROM (
    SELECT DECODE(plec, 'D', nazwa, ' ') "NAZWA BANDY", 
        TO_CHAR(DECODE(PLEC, 'D', 'Kotka', 'Kocor')) plec,
        LPAD(TO_CHAR(COUNT(pseudo)),4) ile,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) szefunio,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) bandzior,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY',   NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) lowczy,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ',   NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) lapacz,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'KOT',      NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) kot,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA',  NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) milusia,
        LPAD(TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) dzielczy,
        LPAD(TO_CHAR(SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra, 0))),7) suma
FROM Kocury NATURAL JOIN Bandy
GROUP BY nazwa, plec
ORDER BY nazwa)

UNION ALL

SELECT 'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
FROM DUAL

UNION ALL

SELECT 'ZJADA RAZEM', ' ', ' ' ,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) szefunio,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) bandzior,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY',   NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) lowczy,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ',   NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) lapacz,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'KOT',      NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) kot,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA',  NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) milusia,
    LPAD(TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0)+NVL(myszy_extra, 0), 0))),9) dzielczy,
    LPAD(TO_CHAR(SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra, 0))),7) suma
FROM Kocury NATURAL JOIN Bandy;

-- b)
    
SELECT *
FROM (
    SELECT TO_CHAR(DECODE(plec, 'D', nazwa, ' ')) "NAZWA BANDY",
        TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocor')) plec,
        LPAD(TO_CHAR(ile), 4) ile,
        LPAD(TO_CHAR(NVL(szefunio, 0)), 9) szefunio,
        LPAD(TO_CHAR(NVL(bandzior,0)), 9) bandzior,
        LPAD(TO_CHAR(NVL(lowczy,0)), 9) lowczy,
        LPAD(TO_CHAR(NVL(lapacz,0)), 9) lapacz,
        LPAD(TO_CHAR(NVL(kot,0)), 9) kot,
        LPAD(TO_CHAR(NVL(milusia,0)), 9) milusia,
        LPAD(TO_CHAR(NVL(dzielczy,0)), 9) dzielczy,
        LPAD(TO_CHAR(NVL(suma,0)), 7) suma
    FROM (
        SELECT nazwa, plec, funkcja, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) cal_przy
        FROM Kocury NATURAL JOIN Bandy)
    PIVOT (
        SUM(cal_przy) FOR funkcja IN (
            'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
            'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy))
    JOIN (
        SELECT nazwa nazwa_inside, plec plec_inside, COUNT(pseudo) ile, SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma
        FROM Kocury NATURAL JOIN Bandy 
        GROUP BY nazwa, plec
        ORDER BY nazwa ) 
    ON nazwa_inside = nazwa AND plec_inside = plec)

UNION ALL

SELECT 'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
FROM DUAL

UNION ALL

SELECT 'ZJADA RAZEM', ' ', ' ',
    LPAD(TO_CHAR(NVL(szefunio, 0)), 9) szefunio,
    LPAD(TO_CHAR(NVL(bandzior, 0)), 9) bandzior,
    LPAD(TO_CHAR(NVL(lowczy, 0)), 9) lowczy,
    LPAD(TO_CHAR(NVL(lapacz, 0)), 9) lapacz,
    LPAD(TO_CHAR(NVL(kot, 0)), 9) kot,
    LPAD(TO_CHAR(NVL(milusia, 0)), 9) milusia,
    LPAD(TO_CHAR(NVL(dzielczy, 0)), 9) dzielczy,
    LPAD(TO_CHAR(NVL(suma, 0)), 7) suma
FROM (
    SELECT funkcja, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) cal_przy
    FROM Kocury NATURAL JOIN Bandy ) 
PIVOT (
    SUM(cal_przy) FOR funkcja IN (
        'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
        'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy)) 
CROSS JOIN (
    SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) suma
    FROM Kocury);
