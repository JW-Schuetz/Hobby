%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

syms omega real             % Jahreszeiteinfluss
syms thetaG real            % Geographische Breite des Stabes
syms psi real               % Komplementwinkel Erd-Rotationsachse zur Ekliptik
syms rS real                % Abstand Erde - Sonne
syms rE real                % Erdradius
syms lS real                % Stablänge
syms e [ 3, 1 ] real        % Einheitsvektor Rotationsachse
syms alpha real             % Erd-Rotationswinkel (2*pi/24h)
syms dAlpha [ 3, 3 ] real   % Drehmatrix
syms p [ 3, 1 ] real        % Fusspunkt des Stabes auf der Erdoberfläche und Stabende
syms s [ 3, 1 ] real        % Sonnenposition in Bezug zum Erdmittelpunkt

e( 1 ) = sin( psi );
e( 2 ) = 0;
e( 3 ) = cos( psi );

ca = cos( alpha );
sa = sin( alpha );

dAlpha( 1, 1 ) = e( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
dAlpha( 2, 1 ) = e( 2 ) * e( 1 ) * ( 1 - ca ) + e( 3 ) * sa;
dAlpha( 3, 1 ) = e( 3 ) * e( 1 ) * ( 1 - ca ) - e( 2 ) * sa;

dAlpha( 1, 2 ) = e( 1 ) * e( 2 ) * ( 1 - ca ) - e( 3 ) * sa;    % 2. Spalte
dAlpha( 2, 2 ) = e( 2 )^2        * ( 1 - ca ) + ca;
dAlpha( 3, 2 ) = e( 3 ) * e( 2 ) * ( 1 - ca ) + e( 1 ) * sa;

dAlpha( 1, 3 ) = e( 1 ) * e( 3 ) * ( 1 - ca ) + e( 2 ) * sa;    % 3. Spalte
dAlpha( 2, 3 ) = e( 2 ) * e( 3 ) * ( 1 - ca ) - e( 1 ) * sa;
dAlpha( 3, 3 ) = e( 3 )^2        * ( 1 - ca ) + ca;

q = ( 1 + lS / rE ) * p;

s( 1 ) = rS * cos( omega );
s( 2 ) = rS * sin( omega );
s( 3 ) = 0;

% Limits für zulässiges alphas berechnen
[ alphaPlus, alphaMinus ] = alphaLimits( rS, rE, p1, p3, psi, omega );

% die Sonne wird um -alpha gedreht
dMinusAlpha = subs( dAlpha, 'alpha', str2sym( '-alpha' ) );
sAlpha      = dMinusAlpha * s;

% PSAlpha als Koeffizienten des Vektors P ausdrücken 
pSAlpha = collect( p' * sAlpha, p );

% Steigung der Trajektorie und astronomischen Mittag bestimmen
[ sPlus, alphaHighNoon ] = steigung( alpha, psi, omega, ...
                                     thetaG - psi );

% mue0 bestimmen
omegaS = simplify( rE - pSAlpha / rE );
omegaS = omegaS / lS;
mue0   = omegaS / ( 1 + omegaS );

% die drei von alpha abhängigen Komponenten von xS( alpha ) bestimmen
[ chi2, f ] = chi( rS, rE, lS, alpha, omega, thetaG, psi, mue0 );

save( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'mue0', ...
      'alphaPlus', 'alphaMinus', 'sPlus', 'alphaHighNoon', 'chi2', 'f' )
