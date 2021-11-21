clc
clear

syms alpha real
syms lS real
syms rE real
syms sE real

h = ( rE + lS ) * sin( alpha );
d = ( rE + lS ) * cos( alpha ) - rE;
H = sqrt( h^2 + ( sE - rE - d )^2 );

x = simplify( lS * tan( asin( h / H ) ) );

x = subs( x, 'alpha', ( 28.136746041614316 - 23.44 ) / 180.0 * pi );
x = subs( x, 'lS', 1.5 );
x = subs( x, 'rE', 6371000.8 );
x = subs( x, 'sE', 149597870700.0 );

eval( x )