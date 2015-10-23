function [ A B ] = creazione_ABzonelisce( maschera,originale,val )

%creazione B
or_trasp=originale';
maschera_trasp=maschera';
B=or_trasp(find(maschera_trasp==1));
if (isempty(B))
    A=[];
    return;
end


%creazione A
Matrix_trasposta=(originale)';
[sizer,sizec]=size(originale);
step=(val-1)/2; 
%indici interpolati nella zona individuata da mask
V=find((maschera_trasp==1));
newmatrice_con_cornice= zeros(sizer+2*step,sizec+2*step); %creazione matrice con cornice di zeri
newmatrice_con_cornice(step+1:end-step,step+1:end-step)=Matrix_trasposta;%creazione matrice con cornice di zeri
A = zeros(size(B,1),val*val);
row=1;
% costruzione riga di A, mediante localizzazione dei pixel della finestra e
% reshape successivo per allinearli
for k=1:size(V)
    [i,j] = ind2sub([sizer,sizec],V(k));
    newi=i+step;
    newj=j+step;
    A(row,:)=reshape(newmatrice_con_cornice(newi-step:newi+step,newj-step:newj+step),[1,val*val]);
    row=row+1;
end

A(:,5)=[];  %eliminazione valori centrali