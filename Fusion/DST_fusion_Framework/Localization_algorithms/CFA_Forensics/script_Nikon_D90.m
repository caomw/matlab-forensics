%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Calcolo ROC per le Nikon D90 con predittore bilineare e Algoritmo EM ZM
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datasets=dir('/users/ferrara/Desktop/simulazioni camere'); %%% INSERIRE IL PATH ESATTO
cartelle={datasets.name};

% dimensione del tampering per dataset. l'ordinamento dipende da come sono
% ordinate le cartelle nel path

tamper_size=128;


% Inizializzazione di parametri che sono funzione della dimensione dei
% blocchi
Nb = 8;
TOL = 1e-3;
MAX_ITER = 500;

% Generazione dei dati sui quali effettuare le misure

    for i=8:8
         failures = main_dataset_v2(char(cartelle(i)),['/users/ferrara/Desktop/Simulazioni/Simulazioni Nikon/',char(cartelle(i))],Nb,TOL,MAX_ITER);
         verosimiglianza(['/users/ferrara/Desktop/Simulazioni/Simulazioni Nikon/',char(cartelle(i))]);
         ROC_verosimiglianza8x8(['/users/ferrara/Desktop/Simulazioni/Simulazioni Nikon/',char(cartelle(i))],tamper_size);
    end

