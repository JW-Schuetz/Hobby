param datafile := "cap61.dat";
param NJ := read datafile as "1n" use 1;
param NI := read datafile as "2n" use 1;

set J := { 1 .. NJ };
set I := { 1 .. NI };
param s[J] := read datafile as "<1n> 2n" skip 1 use NJ;
param f[J] := read datafile as "<1n> 3n" skip 1 use NJ;

param d[I] := read datafile as "<1n> 2n" skip 1 + NJ use NI;

param c[J * I] := read datafile as "<1n,2n> 3n" skip 1 + NJ + NI;

var x[J * I] binary;
var y[J] binary;

minimize cost: sum <j,i> in J * I : c[j,i] * x[j,i]
            +  sum <j> in J : f[j] * y[j];

subto assign : forall <i> in I : sum <j> in J : x[j,i] == 1;

subto capacity : forall <j> in J : sum <i> in I : d[i] * x[j,i] <= s[j] * y[j];