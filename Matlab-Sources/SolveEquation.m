clc
clear

syms a real

syms A real
syms B real
syms C real

[ a, param, cond ] = solve( A * sin( a ) + B * cos( a ) + C == 0, a, ...
                            'Real', true, 'ReturnConditions', true );

a, param, cond