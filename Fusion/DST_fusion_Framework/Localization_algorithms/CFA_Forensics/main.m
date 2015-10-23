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

detection_rate=zeros(1,length(files)/2);

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
        BPPM=test_CFA(Itest,dim,Nb,Ns);
        
        catch ME
           failures=failures+1;
            
           % waiting bar
           waitbar(i/(length(files)/2));
            
            continue;
        end
        
        
        % BPPM thresholding
        BPPM_thresholded=(BPPM>0.5);
        
        
        % detection rate
        numero_blocchi_CFA=sum(BPPM(not(isnan(BPPM))));
        detection_rate(1,i)=numero_blocchi_CFA/numero_blocchi_totali;

end

mean_detection_rate=sum(detection_rate)/(length(detection_rate)-failures);

save unknow-adaptive.mat detection_rate



