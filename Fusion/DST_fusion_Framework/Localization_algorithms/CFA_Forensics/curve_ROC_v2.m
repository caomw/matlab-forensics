% TEST ROC SU DATASET

% waitbar
h=waitbar(0,'Please wait....');

% dimensione dell'immagine e dataset
dim=512;
test_size = [dim, dim];
folder_name1='C:\Users\Pasquale\Desktop\Sintetiche_128\Mappe\';
folder_name2='C:\Users\Pasquale\Desktop\Sintetiche_128\Parametri\';

% file risultati

savefile='32.mat';


% dimesione della statistica
Nb=2;

% accumulazione dei blocchi

Ns=[1,2,4];

% Dimensione del tampering



directory1 = dir([folder_name1, '\*.mat']);
files = {directory1.name};


directory1 = dir([folder_name1, '\*.mat']);
files = {directory1.name};

data=[];
mappa2x2=[];
mappa4x4=[];
mappa8x8=[];


failures=0;

mask=tampering_mask(dim/(Nb*Ns),tamp/(Nb*Ns));

% test
    
for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % map selection
        current_file = char(files(i));
        filename = [folder_name1, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        

        
        data=[data;statistica(true(length(statistica)))];
        
            
        BPPM2x2=BPPM_generation(statistica,mu,sigma,Ns(1));
        mappa2x2=[mappa2x2;BPPM2x2(true(length(BPPM2x2)))];
        
        BPPM4x4=BPPM_generation(statistica,mu,sigma,Ns(2));
        BPPM4x4=kron(BPPM4x4,ones(Ns(2)));
        mappa4x4=[mappa4x4;BPPM4x4(true(length(BPPM4x4)))];
        
        BPPM8x8=BPPM_generation(statistica,mu,sigma,Ns(3));
        BPPM8x8=kron(BPPM8x8,ones(Ns(3)));
        mappa8x8=[mappa8x8;BPPM8x8(true(length(BPPM8x8)))];
        
        

end
       
save (savefile,'data','mappa2x2','mappa4x4','mappa8x8');