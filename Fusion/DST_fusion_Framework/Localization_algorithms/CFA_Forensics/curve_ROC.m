% Generazione delle curve ROC

% waitbar
h=waitbar(0,'Please wait....');

savefile='Curve ROC\ROC_JPEG85_32';

load('risultati immagini compresse\32.mat');

regione_tamp=data(vettore_logico);
regione_not_tamp=data(not(vettore_logico));

minimo=min(data(not(isnan(data)|isinf(data))));
massimo=max(data(not(isnan(data)|isinf(data))));

passo=0.01;

th=minimo:passo:massimo;

for i=1:length(th)
    count1=double(regione_tamp<th(i));
    PD(i)=sum(count1)/length(count1);
    count2=double(regione_not_tamp<th(i));
    PFA(i)=sum(count2)/length(count2);
    % waiting bar update
     waitbar(i/(length(th)));
end

save (savefile,'PD','PFA');

plot(PFA,PD);
    