clear all;
Thresh=0.7;
Field= 'MarkMeasure'; %'IoU' 'MarkMeasure' 'F1'

Files=dir('ReportBinaryRealWorld_*.*');

for Algorithm=1:length(Files)
    load(Files(Algorithm).name);
    for Folder=1:length(Report)
        Successes(Folder,Algorithm)=sum(cell2mat({Report(Folder).(Field)})>Thresh);
    end
    
end