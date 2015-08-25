BasePath='D:\markzampoglou\ImageForensics\Datasets\Mark - Real World Splices\Organized Collection';
List=dir(BasePath);

for ii=3:length(List)
    GhostFolder=[BasePath '\' List(ii).name '\Ghost\'];
    if exist(GhostFolder,'dir')
        TIFList=getAllFiles([BasePath '\' List(ii).name '\Ghost\'] ,'*.tif',true);
        for jj=1:length(TIFList)
            movefile(TIFList{jj}, [TIFList{jj} 'f']);
        end
    end
end