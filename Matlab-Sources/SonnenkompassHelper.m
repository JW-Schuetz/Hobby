clc
clear

syms omega real
syms psi   real

a = simplify( cos( omega - psi ) * sin( pi/2 - ( omega - psi ) ) );
b = simplify( sin( omega - psi ) * cos( pi/2 - ( omega - psi ) ) );
simplify( a + b )

a = simplify( -sin( omega - psi ) * sin( pi/2 - ( omega - psi ) ) );
b = simplify( cos( omega - psi ) * cos( pi/2 - ( omega - psi ) ) );
simplify( a + b )