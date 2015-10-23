% TEST ROC SU DATASET

% waitbar
h=waitbar(0,'Please wait....');

% dimensione dell'immagine e dataset
dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon_tampered';

% file risultati

savefile='risultati immagini compresse\32.mat';

tamp=32;


% dimesione della statistica
Nb=2;

% accumulazione dei blocchi

Ns=1;

% Dimensione del tampering

mask=tampering_mask(dim/Nb,tamp/Nb);

vettore_logico=logical(kron(ones(100,1),mask(true(length(mask)))));

directory = dir([folder_name, '\*.jpg']); % formato cambia a seconda che siano jpg o tif
files = {directory.name};

data=[];


failures=0;

% test
    
for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        % generazione statistica

        statistica=test(Itest,dim,Nb);
        
        data=[data;log(statistica(true(length(statistica))))];

end
       
save (savefile,'data','vettore_logico');

curve_ROC;

