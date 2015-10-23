% TEST ROC SU DATASET

function [failures] = main_dataset_median_ZM(folder_name1,folder_name, Nb, tol, max_iter)

% Nb ??? la dimensione dei blocchi

% waitbar
%h=waitbar(0,'Please wait....');

% dimensione dell'immagine e dataset

dim=512;


directory = dir( [folder_name1,'/*.*']); % formato cambia a seconda che siano jpg o tif
files = {directory.name};

% numero di fallimenti per algoritmo E/M
failures=zeros(1,length(files));

  
% test
    
for i=3:length(files)
    
        % waiting bar update
       % waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name1,'/',current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        % generazione statistica 
        
        statistica=test_median(Itest,dim,Nb);
        
        %stima dei parametri
        
        [mu,sigma,mix_perc]=MoG_parameters_estimation_ZM(statistica, tol, max_iter);
       
        
        save([folder_name,'/Mappe/',num2str((i-2)),'.mat'],'statistica');
        save([folder_name,'/Parametri/',num2str((i-2)),'.mat'],'mu','sigma','mix_perc','failures');
        
end

total_failures = sum(failures)