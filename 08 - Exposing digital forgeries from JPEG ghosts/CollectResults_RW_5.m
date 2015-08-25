function [OverallSpMorphOutput, OverallSpOutput, SpFiles, SpNames, BinMasks]=CollectResults_Adaptive_RW(SpFolders)

load('Results_RW.mat');

for Folder=2 %1:length(SpFolders)
    disp(SpFolders{Folder});
    for MaskInd=1:length(BinMasks{Folder})
        SpOutput=[];
        for ii=1:length(SpFiles{Folder})
            load(SpFiles{Folder}{ii});
            SpFiles{Folder}{ii}
            if mod(ii,30)==0
                disp(ii);
            end
            BinMask=imresize(BinMasks{Folder}{MaskInd},size(Results.dispImages{1}))>0;
            for ImInd=1:length(Results.imin)
                ImToProcess=Results.dispImages{Results.imin(ImInd)};
                Lvl=graythresh(ImToProcess);
                Binarized=GetBinaryOutput_Ghosts(ImToProcess,Lvl);
                for jj=1:size(Binarized,3)
                    tmpResult=Binarized(:,:,jj);
                    Straight=[numel(tmpResult) sum(sum(tmpResult)) sum(sum(BinMask)) sum(sum(tmpResult&BinMask)) sum(sum(tmpResult&~BinMask))];
                    tmpResult=~tmpResult;
                    Inv=[numel(tmpResult) sum(sum(tmpResult)) sum(sum(BinMask)) sum(sum(tmpResult&BinMask)) sum(sum(tmpResult&~BinMask))];
                    SpOutput(ii,:,jj,1,ImInd)=Straight;
                    SpOutput(ii,:,jj,2,ImInd)=Inv;
                end
            end
            OverallSpMorphOutput{Folder}{MaskInd}=SpOutput;
        end
    end
    %save('Results_RW.mat','OverallSpOutput','OverallSpMorphOutput', 'SpFiles','SpNames','SpList', 'BinMasks');
end