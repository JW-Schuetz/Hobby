clear;

% Anzahl der Durchläufe
AlleTueren = [ 1, 2, 3 ];
Gewinn     = 0;
N          = 100000;
Strategie  = 'Beibehalten';
Strategie  = 'Wechseln';

for n = 1 : N
    TuerMitAuto = randi( 3, 1 );

    TuerenMitZiegen = AlleTueren;
    TuerenMitZiegen( TuerMitAuto ) = [];

    MeineErsteTuer = randi( 3, 1 );

    MeinNdx = find( TuerenMitZiegen == MeineErsteTuer );
    if( ~isempty( MeinNdx ) )
        % hinter MeineTuer steht eine Ziege
        ModeratorsTuer = TuerenMitZiegen( TuerenMitZiegen ~= MeineErsteTuer );
    else
        % hinter MeineTuer steht das Auto
        ModeratorsTuer = TuerenMitZiegen( randi( 2, 1 ) );
    end

    % Strategieauswahl
    if( strcmp( Strategie, 'Beibehalten' ) )
        MeineZweiteTuer = MeineErsteTuer;
    else
        SchonVergebeneTueren = [ MeineErsteTuer, ModeratorsTuer ];
        MeineZweiteTuer      = setdiff( AlleTueren, SchonVergebeneTueren );
    end

    if( MeineZweiteTuer == TuerMitAuto )
        Gewinn = Gewinn + 1;
    end
end

Gewinn / N