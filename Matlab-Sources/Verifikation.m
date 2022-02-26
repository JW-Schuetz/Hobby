clc
clear

load( 'SonnenkompassSymbolic.mat', 'alpha', 'q', 'sAlpha', 'mue0', ...
      'alphaPlus', 'alphaMinus', 'sPlus', 'alphaHighNoon', ...
      'chi2', 'f' )

offset = thetaG - psi;          % Elevations-Winkeloffset für die Projektion

% Kugelkoordinaten des Fusspunkt des Stabes, geographische Länge 0°, dabei 
% Neigung der Erd-Rotationsachse psi berücksichtigen
p1 = rE * cos( offset );        % x-Koordinate
p2 = 0;                         % y-Koordinate
p3 = rE * sin( offset );        % z-Koordinate

% die dreidimensionale Trajektorie
x0 = mue0 * q + ( 1 - mue0 ) * sAlpha;

% Test-Environment
[ y1, y2 ] = MapTrajektoryToTangentialPlane( x0( 1 ), x0( 2 ), x0( 3 ), ...
                offset );
