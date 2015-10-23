% Stima dei parametri del CFA demosaiking e delle maschere utilizzando la funzione 
% maincfa (da Swaminathan) e riordinando i dati in maniera opportuna

function [ H1red, H1green, H1blue,  H2red, H2green, H2blue,  H3red, H3green, H3blue, pattern_R, pattern_G, pattern_B , mask_R1, mask_R2, mask_R3] = CFA_estimation (immagine)

[errore, coefficienti, pattern]=maincfa(immagine);


%pattern per i canali rosso,verde e blu
pattern_R=reshape(pattern(1,:),2,2);
pattern_G=reshape(pattern(2,:),2,2);
pattern_B=reshape(pattern(3,:),2,2);


% i coefficienti di interpolazione sono restituiti in un unico vettore
% trascrivere i filtri per ogni canale e per ogni maschera in forma
% matriciale

H1red=reshape(coefficienti(1:49),7,7);
H2red=reshape(coefficienti(50:98),7,7);
H3red=reshape(coefficienti(99:147),7,7);

H1green=reshape(coefficienti(148:196),7,7);
H2green=reshape(coefficienti(197:245),7,7);
H3green=reshape(coefficienti(246:294),7,7);

H1blue=reshape(coefficienti(295:343),7,7);
H2blue=reshape(coefficienti(344:392),7,7);
H3blue=reshape(coefficienti(393:441),7,7);

% Calcolo gradienti
[ gradh, gradv ] = gradvh(immagine);
th=5;
% Costruzione maschere delle zone a gradienti elevati
[ mask_R1,mask_R2,mask_R3 ] = zone(gradh,gradv,th);
