%This file generates the data matrices needed by the BBA modules of
%each algorithm. It creates the tampering of CFA,AJPEG and NAJPEG from
%the TIFF images in the directory dataset.

%sample step of the quality factor JPEG. The value are
%[50,60,70,80,90,100] for AJPEG and NAJPEG algorithms and
%[50,60,70,80,90,100,inf] for CFA.
qstep=10;

	datasetdir='dataset_for_svm_training/dataset/';    
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