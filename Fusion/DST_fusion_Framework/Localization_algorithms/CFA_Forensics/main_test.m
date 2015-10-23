% TEST ROC SU DATASET

% waitbar
h=waitbar(0,'Please wait....');

% dimensione dell'immagine e dataset
dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon_tampered';


% dimesione della statistica
Nb=2;

% accumulazione dei blocchi

Ns=[1,2,4];

% Dimensione del tampering

tamper_size=[128, 128];


directory = dir([folder_name, '\*.jpg']); % formato cambia a seconda che siano jpg o tif
files = {directory.name};

% inizializzazione strutture dati 

PD=zeros(3,length(files));
PFA=zeros(3,length(files));
PMD=zeros(3,length(files));

mean_PD=zeros(1,3);
mean_PFA=zeros(1,3);
mean_PMD=zeros(1,3);

% numero di fallimenti per algoritmo E/M
failures=0;

% soglia variabile per calcolo della ROC 
th=0:0.05:1;


% test
    
for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        % generazione statistica e stima dei parametri
        try
       
        statistica=test(Itest,dim,Nb);
        
        [mu,sigma,mix_perc]=MoG_parameters_estimation_v2(statistica);
           
        catch ME
            
           failures=failures+1;
            
           % waiting bar
           waitbar(i/(length(files)));
            
            continue;
        end
        
        % generazione PD,PFA e PMD al variare della soglia di decisione e
        % della dimensione della statistica
        
        for j=1:length(th)
        
            for k=1:3
            
                mask=tampering_mask(dim/(Nb*Ns(k)),tamper_size./(Nb*Ns(k)));
            
                BPPM=BPPM_generation(statistica,mu,sigma,Ns(k));
        
                BPPM_tamp=BPPM(mask);
                BPPM_tamp_detected=(BPPM_tamp<=th(j));
                PD(k,i,j)=sum(double(BPPM_tamp_detected))/length(BPPM_tamp_detected);
                PMD(k,i,j)=sum(double(not(BPPM_tamp_detected)))/length(BPPM_tamp_detected);
        
                BPPM_not_tamp=BPPM(not(mask));
                BPPM_not_tamp_detected=(BPPM_not_tamp>th(j));
                PFA(k,i,j)=1-sum(double(BPPM_not_tamp_detected))/length(BPPM_not_tamp_detected);
            
            end
        end
 end

for l=1:3
    for m=1:length(th)
        
        mean_PD(l,m)=sum(PD(l,:,m))/(length(PD(l,:,m))-failures);
        mean_PMD(l,m)=sum(PMD(l,:,m))/(length(PMD(l,:,m))-failures);
        mean_PFA(l,m)=sum(PFA(l,:,m))/(length(PFA(l,:,m))-failures);
    
    end
end

save tamp=128.mat


