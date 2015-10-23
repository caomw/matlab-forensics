%This file generates the data matrices needed by the BBA modules of
%each algorithm. It creates the tampering of CFA,AJPEG and NAJPEG from
%the TIFF images in the directory dataset.

%sample step of the quality factor JPEG. The value are
%[50,60,70,80,90,100] for AJPEG and NAJPEG algorithms and
%[50,60,70,80,90,100,inf] for CFA.
qstep=10;

if ispc
    datasetdir='dataset_for_BBA_training\';
    ajpegdir='AJPEG\';
    najpegdir='NAJPEG\';
    cfadir='CFA\';
    datadir='DATA\';
    addpath('..\Localization_algorithms\JPEG_Forensics\jpeg_read');
    addpath('..\Localization_algorithms\JPEG_Forensics\JPEGNA');
    addpath('..\Localization_algorithms\JPEG_Forensics\JPEGDQ');        
    addpath('..\Localization_algorithms\CFA_Forensics\');     
    slash='\';
    
    vector=50:qstep:100;
    path_DQ=cell(1,length(vector));
    path_NA=cell(1,length(vector));
    path_CFA=cell(1,length(vector)+1);
    for i=1:length(vector)
        path_DQ(1,i)=cellstr([datasetdir,'AJPEG\Q2_',num2str(vector(i)),'\']);
        path_NA(1,i)=cellstr([datasetdir,'NAJPEG\Q2_',num2str(vector(i)),'\']);
    end
    
    for i=1:length(vector)+1
        if(i==1)
            path_CFA(1,i)=cellstr([datasetdir,'CFA\Q2_','0','\']);
        else
            path_CFA(1,i)=cellstr([datasetdir,'CFA\Q2_',num2str(vector(i-1)),'\']);
        end
    end
    
else
	datasetdir='dataset/';    
    ajpegdir='AJPEG/';
    najpegdir='NAJPEG/';
    cfadir='CFA/';
    datadir='DATA/';
    addpath('../Localization_algorithms/JPEG_Forensics/jpeg_read');
    addpath('../Localization_algorithms/JPEG_Forensics/JPEGNA');
    addpath('../Localization_algorithms/JPEG_Forensics/JPEGDQ');
    addpath('../Localization_algorithms/CFA_Forensics/');   
    slash='/';
    
    vector=50:qstep:100;
    path_DQ=cell(1,length(vector));
    path_NA=cell(1,length(vector));
    path_CFA=cell(1,length(vector)+1);
    for i=1:length(vector)
        path_DQ(1,i)= cellstr([datasetdir,'AJPEG/Q2_',num2str(vector(i)),'/']);
        path_NA(1,i)=cellstr([datasetdir,'NAJPEG/Q2_',num2str(vector(i)),'/']);
    end
    
    for i=1:length(vector)+1
        if(i==1)
            path_CFA(1,i)=cellstr([datasetdir,'CFA/Q2_','0','/']);
        else
            path_CFA(1,i)=cellstr([datasetdir,'CFA/Q2_',num2str(vector(i-1)),'/']);
        end
    end
    
end    

%size of the images in dataset
test_size = [1024, 1024];
%tamper size
tamp_size = [1024, 512];
%number of the dataset fold
nfold=5;
%size of the localization map
size_of_map=128;
%sample step of the localization map. It takes 1:8 value in each direction
%of the map.
skip_samples=8;


%Tampering creation step

disp('Tampering creation for CFA');
create_tampering_cfa(datasetdir,cfadir,test_size,tamp_size,qstep);

disp('Tampering creation for NAJPEG');
create_tampering_najpeg(datasetdir,najpegdir,test_size,tamp_size,qstep);

disp('Tampering creation for AJPEG');
create_tampering_ajpeg(datasetdir,ajpegdir,test_size,tamp_size,qstep);

mkdir([datasetdir ajpegdir],datadir);
mkdir([datasetdir najpegdir],datadir);
mkdir([datasetdir cfadir],datadir);


%Creation of the localization maps step

%Maps for CFA
for i=1:length(vector)+1
    if(i==1)
        fprintf('Create CFA map with Q2=0---------------------------------\n');
        create_map(path_CFA(1,i),[datasetdir cfadir datadir],'CFA',nfold,0,size_of_map);
    else
        fprintf('Create CFA map with Q2=%d---------------------------------\n',vector(i-1));
        create_map(path_CFA(1,i),[datasetdir cfadir datadir],'CFA',nfold,vector(i-1),size_of_map);
    end
end

%Maps for AJPEG
for i=1:length(vector)    
    fprintf('Create AJPEG map with Q2=%d---------------------------------\n',vector(i));
    create_map(path_DQ(1,i),[datasetdir ajpegdir datadir],'AJPEG',nfold,vector(i),size_of_map);
end

%Maps for NAJPEG
for i=1:length(vector)
    fprintf('Create NAJPEG map with Q2=%d---------------------------------\n',vector(i));
    create_map(path_NA(1,i),[datasetdir najpegdir datadir],'NAJPEG',nfold,vector(i),size_of_map);
end


%Fold creation step

%Fold creation for CFA
for i=1:length(vector)+1
    if(i==1)
        fprintf('Create fold for CFA with Q2=0---------------------------------\n');
        for j=1:nfold            
            create_fold_data('CFA',0,[datasetdir cfadir datadir],[datasetdir cfadir],['Q2_0' slash],j,test_size,tamp_size,size_of_map,skip_samples)
        end
    else
        fprintf('Create fold for CFA with Q2=%d---------------------------------\n',vector(i-1));
        for j=1:nfold
            create_fold_data('CFA',vector(i-1),[datasetdir cfadir datadir],[datasetdir cfadir],['Q2_' num2str(vector(i-1)) slash],j,test_size,tamp_size,size_of_map,skip_samples)
        end
    end        
end

%Fold creation for AJPEG
for i=1:length(vector)    
    fprintf('Create fold for AJPEG with con Q2=%d---------------------------------\n',vector(i));
    for j=1:nfold
        create_fold_data('AJPEG',vector(i),[datasetdir ajpegdir datadir],[datasetdir ajpegdir],['Q2_' num2str(vector(i)) slash],j,test_size,tamp_size,size_of_map,skip_samples)
    end
end

%Fold creation for NAJPEG
for i=1:length(vector)    
    fprintf('Create fold for NAJPEG with Q2=%d---------------------------------\n',vector(i));
    for j=1:nfold
        create_fold_data('NAJPEG',vector(i),[datasetdir najpegdir datadir],[datasetdir najpegdir],['Q2_' num2str(vector(i)) slash],j,test_size,tamp_size,size_of_map,skip_samples)
    end
end

%creation of the matrix and the parameters needed by the BBA modules
create_best_BBA_parameters;
