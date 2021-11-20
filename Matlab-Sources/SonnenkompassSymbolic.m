%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

%#ok<*UNRCH> 

alt = false;

% Symbol-Definitionen:
if( alt )
    syms Omega Psi RS RE LS real
else
    Omega = sym( 'omega', 'real' );     % Jahreszeiteinfluss
    Psi   = sym( 'psi', 'real' );       % Komplementwinkel Erd-Rotationsachse zur Ekliptik
    RS    = sym( 'rS', 'real' );        % Abstand Erde - Sonne
    RE    = sym( 'rE', 'real' );        % Erdradius
    LS    = sym( 'lS', 'real' );        % Stablänge
end

% Einheitsvektor Rotationsachse
if( alt )
    syms E [ 3, 1 ] real
else
    E = sym( 'e', [ 3, 1 ], 'real' );
end

E( 1 ) = sin( Psi );
E( 2 ) = 0;
E( 3 ) = cos( Psi );

% Erd-Rotationswinkel (2*pi/24h), alpha=0 -> Mittags d.h.Sonnenhöchststand
if( alt )
    syms Alpha real
else
    Alpha = sym( 'alfa', 'real' );
end

ca = cos( Alpha );
sa = sin( Alpha );

% Drehmatrix
if( alt )
    syms DAlpha [ 3, 3 ] real
else
    DAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );
end

DAlpha( 1, 1 ) = E( 1 )^2        * ( 1 - ca ) + ca;             % 1. Spalte
DAlpha( 2, 1 ) = E( 2 ) * E( 1 ) * ( 1 - ca ) + E( 3 ) * sa;
DAlpha( 3, 1 ) = E( 3 ) * E( 1 ) * ( 1 - ca ) - E( 2 ) * sa;

DAlpha( 1, 2 ) = E( 1 ) * E( 2 ) * ( 1 - ca ) - E( 3 ) * sa;    % 2. Spalte
DAlpha( 2, 2 ) = E( 2 )^2        * ( 1 - ca ) + ca;
DAlpha( 3, 2 ) = E( 3 ) * E( 2 ) * ( 1 - ca ) + E( 1 ) * sa;

DAlpha( 1, 3 ) = E( 1 ) * E( 3 ) * ( 1 - ca ) + E( 2 ) * sa;    % 3. Spalte
DAlpha( 2, 3 ) = E( 2 ) * E( 3 ) * ( 1 - ca ) - E( 1 ) * sa;
DAlpha( 3, 3 ) = E( 3 )^2        * ( 1 - ca ) + ca;

% Fusspunkt des Stabes auf der Erdoberfläche und Stabende
if( alt )
	syms P [ 3, 1 ] real
else
    P = sym( 'p', [ 3, 1 ], 'real' );
end

Q = ( 1 + LS / RE ) * P;

% Sonne
if( alt )
    syms S [ 3, 1 ] real
else
    S = sym( 's', [ 3, 1 ], 'real' );
end

S( 1 ) = RS * cos( Omega );
S( 2 ) = RS * sin( Omega );
S( 3 ) = 0;

% rotierte Punkte P, Q und S
PAlpha = DAlpha * P;
SAlpha = DAlpha * S;

% Ausdruck PAlpha' * S bestimmen, collect: PAlphaS als Koeffizienten des Vektors P ausdrücken
PAlphaS = collect( PAlpha' * S, P );

% Ausdruck P' * SAlpha bestimmen, collect: PSAlpha als Koeffizienten des Vektors P ausdrücken
PSAlpha = collect( P' * SAlpha, P );

% Hauptterm der zu lösende Gleichung (Sonne wird gedreht)
OmegaS = simplify( RE - PSAlpha / RE );
OmegaS = OmegaS / LS;

save( 'sonnenkompass.mat', 'Alpha', 'DAlpha', 'Q', 'SAlpha', 'OmegaS' )