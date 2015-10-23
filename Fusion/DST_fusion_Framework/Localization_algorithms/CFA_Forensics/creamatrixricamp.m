function [ matrixric ] = creamatrixricamp(imm_puri,maschera_puri,X1,X2,X3,R1,R2,R3,val)

% Partendo dai coefficienti di interpolazione Xn ricampiono tutte le zone
% poi a seconda della zona di appartenenza prendo i valori finali

ric1=imfilter(imm_puri,reshape(X1,val,val));
ric2=imfilter(imm_puri,reshape(X2,val,val));
ric3=imfilter(imm_puri,reshape(X3,val,val));

matrixric=ric1.*R1+ric2.*R2+ric3.*R3;
% Nelle locazioni pure riprendo i valori originali
matrixric(find(maschera_puri==1))=imm_puri(find(maschera_puri==1));
