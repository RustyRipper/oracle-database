-- ZAD1
SELECT imie_wroga "WROG", opis_incydentu "PRZEWINA"
FROM Wrogowie_kocurow
WHERE data_incydentu >= '2009-01-01' AND data_incydentu < '2010-01-01';

-- ZAD2
SELECT imie, funkcja, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "Z NAMI OD"
FROM Kocury
WHERE plec = 'D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

-- ZAD3
SELECT imie_wroga "WROG", gatunek, stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

-- ZAD4
SELECT imie || ' zwany ' || pseudo  || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo;

-- ZAD5
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'L', '%', 1, 1), 'A', '#', 1, 1) "Po wymianie A an # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

-- ZAD6 
SELECT imie, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "W stadku", ROUND(NVL(przydzial_myszy,0) / 1.1 ) "Zjadal", TO_CHAR(ADD_MONTHS(w_stadku_od, 6), 'YYYY-MM-DD') "Podwyzka", NVL(przydzial_myszy,0) "Zjada"
FROM Kocury
WHERE (MONTHS_BETWEEN(DATE '2022-07-14', w_stadku_od) / 12) > 13 AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9;
      
-- ZAD7
SELECT imie, NVL(przydzial_myszy,0) * 3 "MYSZY KWARTALNIE", NVL(myszy_extra, 0) * 3 "KWARTALNE DODATKI"
FROM Kocury
WHERE NVL(przydzial_myszy,0) > 2 * NVL(myszy_extra, 0) AND NVL(przydzial_myszy,0) >= 55;

-- ZAD8
SELECT imie,
    CASE
        WHEN (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 = 660
            THEN 'Limit'
        WHEN (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 < 660
            THEN 'Ponizej 660'
        ELSE TO_CHAR((NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12)
    END "Zjada rocznie"
FROM Kocury;

-- ZAD9
SELECT pseudo, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "W STADKU",
    CASE
        WHEN (EXTRACT(DAY FROM w_stadku_od) <= 15 AND NEXT_DAY(LAST_DAY(TO_DATE('2022-10-25')), 3) - 7 >= TO_DATE('2022-10-25'))
            THEN TO_CHAR(NEXT_DAY(LAST_DAY(TO_DATE('2022-10-25')), 3) - 7, 'YYYY-MM-DD')
        WHEN (EXTRACT(DAY FROM w_stadku_od) > 15 AND NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-25'), 1)), 3) - 7 >= TO_DATE('2022-10-25'))
            THEN TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-25'), 1)), 3) - 7, 'YYYY-MM-DD')
        ELSE TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-25'), 1)), 3) - 7, 'YYYY-MM-DD')
    END "WYPLATA"
FROM Kocury;

SELECT pseudo, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "W STADKU",
    CASE
        WHEN (EXTRACT(DAY FROM w_stadku_od) <= 15 AND NEXT_DAY(LAST_DAY(TO_DATE('2022-10-27')), 3) - 7 >= TO_DATE('2022-10-27'))
            THEN TO_CHAR(NEXT_DAY(LAST_DAY(TO_DATE('2022-10-27')), 3) - 7, 'YYYY-MM-DD')
        WHEN (EXTRACT(DAY FROM w_stadku_od) > 15 AND NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-27'), 1)), 3) - 7 >= TO_DATE('2022-10-27'))
            THEN TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-27'), 1)), 3) - 7, 'YYYY-MM-DD')
        ELSE TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2022-10-27'), 1)), 3) - 7, 'YYYY-MM-DD')
    END "WYPLATA"
FROM Kocury;

-- ZAD10
SELECT pseudo || ' - ' ||
    CASE COUNT(pseudo)
        WHEN 1 
            THEN 'Unikalny'
        ELSE
            'nieunikalny' 
    END "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;


SELECT szef || ' - ' ||
    CASE COUNT(szef)
        WHEN 1 
            THEN 'Unikalny'
        ELSE
            'nieunikalny' 
    END "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef;


-- ZAD11
SELECT pseudo "Pseudonim", COUNT(imie_wroga) "Liczba wrogow"
FROM Wrogowie_kocurow
GROUP BY pseudo
HAVING COUNT(imie_wroga)>=2;

-- ZAD12
SELECT 'Liczba kotow= ' " ", COUNT(pseudo) " ", 'lowi jako' " ",  funkcja " ", 'i zjada max.' " ", MAX(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) " ", 'myszy miesiecznie' " "
FROM Kocury
WHERE plec != 'M' AND funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) > 50;

-- ZAD13
SELECT nr_bandy "Nr bandy", plec "Plec", MIN( NVL(przydzial_myszy, 0)) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy, plec;

-- ZAD14
SELECT level "Poziom", pseudo "Pseudonim", funkcja "Funkcja", nr_bandy "Nr bandy"
FROM Kocury
WHERE plec  = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

-- ZAD15
SELECT LPAD(level - 1, (level - 1) * 4 + 1, '===>') || '                ' || imie "Hierarchia", NVL(szef, 'Sam sobie panem') "Pseudo szefa", funkcja "Funkcja"
FROM Kocury
WHERE myszy_extra is NOT NULL
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

-- ZAD16
SELECT LPAD(' ', (level - 1) * 4 ) || pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo AND pseudo <> 'RAFA'
START WITH (MONTHS_BETWEEN(DATE '2022-07-14', w_stadku_od) / 12) > 13
    AND plec = 'M'
    AND myszy_extra IS NULL
    AND pseudo <> 'RAFA' ;
