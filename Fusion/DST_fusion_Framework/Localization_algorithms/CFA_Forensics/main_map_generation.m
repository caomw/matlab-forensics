% GENERAZIONE MAPPE PROBABILITA'

function main_map_generation(folder_name)

% waitbar
h=waitbar(0,'Please wait....');

folder_name1=[char(folder_name),'\Mappe'];
folder_name2=[char(folder_name),'\Parametri'];


% directory delle mappe e dei parametri del modello

directory1 = dir([folder_name1, '\*.mat']);
files1 = {directory1.name};


directory2 = dir([folder_name2, '\*.mat']);
files2 = {directory2.name};


% Inizializzazione parametri

mu=[];
sigma=[];


% Generazione delle mappe per ogni immagine 
    
for i=1:length(files1)
    
        % waiting bar update
        waitbar(i/(length(files1)));
        
        % map selection
        current_file1 = char(files1(i));
        filename1 = [folder_name1, '\', current_file1];
        load(filename1);
        mappa=statistica;
        
        %parameter selection
        
        current_file2 = char(files2(i));
        filename2 = [folder_name2, '\', current_file2];
        load(filename2);
        m=mu;
        s=sigma;
    
            
        BPPM2x2=BPPM(mappa,m,s);
        
        save ([folder_name,'\BPPM\',current_file1],'BPPM2x2');

end