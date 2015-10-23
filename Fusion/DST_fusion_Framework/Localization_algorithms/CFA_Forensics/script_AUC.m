%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Calcolo ROC per dimensioni della statistica 2x2
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datasets=dir('/users/ferrara/Desktop/Dataset'); %%% INSERIRE IL PATH ESATTO
cartelle={datasets.name};

% dimensione del tampering per dataset. l'ordinamento dipende da come sono
% ordinate le cartelle nel path

tamper_size=[0,0,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64,128,32,64];


% Generazione dei dati sui quali effettuare le misure
    for i=3:20 
         calcolo_AUC(['/users/ferrara/Desktop/Simulazioni8x8/',char(cartelle(i))]);
    end
