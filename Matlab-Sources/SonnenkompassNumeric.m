%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilfstool zu numerischen Lösung des Problems "Sonnenkompass"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

Phi = 23.44 / 180 * pi;     % Komplementwinkel Erd-Rotationsachse zur Ekliptik [rad]
RS  = 149600 * 10^6;        % Abstand Erde - Sonne [m]
RE  = 6371000;              % Erdradius [m]
L   = 1;                    % Stablänge [m]
LP  = [ 28.136746041614316, -15.438275482887885 ] / 180 * pi;   % Las Palmas

Alpha = 0 / 180 * pi;       % Rotationswinkel [rad]

A1 = sin( Phi )^2 * ( cos( Alpha ) - 1 ) - cos( Alpha );
A2 = cos( Phi ) * sin( Alpha );
A3 = cos( Phi ) * sin( Phi ) * ( cos( Alpha ) - 1 );
