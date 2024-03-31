## Funkcionálny projekt pre predmet FLP@FIT VUT, 2024
## Autor: Sabína Gulčíková, xgulci00

### Popis
Program, ktory spracováva rozhodovacie stromy a dáta. Tieto dáta buď klasifikuje na základe 
zadaného stromu, alebo na základe nich natrénuje rozhodovací strom.

### Podúloha 1: Načítanie rozhodovacieho stromu a klasifikácia
**spustenie:**
`> make`
`> ./flp-fun -1 <data_obsahujuce_strom> <data_obsahujuce_data_na_klasifikaciu>`

**príklad vstupu:**
strom:
```text
Node: 0, 5.5
   Leaf: TridaA
   Node: 1, 3.0
       Leaf: TridaB
       Leaf: TridaC
```

data:
```text
2.4,1.3
6.1,0.3
6.3,4.4
```

**príklad výstupu:**
```text
TridaA
TridaB
TridaC
```

### Podúloha 2: Trénovanie rozhodovacieho stromu

**spustenie:**
`> make`
`> ./flp-fun -2 <data_obsahujuce_trenovacie_data>`

**príklad vstupu:**
```text
2.4,1.3,TridaA
6.1,0.3,TridaB
6.3,4.4,TridaC
2.9,4.4,TridaA
3.1,2.9,TridaB
.
.
.
```

### Detail implementácie podúlohy 2
Implementácia trénovania je inšpirovaná metódou CART. Na počiatku je do koreňového uzla uložený celý dataset.
Je vypočítaná jeho gini hodnota. Dataset je zoradený podľa atribútu na indexe aktuálnej hĺbky v strome. Pri koreňovom
uzle teda radíme podľa prvého (nultého) atribútu. Nasledne zoradené dáta delíme do dvoch skupín a počítame gini hodnotu
oboch skupín. Hodnotu následne váhovane priemerujeme, a porovnávame s gini hodnoutou predka. 
Pokiaľ žiadna z hodnôt menšia nie je, rozdeľovanie ukončíme, a uzol nahradíme triedou, ktorá je najviac zastúpená v danej podmnožine datasetu. 
Pokiaľ sa nám podarí identifikovať rozdelenie s najmenšou možnou gini hodnotou, algoritmus delenia rekurzívne voláme na rozdelené podčasti, 
radíme podľa atribútu na indexe o jedna vyššom, a porovnávame s našou gini hodnotou. Ako threshold aktuálneho uzla volíme priemer najvyššej hodnoty
radeného atribútu v ľavej skupine a najnižšej hodnoty radeného atribútu v pravej skupine.

Pokiaľ hĺbka stromu presiahne počet atribútov, daná podmnožina datasetu sa ďalej nedelí, uzol je nahradný labelom ktorý
reprezentuje triedu, ktorá je v pozostalých dátach najviac zastúpená.

### Známe obmedzenia
- Strom definovaný v prvej časti úlohy musí byť odsadený vždy párnym počtom medzier, nie tabov. 