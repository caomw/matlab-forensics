% Datasets already scanned:
% CASIA2

load('MetadataStatistics.mat');

TargetPath='/media/marzampoglou/3TB_B/Image Forensics/Datasets/WildWebDataset/';

%FileList={'Metadata.jpg','Tp_D_CNN_M_N_ani00023_ani00024_10205.tif','3f4b0fdf3be6faafc42a87c7be651f8f226de03a.180846.jpg'};

FileList=getAllFiles(TargetPath,'*.jpg',true);
FileList=[FileList;getAllFiles(TargetPath,'*.tif',true)];
FileList=[FileList;getAllFiles(TargetPath,'*.tiff',true)];
FileList=[FileList;getAllFiles(TargetPath,'*.jpeg',true)];
FileList=[FileList;getAllFiles(TargetPath,'*.png',true)];
disp('Files collected. Beginning');


%StatisticsStruct=[];

for FileInd=1:length(FileList)
    FileList{FileInd}=strrep(FileList{FileInd}, ' ', '\ ');
    FileList{FileInd}=strrep(FileList{FileInd}, '(', '\(');
    FileList{FileInd}=strrep(FileList{FileInd}, ')', '\)');
    Command=['java -jar image-forensics-0.8.3-SNAPSHOT-jar-with-dependencies.jar ' FileList{FileInd}];
    system(Command);
    JSONCell=loadjson('filename.txt');
    for CategoryInd=1:length(JSONCell.values)
        Category=JSONCell.values{CategoryInd}.name;
        Category = matlab.lang.makeValidName(Category,'ReplacementStyle','hex');
        for FieldInd=1:length(JSONCell.values{CategoryInd}.values)
            FieldName=JSONCell.values{CategoryInd}.values{FieldInd}.name;
            FieldName = matlab.lang.makeValidName(FieldName,'ReplacementStyle','hex');
            FieldValue = JSONCell.values{CategoryInd}.values{FieldInd}.value;
            if isempty(FieldValue)
                FieldValue='Empty Field Value';
            end
            FieldValue = matlab.lang.makeValidName(FieldValue,'ReplacementStyle','hex');
            
            if isfield(StatisticsStruct,Category) && isfield(StatisticsStruct.(Category),FieldName)
                %StatisticsStruct.(Category).(FieldName)=StatisticsStruct.(Category).(FieldName)+1;
                StatisticsStruct.(Category).(FieldName).OverallFrequency=StatisticsStruct.(Category).(FieldName).OverallFrequency+1;
                if length(fieldnames(StatisticsStruct.(Category).(FieldName)))<100
                    if isfield(StatisticsStruct.(Category).(FieldName),FieldValue)
                        StatisticsStruct.(Category).(FieldName).(FieldValue)=StatisticsStruct.(Category).(FieldName).(FieldValue)+1;
                    else
                        StatisticsStruct.(Category).(FieldName).(FieldValue)=1;
                    end
                end
                
            else
                %StatisticsStruct.(Category).(FieldName)=1;
                StatisticsStruct.(Category).(FieldName).OverallFrequency=1;
                StatisticsStruct.(Category).(FieldName).(FieldValue)=1;
            end
        end
    end
    if (mod(FileInd,100)==0)
        disp([FileInd length(FileList)]);
    end
end


save('MetadataStatistics.mat','StatisticsStruct');