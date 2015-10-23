% Calcolo dei valori della PD e PFA 

function [PD,PFA] = calcolo_ROC(regione_tamp,regione_not_tamp)


N=1000000;        % numero di punti sulla ROC
eps=0.05;           % probabilit? delle code

f_inf_tamp = @(T) (sum(double(regione_tamp<T))./length(regione_tamp))-eps;   % coda inferiore
%f_sup_tamp = @(T) sum(double(regione_tamp<T))./length(regione_tamp)-1+eps; % coda superiore

%f_inf_not_tamp = @(T) sum(double(regione_not_tamp<T))./length(regione_not_tamp)-eps;   % coda inferiore
f_sup_not_tamp = @(T) (sum(double(regione_not_tamp<T))./length(regione_not_tamp))-1+eps; % coda superiore

x0_tamp = (max(regione_tamp)+min(regione_tamp))/2;
x0_not_tamp = (max(regione_not_tamp)+min(regione_not_tamp))/2;

T_inf_tamp=fzero(f_inf_tamp,x0_tamp);
%T_sup_tamp=fzero(f_sup_tamp,x0_tamp);

%T_inf_not_tamp=fzero(f_inf_not_tamp,x0_not_tamp);
T_sup_not_tamp=fzero(f_sup_not_tamp,x0_not_tamp);

%data_tamp = regione_tamp(not(regione_tamp<T_inf_tamp | regione_tamp > T_sup_tamp));
%data_not_tamp = regione_not_tamp(not(regione_not_tamp< T_inf_not_tamp| regione_not_tamp>T_sup_not_tamp));

minimo=T_inf_tamp;
massimo=T_sup_not_tamp;

th= minimo:((massimo-minimo)/N):massimo;
th =[-inf th inf];

freq_tamp=histc(regione_tamp,th);
freq_not_tamp=histc(regione_not_tamp,th);

PD=cumsum(freq_tamp)./length(regione_tamp);
PFA=cumsum(freq_not_tamp)./length(regione_not_tamp);



    
