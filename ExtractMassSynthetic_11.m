load('../../Datasets_Linux.mat');

DataPath={FirstChallengeTrain.Sp, FirstChallengeTrain.Au, FirstChallengeTest.Sp, FirstChallengeTest2.Sp, ColumbiauUncomp.au, ColumbiauUncomp.sp, VIPPDempSchaReal.au, VIPPDempSchaSynth.au, VIPPDempSchaSynth.sp};
OutNames={'FirstChallengeTrain_sp.mat','FirstChallengeTrain_au.mat', 'FirstChallengeTest_sp.mat'  'FirstChallengeTest2_sp.mat', 'ColumbiauUncomp_au.mat', 'ColumbiauUncomp_sp.mat', 'VIPPDempSchaReal_au.mat', 'VIPPDempSchaSynth_au.mat', 'VIPPDempSchaSynth_sp.mat'};

upLimit=inf;


for FolderInd=2:length(DataPath)
    DataPath{FolderInd}=strrep(DataPath{FolderInd},'\','/');
    List=[getAllFiles(DataPath{FolderInd},'*.jpg',false); getAllFiles(DataPath{FolderInd},'*.jpeg',false); getAllFiles(DataPath{FolderInd},'*.tif',false); getAllFiles(DataPath{FolderInd},'*.png',false); getAllFiles(DataPath{FolderInd},'*.gif',false); getAllFiles(DataPath{FolderInd},'*.bmp',false)];
    
    OutPath=OutNames{FolderInd};
    disp(OutPath);
    dots=strfind(OutPath,'.');
    OutPath=OutPath(1:dots(end)-1);
    OutPath=['SyntheticData/' OutPath '/'];
    mkdir(OutPath);
    
    for ii=1:min(length(List),upLimit)
        if mod(ii,15)==0
            disp(ii)
        end
        filename=List{ii};
        im =CleanUpImage([DataPath{FolderInd} '/' filename]);
        
        [l] = SLIC_Colour( im );
        
        save([OutPath filename '.mat'],'l','-v7.3');
    end
    
end