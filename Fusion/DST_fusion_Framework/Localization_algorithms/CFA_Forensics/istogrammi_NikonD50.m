%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Calcolo istogrammi della statistica 2x2 su Nikon D50
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder = '/users/ferrara/Desktop/Datasets/Nikon D50';
datasets=dir(folder); %%% INSERIRE IL PATH ESATTO
files={datasets.name};

dim =512;

% Inizializzazione di parametri che sono funzione della dimensione dei
% blocchi
Nb = 8;

% Numero di punti
n = 100;

data_bil =  [];
data_bicub =  [];
data_median =  [];
data_gradient =  [];

for i=3:length(files)
    
        % image selection
        current_file = char(files(i));
        filename = [folder,'/',current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        % generazione delle statistiche per i differenti predittori 
        
        statistica_bil = test_bil( Itest, dim, Nb);
        statistica_bicub = test_bicub( Itest, dim, Nb);
        statistica_median = test_median(Itest,dim,Nb);
        statistica_gradient = test_gradient( Itest, dim,Nb);
        

        % generazione dei dati
        
        data_bil = [data_bil;log(statistica_bil(:))];
        data_bicub = [data_bicub;log(statistica_bicub(:))];
        data_median = [data_median;log(statistica_median(:))];
        data_gradient = [data_gradient;log(statistica_gradient(:))];
        
end        
        % eliminazione dei nan e degli inf
       
       %data_bil(isnan(data_bil)) = 0;
       %data_bicub(isnan(data_bicub)) = 0;
       %data_median(isnan(data_median)) = 0;
       %data_gradient(isnan(data_gradient)) = 0;
       
       data_bil = data_bil(not(isinf(data_bil)));
       data_bicub = data_bicub(not(isinf(data_bicub)));
       data_median = data_median(not(isinf(data_median)));
       data_gradient = data_gradient(not(isinf(data_gradient)));

       data_bil = data_bil(not(isnan(data_bil)));
       data_bicub = data_bicub(not(isnan(data_bicub)));
       data_median = data_median(not(isnan(data_median)));
       data_gradient = data_gradient(not(isnan(data_gradient)));
       
       %[h_bil,x_bil] = hist(data_bil,n);
       %[h_bicub,x_bicub] = hist(data_bicub,n);
       %[h_median,x_median] = hist(data_median,n);
       %[h_gradient,x_gradient] = hist(data_gradient,n);
       
       save([folder,'/istogramma8.mat'],'data_bil','data_bicub','data_median','data_gradient');
        
