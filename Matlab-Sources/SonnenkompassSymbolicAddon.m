clc
clear

syms alpha real
syms lS real
syms rE real
syms s real
syms c real

load( 'SonnenkompassSymbolic.mat', 'omegaS' )

z = simplify( lS * rE * omegaS );

% kein Nenner
[ z, n ] = numden( z );
if( n ~= 1 )
    error( 'Nenner muss gleich 1 sein!' )
end

% die Terme mit sin(alpha) zusammenfassen
z = collect( z, sin( alpha ) );

% die Terme mit cos(alpha) zusammenfassen
z = collect( z, cos( alpha ) );

% sin/cos(alpha) substituieren
z = subs( z, sin( alpha ), s );
z = subs( z, cos( alpha ), c );

% Koeffizienten von sA, cA und dem konstanten Term finden
A = simplify( coeffs( z, s ) ); A = A( 2 );
B = simplify( coeffs( z, c ) ); B = B( 2 );
C = simplify( z - A * s - B * c );

% Kontrolle
probe = simplify( lS * rE * omegaS - A * sin( alpha ) - ...
                  B * cos( alpha ) - C );
if( probe ~= 0 )
    error( 'Probe gescheitert!' )
end