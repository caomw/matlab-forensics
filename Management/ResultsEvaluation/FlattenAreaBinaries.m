InputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/Evaluations/';

List=getAllFiles(InputRoot,'*MaskArea.mat',true);

for ii=1:List
    LL=load(List{ii});
    Result.F1s=cell2mat(reshape({LL.Results.F1},size(LL.Results)));
    [F1sMaxFlip,F1sMaxFlipInd]=max(F1s,[],4);
    [F1sMaxOper,F1sMaxOperInd]=max(F1sMaxFlip,[],4);
    
    Result.IoUs=cell2mat(reshape({LL.Results.IoU},size(LL.Results)));
    [IoUsMaxFlip,IoUsMaxFlipInd]=max(IoUs,[],4);
    [IoUsMaxOper,IoUsMaxOperInd]=max(IoUsMaxFlip,[],4);
    
    Result.MarkMeasures=cell2mat(reshape({LL.Results.MarkMeasure},size(LL.Results)));
    [MarkMeasuresMaxFlip,MarkMeasuresMaxFlipInd]=max(MarkMeasures,[],4);
    [MarkMeasuresMaxOper,MarkMeasuresMaxOperInd]=max(MarkMeasuresMaxFlip,[],4);
    
    save(strrep(List{ii},'.mat','_max.mat'), '-struct', 'Result');
end


