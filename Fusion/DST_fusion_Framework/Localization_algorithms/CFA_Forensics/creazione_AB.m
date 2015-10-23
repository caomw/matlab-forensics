function [A B ] = creazione_AB(originale,pattern, mask,val)

% Creazione matrice A di dimensione #interpolati x (valxval)
% Creazione B vettore di dimensione #interpolati x 1
% Risolvendo Ax=B otterrò i coefficienti di interpolazione

% creazione B, vettore dei pixel noti, nelle posizioni da interpolare
% si identificano facendo il negativo della pattern
or_trasp=originale';
B=or_trasp(find(((1-pattern).*mask)==1));
if (isempty(B))
    A=[];
    return;
end
puri_trasposti=(originale.*pattern)';

%creazione A
[sizer,sizec]=size(originale);
step=(val-1)/2; 
%indici interpolati nella zona individuata da mask
V=find(((1-pattern).*mask)==1);
newmatrice_pura= zeros(sizer+2*step,sizec+2*step); %creazione matrice con cornice di zeri
newmatrice_pura(step+1:end-step,step+1:end-step)=puri_trasposti;%creazione matrice con cornice di zeri
A = zeros(size(B,1),val*val);
row=1;
% costruzione riga di A, mediante localizzazione dei pixel della finestra e
% reshape successivo per allinearli
for k=1:size(V)
    [i,j] = ind2sub([sizer,sizec],V(k));
    newi=i+step;
    newj=j+step;
    A(row,:)=reshape(newmatrice_pura(newi-step:newi+step,newj-step:newj+step),[1,val*val]);
    row=row+1;
end