%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Calcolo ROC per Dataset unificati con predittore fissato
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folder_name = '/users/ferrara/Desktop/Verosimiglianza Median';
datasets=dir(folder_name); %%% INSERIRE IL PATH ESATTO
cartelle={datasets.name};

% dimensione del tampering per dataset. l'ordinamento dipende da come sono
% ordinate le cartelle nel path

tamp=128;


% Inizializzazione di parametri che sono funzione della dimensione dei
% blocchi
Nb = 8;
TOL = 1e-3;
MAX_ITER = 500;

% Generazione dei dati sui quali effettuare le misure

dim=512;


% Dimensioni del filtraggio
Nm=5;

mask8x8=tampering_mask(dim/8,tamp/8);

vettore_logico8x8=logical(kron(ones(400,1),mask8x8(true(length(mask8x8)))));

data8x8=[];
data8x8_median=[];
data8x8_mean=[];

    
for i=3:length(cartelle)-1
    
    directory = dir([char(folder_name), '/',char(cartelle(i)),'/*.mat']);
    files = {directory.name};

  for j=1:length(files)
    current_file = char(files(j));
    filename = [folder_name,  '/',char(cartelle(i)),'/', current_file];
    load(filename);

    ver8x8=loglikemap;
    %ver8x8_median=verosimiglianze_cumulate_median(ver8x8,1,Nm);
    %ver8x8_mean=verosimiglianze_cumulate_mean(ver8x8,1,Nm);
     
    data8x8=[data8x8;ver8x8(true(length(ver8x8)))];

    %data8x8_median=[data8x8_median;ver8x8_median(true(length(ver8x8_median)))];
    
    %data8x8_mean=[data8x8_mean;ver8x8_mean(true(length(ver8x8_mean)))];
 
    
 end  
end

regione_tamp8x8=data8x8(vettore_logico8x8);

%regione_tamp8x8_median=data8x8_median(vettore_logico8x8);

%regione_tamp8x8_mean=data8x8_mean(vettore_logico8x8);

regione_not_tamp8x8=data8x8(not(vettore_logico8x8));

%regione_not_tamp8x8_median=data8x8_median(not(vettore_logico8x8));

%regione_not_tamp8x8_mean=data8x8_mean(not(vettore_logico8x8));

[PD8x8,PFA8x8]=calcolo_ROC(regione_tamp8x8,regione_not_tamp8x8);
%[PD8x8_median,PFA8x8_median]=calcolo_ROC(regione_tamp8x8_median,regione_not_tamp8x8_median);
%[PD8x8_mean,PFA8x8_mean]=calcolo_ROC(regione_tamp8x8_mean,regione_not_tamp8x8_mean);

save ([folder_name,'/ROC/ROC'],'PD8x8','PFA8x8');

AUC8x8=trapz(PFA8x8,PD8x8);
%AUC8x8_median=trapz(PFA8x8_median,PD8x8_median);
%AUC8x8_mean=trapz(PFA8x8_mean,PD8x8_mean);

save ([folder_name,'/ROC/AUC.mat'],'AUC8x8');


