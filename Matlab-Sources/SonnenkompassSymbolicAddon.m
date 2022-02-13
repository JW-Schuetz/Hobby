clc
clear

syms alpha real
syms psi real
syms omega real
syms lS real
syms rE real
syms rS real
syms p1 real
syms p2 real
syms p3 real
syms s real
syms c real

load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'omegaS' )

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
    error( 'Probe A, B, C gescheitert!' )
end

% A, B, C

% Ausgabe dieses Skripts für A, B und C:
% ======================================
% A = p3*rS*sin(omega)*sin(psi) + p2*rS*cos(omega)*cos(psi) - 
%     p1*rS*cos(psi)*sin(omega)
% B = p3*rS*cos(omega)*cos(psi)*sin(psi) - p1*rS*cos(omega)*cos(psi)^2 - 
%     p2*rS*sin(omega)
% C = rE^2 - p1*rS*cos(omega) + p1*rS*cos(omega)*cos(psi)^2 - 
%     p3*rS*cos(omega)*cos(psi)*sin(psi)

% Kontrolle der Formeln in Sonnenkompass.lyx, p2 -> 0
A = subs( A, p2, 0 );
B = subs( B, p2, 0 );
C = subs( C, p2, 0 );

% Formeln aus Sonnenkompass.lyx
AS = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) * sin( omega );
BS = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) * cos( psi ) * cos( omega );
CS = rE^2 - rS * ( p1 * sin( psi )^2 + p3 * cos( psi ) * sin( psi ) ) * cos( omega );

probe = simplify( A - AS );
if( probe ~= 0 )
    error( 'LyX Probe A gescheitert!' )
end

probe = simplify( B - BS );
if( probe ~= 0 )
    error( 'LyX Probe B gescheitert!' )
end

probe = simplify( C - CS );
if( probe ~= 0 )
    error( 'LyX Probe C gescheitert!' )
end

% Kontrolle der Formeln des Anhanges in Sonnenkompass.lyx
xi  = subs( sAlpha, rS, 1 );	% xi ist: D_(-alpha) * s
dxi = diff( xi, alpha );        % Ableiten nach alpha

% Formeln aus Sonnenkompass.lyx
dxi1S = -cos( psi )^2 * sin( alpha ) * cos( omega ) + ...
         cos( psi ) * cos( alpha ) * sin( omega );
dxi2S = -cos( psi ) * cos( alpha ) * cos( omega ) - ...
         sin( alpha ) * sin( omega );
dxi3S =  cos( psi ) * sin( psi ) * sin( alpha ) * cos( omega ) - ...
         sin( psi ) * cos( alpha ) * sin( omega );

probe = simplify( dxi( 1 ) - dxi1S );
if( probe ~= 0 )
    error( 'LyX Probe dxi1 gescheitert!' )
end

probe = simplify( dxi( 2 ) - dxi2S );
if( probe ~= 0 )
    error( 'LyX Probe dxi2 gescheitert!' )
end

probe = simplify( dxi( 3 ) - dxi3S );
if( probe ~= 0 )
    error( 'LyX Probe dxi3 gescheitert!' )
end