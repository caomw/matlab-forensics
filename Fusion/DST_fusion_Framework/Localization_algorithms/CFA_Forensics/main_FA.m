% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon_tampered';

% dimesione della statistica
Nb=2;

% accumulazione dei blocchi

Ns=4;


directory = dir([folder_name, '\*.tif']);
files = {directory.name};

region_rate=zeros(1,length(files));
false_alarm=zeros(1,length(files));

for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        [statistica, blocks]=test_FA_soglia2(Itest,dim,Nb,Ns);
        
        blocks=double(blocks);
        region_rate(i)=1-sum(sum(blocks))/((length(blocks))^2);
        
        [mu,sigma,mix_perc]=MoG_parameters_estimation(statistica(logical(blocks)));
        
        BPPM=BPPM_generation_v2(statistica,blocks,mu,sigma,Ns);
        
        BPPM_valida=BPPM(logical(blocks));
        
        blocchi_non_validi=(BPPM_valida<=0.5);
        
        false_alarm(i)=sum(double(blocchi_non_validi))/length(blocchi_non_validi);
end


mean_region_rate=mean(region_rate);
mean_false_alarm=mean(false_alarm);

