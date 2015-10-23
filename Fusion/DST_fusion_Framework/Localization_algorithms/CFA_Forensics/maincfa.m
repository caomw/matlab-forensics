function [ min_error,features_cfa,pattern ] = maincfa( sorgente )
red=double(sorgente(:,:,1));%creo i 3 canali red green blue
green=double(sorgente(:,:,2));
blue=double(sorgente(:,:,3));

% Le prossime tre pattern sono quelle rappresentative per ogni cluster,
% in base a quale risulterà l'errore minimo verranno provate le pattern del
% cluster relativo
% CLUSTER 1: hanno lo stesso colore lungo le diagonali
% CLUSTER 2: hanno rosso e blu in posizioni adiacenti orizzontali o
% verticali
% CLUSTER 3: hanno verde in posizioni adiacenti orizzontali o verticali

% Ogni blocco i-esimo RGB rappresenta una pattern, esempio i=1 abbiamo
% prima posizione pura RED, seconda e terza GREEN e quarta BLUE
vett_patt_red = [1,0,0,0; 0 1 0 0; 0 0 0 1 ; 0 0 1 0 ];
vett_patt_green=[0,1,1,0; 1 0 0 1; 0 1 1 0 ; 1 0 0 1 ];
vett_patt_blue =[0,0,0,1; 0 0 1 0; 1 0 0 0 ; 0 1 0 0 ];
% Inizializzazione vettori
features_cfa=[];
pattern=[];
min_error = Inf;
% Testing di tutte le 4 pattern di Bayer
for i= 1:4
%     Relative_error restituisce i coefficienti di interpolazione e
%     l'errore normalizzato per ogni canale
    [erroreRed,X1red,X2red,X3red]=relative_error(red,vett_patt_red(i,1),vett_patt_red(i,2),vett_patt_red(i,3),vett_patt_red(i,4));
    [erroreGreen,X1green,X2green,X3green]=relative_error(green,vett_patt_green(i,1),vett_patt_green(i,2),vett_patt_green(i,3),vett_patt_green(i,4));
    [erroreBlue,X1blue,X2blue,X3blue]=relative_error(blue,vett_patt_blue(i,1),vett_patt_blue(i,2),vett_patt_blue(i,3),vett_patt_blue(i,4));
%    Calcolo errore complessivo (dei 3 colori pesati opportunamente)
    err = erroreass_immagine( erroreRed,erroreGreen,erroreBlue );
%     Scelta della pattern migliore
    if(err<min_error)
        min_error = err;
        features_cfa=[X1red',X2red',X3red',X1green',X2green',X3green',X1blue',X2blue',X3blue'];
        pattern=[vett_patt_red(i,:);vett_patt_green(i,:);vett_patt_blue(i,:)];
    end
    
end

