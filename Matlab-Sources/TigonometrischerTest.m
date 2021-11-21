clc
clear

syms alpha real
syms L real
syms R real
syms S real

h = ( R + L ) * sin( alpha );
d = ( R + L ) * cos( alpha ) - R;
H = sqrt( h^2 + ( S - R - d )^2 );

x = simplify( L * tan( asin( h / H ) ) );

x = subs( x, 'alpha', ( 28.136746041614316 - 23.44 ) / 180.0 * pi );
x = subs( x, 'L', 1.5 );
x = subs( x, 'R', 6371000.8 );
x = subs( x, 'S', 149597870700.0 );

eval( x )

