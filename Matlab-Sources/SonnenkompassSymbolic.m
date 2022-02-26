%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu analytischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SonnenkompassSymbolic
    clc
    clear

    omega  = sym( 'omega', 'real' );            % Jahreszeiteinfluss
    thetaG = sym( 'thetaG', 'real' );           % Geographische Breite des Stabes
    psi    = sym( 'psi', 'real' );              % Komplementwinkel Erd-Rotationsachse zur Ekliptik
    rS     = sym( 'rS', 'real' );               % Abstand Erde - Sonne
    rE     = sym( 'rE', 'real' );               % Erdradius
    lS     = sym( 'lS', 'real' );               % Stablänge
    e      = sym( 'e', [ 3, 1 ], 'real' );      % Einheitsvektor Rotationsachse
    alpha  = sym( 'alpha', 'real' );            % Erd-Rotationswinkel (2*pi/24h)
    dAlpha = sym( 'dAlpha', [ 3, 3 ], 'real' );	% Drehmatrix
    p      = sym( 'p', [ 3, 1 ], 'real' );      % Fusspunkt des Stabes auf der Erdoberfläche und Stabende
    s      = sym( 's', [ 3, 1 ], 'real' );      % Sonnenposition in Bezug zum Erdmittelpunkt

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
    [ alphaPlus, alphaMinus ] = alphaLimits( rS, rE, p( 1 ), p( 3 ), psi, omega );

    % die Sonne wird um -alpha gedreht
    dMinusAlpha = subs( dAlpha, 'alpha', str2sym( '-alpha' ) );
    sAlpha      = dMinusAlpha * s;

    % PSAlpha als Koeffizienten des Vektors P ausdrücken 
    pSAlpha = collect( p' * sAlpha, p );

    % Steigung der Trajektorie und astronomischen Mittag bestimmen
    [ sPlus, alphaHighNoon ] = steigung( alpha, psi, omega, ...
                                         thetaG - psi );

    % omegaS und mue0 bestimmen
    omegaS = simplify( rE - pSAlpha / rE );
    omegaS = omegaS / lS;
    mue0   = omegaS / ( 1 + omegaS );

    % die drei von alpha abhängigen Komponenten von xS( alpha ) bestimmen
    [ chi2, f ] = chi( rS, rE, lS, alpha, omega, thetaG, psi, mue0 );

    save( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'omegaS', 'mue0', ...
          'alphaPlus', 'alphaMinus', 'sPlus', 'alphaHighNoon', 'chi2', 'f' )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ alphaPlus, alphaMinus ] = alphaLimits( rS, rE, p1, p3, psi, omega )
    % Limits für den Erdrotationswinkel alpha (Tageszeit)
    % Die hier benutzten Formeln werden in "SonnenKompassSymbolicAddon.m"
    % verfifiziert.
	as = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) ...
            * sin( omega );
    bs = - rS * ( p1 * cos( psi ) - p3 * sin( psi ) ) * cos( psi ) ...
            * cos( omega );
    cs = rE^2 - rS * ( p1 * sin( psi )^2 + p3 * cos( psi ) * sin( psi ) ) ...
            * cos( omega );

    wurzel  = sqrt( as^2 + bs^2 - cs^2 );
    nenner  = bs - cs;
    zPlus   = as + wurzel;
    zMinus  = as - wurzel;

    alphaPlus  = 2 * atan2( zPlus,  nenner );
    alphaMinus = 2 * ( atan2( zMinus, nenner ) + pi );
end

function [ sPlus, highNoon ] = steigung( alpha, psi, omega, offset )
    % Steigung der Trajektorie und astronomischer Mittag
    A = -cos( psi )^2 * sin( alpha ) * cos( omega ) + ...
         cos( psi ) * cos( alpha ) * sin( omega );
    B = -cos( psi ) * sin( psi ) * sin( alpha ) * cos( omega ) + ...
         sin( psi ) * cos( alpha ) * sin( omega );
    C =  cos( psi ) * cos( alpha ) * cos( omega ) + ...
         sin( alpha ) * sin( omega );

	s     = ( sin( offset ) * A + cos( offset ) * B ) / C;
    sPlus = simplify(  s );

    highNoon = atan2( tan( omega ), cos( psi ) );
end

function [ chi2, f ] = chi( rS, rE, lS, alpha, omega, thetaG, psi, mue0 )
    % Die zweidimensionale Trajektorie mit (x,y)=(chi2,f)
    offset = thetaG - psi;

    fak  = ( rE + lS ) * mue0;
    rho1 = fak * cos( offset );
    rho2 = 0;
    rho3 = fak * sin( offset );

    fak  = rS * ( 1 - mue0 );
    sig1 = sin( psi )^2 * ( 1 - cos( alpha ) ) * cos( omega ) + ...
           cos( alpha ) * cos( omega ) + ...
           cos( psi ) * sin( alpha ) * sin( omega );
    sig1 = fak * sig1;
    sig2 = -cos( psi ) * sin( alpha ) * cos( omega ) + ...
           cos( alpha ) * sin( omega );
    sig2 = fak * sig2;
    sig3 = cos( psi ) * sin( psi ) * ( 1 - cos( alpha ) ) * cos( omega ) ...
           - sin( psi ) * sin( alpha ) * sin( omega );
    sig3 = fak * sig3;

    chi1 = simplify( rho1 + sig1 );
    chi2 = simplify( rho2 + sig2 );
    chi3 = simplify( rho3 + sig3 );

    f = -sin( offset ) * chi1 + cos( offset ) * chi3;
end