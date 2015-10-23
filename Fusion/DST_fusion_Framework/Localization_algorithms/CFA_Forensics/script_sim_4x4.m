%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Calcolo ROC per dimensioni della statistica 4x4
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datasets=dir('/users/ferrara/Desktop/Dataset'); %%% INSERIRE IL PATH ESATTO
cartelle={datasets.name};

% dimensione del tampering per dataset. l'ordinamento dipende da come sono
% ordinate le cartelle nel path

tamper_size=[0,0,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64];


% Inizializzazione di parametri che sono funzione della dimensione dei
% blocchi
Nb = 4;
TOL = 1e-3;
MAX_ITER = 500;

% Generazione dei dati sui quali effettuare le misure
    for i=3:20
         failures = main_dataset_bil_ZM(['/users/ferrara/Desktop/Dataset/',char(cartelle(i))],['/users/ferrara/Desktop/Simulazioni4x4/',char(cartelle(i))],Nb,TOL,MAX_ITER);
         verosimiglianza(['/users/ferrara/Desktop/Simulazioni4x4/',char(cartelle(i))]);
         ROC_verosimiglianza4x4(['/users/ferrara/Desktop/Simulazioni4x4/',char(cartelle(i))],tamper_size(i));
    end
