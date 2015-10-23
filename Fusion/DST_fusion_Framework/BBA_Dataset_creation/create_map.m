function create_map(path,datapath,type,nfold,q2value,size_of_map)
%This function creates the localization map for each image in the dataset through the quality factor Q2.
%The maps are divided in nfold for each algorithm.
    if ispc   
        addpath('..\Localization_algorithms\JPEG_Forensics\jpeg_read');
        addpath('..\Localization_algorithms\JPEG_Forensics\JPEGNA');
        addpath('..\Localization_algorithms\JPEG_Forensics\JPEGDQ');        
        addpath('..\Localization_algorithms\CFA_Forensics\');     
        addpath('..\Localization_algorithms\CFA_Forensics\Algoritmo_Rivelazione\');   
    else
        addpath('../Localization_algorithms/JPEG_Forensics/jpeg_read');
        addpath('../Localization_algorithms/JPEG_Forensics/JPEGNA');
        addpath('../Localization_algorithms/JPEG_Forensics/JPEGDQ');
        addpath('../Localization_algorithms/CFA_Forensics/');   
        addpath('../Localization_algorithms/CFA_Forensics/Algoritmo_Rivelazione/');   
    end
    
    %Variables needed by the three algorithms
    
    Nb = 8;           
    Ns = 1;           
    Nm = 5;           

    Bayer_G = [0, 1;
               1, 0];

    Bayer_R = [1, 0;
               0, 0];

    Bayer_B = [0, 0; 
               0, 1];
    
    c2Y = [1 3 6 10 15];
    path=char(path);

    destinationfolder=['Q2_',num2str(q2value)];    
    mkdir(datapath,  destinationfolder);
    index=1;
    
    %Mix the images for each Q2
    img_list1=dir([path,'*.jpg']);    
    img_list2=dir([path,'*.tif']);    
    files1 = {img_list1.name};
    files2 = {img_list2.name};
    if(length(files1)>length(files2))
        files=files1;
    else
        files=files2;
    end   
    permutation=randperm(length(files));
    rand_files=files(permutation);
    number_of_files_per_fold=length(rand_files)/nfold;        
    for i=1:nfold
        file = fopen ( ['errorfold',num2str(i),'.txt'], 'w');
        file_name = fopen ( ['namefold',num2str(i),'.txt'], 'w');
        fold_matrix=zeros(size_of_map,size_of_map,number_of_files_per_fold);
        for j=1:number_of_files_per_fold
            if(strcmp(type,'NAJPEG')==1)
                %application of NAJPEG algorithm
                fprintf('Analyze the image %s %d/%d\n',char(rand_files(index)),index,length(files));
                fprintf(file_name,'%s \n',char(rand_files(index)));
                im = jpeg_read([path, char(rand_files(index))]);   
                try
                    [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2Y(end));
                    fold_matrix(:,:,j) = smooth_unshift(sum(LLRmap_s(:,:,1:length(c2Y)),3),k1e,k2e);
                    fold_matrix(:,:,j)=1./(1+exp(fold_matrix(:,:,j)));
                catch err
                    fprintf('Error on %s\n', char(rand_files(index)));
                    fprintf(file,'%s %d\n',char(rand_files(index)),j);
                end 
            elseif(strcmp(type,'AJPEG')==1)
                %application of AJPEG algorithm
                fprintf('Analyze the image %s %d/%d\n',char(rand_files(index)),index,length(files));
                fprintf(file_name,'%s \n',char(rand_files(index)));
                im = jpeg_read([path, char(rand_files(index))]);   
                try
                    [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2Y(end));
                    fold_matrix(:,:,j) = imfilter(sum(LLRmap_s(:,:,1:length(c2Y)),3), ones(3), 'symmetric', 'same');
                    fold_matrix(:,:,j)=1./(1+exp(fold_matrix(:,:,j)));
                catch err
                    fprintf('Error on %s\n', char(rand_files(index)));
                    fprintf(file,'%s %d\n',char(rand_files(index)),j);
                end 
            elseif(strcmp(type,'CFA')==1)
                %application of CFA algorithm
                fprintf('Analyze the image %s %d/%d\n',char(rand_files(index)),index,length(files));
                fprintf(file_name,'%s \n',char(rand_files(index)));
                immagine = imread([path, char(rand_files(index))]); 
                try
                    [h, w, dummy] = size(immagine);                    
                    dim = [h, w];
                    err_pred = predizione(immagine);                    
                    mappa_varianza = variance_map_generation(err_pred(:,:,2), Bayer_G, dim);                    
                    statistica = statistics_generation(mappa_varianza, Bayer_G, Nb);
                    [mu, sigma, mix_perc] = MoG_parameters_estimation_ZM(statistica, 1e-3, 500);
                    likelihood_map = verosimiglianza_ZM(statistica, mu, sigma);                    
                    BPPMfilt_median = mappe_cumulate_median(likelihood_map, Ns, Nm);                                                          
                    fold_matrix(:,:,j) = BPPMfilt_median;
                catch err
                    fprintf('Error on %s\n', char(rand_files(index)));
                    fprintf(file,'%s %d\n',char(rand_files(index)),j);
                end                       
            end
            index=index+1;
        end
        
        save(['fold', num2str(i)],'fold_matrix');  
        fclose(file);
        fclose(file_name);       
        movefile(['errorfold',num2str(i),'.txt'],[datapath ,destinationfolder]);
        movefile(['namefold',num2str(i),'.txt'],[datapath,destinationfolder]);                            
    end
    movefile('*.mat',[datapath,destinationfolder]);    
end
