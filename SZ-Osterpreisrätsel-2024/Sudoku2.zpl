# Modell mit integer Optimierungsvariablen

# Für jedes Arrayelement <i,j> gibt es eine integer Variable 
# für die die Zahl k.

# Arraygrösse
param m := 7;
set I := { 1 .. m };

# Vordefinierte Arrayelemente
 set PREDEFINED := { <4,1,1>, <5,7,1>, <6,7,6>, <6,5,1> };

# Optimierungsvariablen
# x[i,j] definiert die Zahl an Stelle [i,j]
#
var x[I*I] integer >= 1 <= m;

# Nebenbedingung: Zahl darf in jeder Zeile und Spalte nur einmal vorkommen
subto columns :
	forall <i> in I do									# jede Zeile i
		forall <j> in I do								# jedes Element j diese Zeile i
			forall <k> in I with abs( k - j ) > 0 do	# jedes Element k diese Zeile i mit j != k
				abs( x[i,j] - x[i,k] ) >= 1;

subto rows :
	forall <j> in I do									# jede Spalte j
		forall <i> in I do								# jedes Element i diese Spalte j
			forall <p> in I with abs( p - i ) > 0 do	# jedes Element p diese Zeile i mit i != p
				abs( x[i,j] - x[p,j] ) >= 1;

# Nebenbedingung: Vordefinierte Einträge
subto known : forall <i,j,k> in PREDEFINED do
	x[i,j] == k;

# Ungleichungsnebenbedingungen
subto ungleichung1 : x[1,4] >= x[1,3];
subto ungleichung2 : x[1,6] >= x[1,5];

subto ungleichung3 : x[2,2] >= x[2,1];
subto ungleichung4 : x[2,4] >= x[2,3];
subto ungleichung5 : x[2,6] >= x[2,7];

subto ungleichung6 : x[6,2] >= x[6,3];
subto ungleichung7 : x[6,4] >= x[6,3];
subto ungleichung8 : x[6,6] >= x[6,5];

subto ungleichung9 :  x[2,7] >= x[3,7];
subto ungleichung10 : x[4,6] >= x[5,6];
subto ungleichung11 : x[5,3] >= x[4,3];
subto ungleichung12 : x[6,1] >= x[5,1];
subto ungleichung13 : x[6,3] >= x[5,3];
subto ungleichung14 : x[7,2] >= x[6,2];