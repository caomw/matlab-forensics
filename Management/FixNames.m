AlgorithmNames={'01' '02' '04' '05' '07' '10' '12' '14' '16'};

%EntireFileList=cell(0);
for Algorithm=1:length(AlgorithmNames)
    %EntireFileList=[EntireFileList;getAllFiles(['/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/' AlgorithmNames{Algorithm} '/'],'*.mat','true')];
end

disp('Began');

for fileInd=149830:length(EntireFileList)

    if ~strcmp(EntireFileList{fileInd},'Wild Web')
        MatContents=whos('-file',EntireFileList{fileInd});
        FoundName=false;
        Var=1;
        while Var<=length(MatContents)
            if strcmp(MatContents(Var).name,'Name')
                FoundName=1;
                break;
            end
            Var=Var+1;
        end
        if ~FoundName
            tmpName=strrep(EntireFileList{fileInd},'/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/','');
            slashes=strfind(tmpName,'/');
            Name=tmpName(slashes(2)+1:end);
            L=load(EntireFileList{fileInd});
            L.Name=Name;
            save(EntireFileList{fileInd},'-struct','L','-v7.3');
        end
    end
    if ~mod(fileInd,100)
        disp(fileInd)
    end
end
