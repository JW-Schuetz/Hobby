clc
clear

syms a real

syms A real
syms B real
syms C real

[ a, param, cond ] = solve( A * sin( a ) + B * cos( a ) + C == 0, a, ...
                            'Real', true, 'ReturnConditions', true );

a, param, cond

% Ausgabe diese Skripts:
% ======================
% a = 
%  2*atan((A - (A^2 + B^2 - C^2)^(1/2))/(B - C)) + 2*pi*k
%  2*atan((A + (A^2 + B^2 - C^2)^(1/2))/(B - C)) + 2*pi*k
%
% param =
% k
%
% cond =
%  C^2 <= A^2 + B^2 & B ~= C & in(k, 'integer')
%  C^2 <= A^2 + B^2 & B ~= C & in(k, 'integer')