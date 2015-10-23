function [error,X1,X2,X3] =  relative_error(originale,a,b,c,d)

% th=soglia T discriminante per il rilevamento zone grad. h,v e zone lisce
th=5;   % swava diceva 5 cmq..
% dimensione finestra (dimxdim) per la costruzione del sistema Ax=B
dim_finestra=7;
% Costruzione pattern di un colore
pattern=[a b; c d];
% Localizzazione pixel "puri", sia come maschera binaria che come valori effettivi
[imm_puri,imm_inter,maschera_puri]=extraction(originale,pattern);
% Calcolo gradienti
[ gradh, gradv ] = gradvh(originale);
% Costruzione maschere delle zone a gradienti elevati
[ mask_R1,mask_R2,mask_R3 ] = zone(gradh,gradv,th);


% Costruzione sistema Ax=B per trovare le x, coefficienti di interpolazione
[ A1,B1 ] = creazione_AB(originale,maschera_puri, mask_R1,dim_finestra);
if (isempty(A1))
    X1=zeros(dim_finestra*dim_finestra,1);
else
    X1 = calcolox( A1,B1);
end


[ A2,B2 ] = creazione_AB(originale,maschera_puri, mask_R2,dim_finestra);
if (isempty(A2))
    X2=zeros(dim_finestra*dim_finestra,1);
else
    X2 = calcolox( A2,B2);
end


[ A3,B3 ] = creazione_AB(originale,maschera_puri, mask_R3,dim_finestra);

if (isempty(A3))
    X3=zeros(dim_finestra*dim_finestra,1);
else
    X3 = calcolox( A3,B3);
end

% Ricostruzione del canale con i coefficienti trovati
[ matrixric ] = creamatrixricamp(imm_puri,maschera_puri,X1,X2,X3,mask_R1,mask_R2,mask_R3,dim_finestra);
% Calcolo dell'errore introdotto, tramite differenza e norma
matrix_diff_campionamento= originale-matrixric;
error= norm(matrix_diff_campionamento,'fro');