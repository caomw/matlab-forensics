% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon';

% dimesione della statistica
Nb=2;
% numero di blocchi su cui cumulare BPPM
Ns=4;
% numero di fallimenti dell'algoritmo E/M
failures=0;

numero_blocchi_totali=(dim/(Nb*Ns))^2;
numero_blocchi_CFA=0;


directory = dir([folder_name, '\*.tif']);
files = {directory.name};

data=[];

for i=1:length(files)/2
    
        % waiting bar update
        waitbar(i/(length(files)/2));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        % CFA testing
        try
        [BPPM,mappa_varianza]=test_uniform(Itest,dim,Nb);
        data=[data;region_uniform_detection(mappa_varianza,BPPM,Nb)];  
       
        catch ME
          failures=failures+1;
            
          % waiting bar
           waitbar(i/(length(files)/2));
            
           continue;
        end
end

x=0:0.1:20;
h=histc(data,x);
plot(x,h)

