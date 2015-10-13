rng('shuffle');
Algorithms={'08'} %{'01' '02' '04' '05' '06' '07' '10' '14'};% '08', '12', '16'
%HistSteps=[5];

HistSize=500;

load('RandomSamplingStatistics.mat');
InputRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/AlgorithmOutput/';


for AlgInd=1:length(Algorithms)
    Algorithm=Algorithms{AlgInd};
    disp(Algorithm)
    %HistStep=HistSteps(AlgInd);
    
    %if ~isfield(Statistics,['A' Algorithm]) || ~isfield(Statistics.(['A' Algorithm]),'List')
    Statistics.(['A' Algorithm]).List=getAllFiles([InputRoot Algorithm],'*.mat',true);
    %end
    
    
        RandomizedIndex=randperm(length(Statistics.(['A' Algorithm]).List));
        for File=1:1600 %length(RandomizedIndex)
            FileInd=RandomizedIndex(File);
            L=load(Statistics.(['A' Algorithm]).List{FileInd});
            pause(0.05);
            Map=GetAlgorithmInputMap(L,Algorithm);
            for ii=1:length(Map)
                if File==1
                    HistMin{ii}=Statistics.(['A' Algorithm]).PracticalMin{ii};
                    HistMax{ii}=Statistics.(['A' Algorithm]).PracticalMax{ii};
                    HistStep{ii}=(HistMax{ii}-HistMin{ii})/HistSize;

                    AlgorithmHist{ii}=zeros(1,HistSize+3);
                    BinRanges{ii}=[-inf HistMin{ii}:HistStep{ii}:HistMax{ii} inf];

                    LogHistMin{ii}=log(realmin);
                    LogHistMax{ii}=log(Statistics.(['A' Algorithm]).PracticalMax{ii}-Statistics.(['A' Algorithm]).PracticalMin{ii});
                    HistRange=(LogHistMax{ii}-LogHistMin{ii})/10;
                    LogHistStep{ii}=HistRange/HistSize;

                    LogAlgorithmHist{ii}=zeros(1,HistSize+2);
                    LogBinRanges{ii}=[0:LogHistStep{ii}:HistRange inf];
                end
                
                
                
                LocalMax=max(max(max(Map{ii})));
                LocalMin=min(min(min(Map{ii})));
                LocalMaxNoInf=max(max(max(Map{ii}(Map{ii}~=Inf))));
                LocalMinNoInf=min(min(min(Map{ii}(Map{ii}~=-Inf))));
                
                if ~isfield(Statistics.(['A' Algorithm]),'Max') || length(Statistics.(['A' Algorithm]).Max)<ii || Statistics.(['A' Algorithm]).Max{ii}<LocalMax
                    Statistics.(['A' Algorithm]).Max{ii}=LocalMax;
                end
                if ~isfield(Statistics.(['A' Algorithm]),'Min') || length(Statistics.(['A' Algorithm]).Min)<ii || Statistics.(['A' Algorithm]).Min{ii}>LocalMin
                    Statistics.(['A' Algorithm]).Min{ii}=LocalMin;
                end
                if ~isfield(Statistics.(['A' Algorithm]),'MaxNoInf') || length(Statistics.(['A' Algorithm]).MaxNoInf)<ii || Statistics.(['A' Algorithm]).MaxNoInf{ii}<LocalMaxNoInf
                    Statistics.(['A' Algorithm]).MaxNoInf{ii}=LocalMaxNoInf;
                end
                if ~isfield(Statistics.(['A' Algorithm]),'MinNoInf') || length(Statistics.(['A' Algorithm]).MinNoInf)<ii || Statistics.(['A' Algorithm]).MinNoInf{ii}>LocalMinNoInf
                    Statistics.(['A' Algorithm]).MinNoInf{ii}=LocalMinNoInf;
                end
                
                Map{ii}(isnan(Map{ii}))=0;
                
                MapValues=Map{ii}(:);
                Hist=histc(MapValues,BinRanges{ii})';
                if sum(Hist)>0
                    AlgorithmHist{ii}=AlgorithmHist{ii}+Hist/sum(Hist);
                    %Statistics.(['A' Algorithm]).Hist{ii}=Statistics.(['A' Algorithm]).Hist{ii}+Hist/sum(Hist);
                else
                    disp('Empty Hist!');
                    pause
                end
                
                NormalizedForLog=Map{ii}(:)-Statistics.(['A' Algorithm]).Min{ii};
                NormalizedForLog(NormalizedForLog<0)=realmin;
                LogMapValues=log(NormalizedForLog);
                LogHist=histc(LogMapValues,LogBinRanges{ii})';
                LogAlgorithmHist{ii}=LogAlgorithmHist{ii}+LogHist/sum(LogHist);
                %Statistics.(['A' Algorithm]).LogHist{ii}=Statistics.(['A' Algorithm]).LogHist{ii}+LogHist/sum(LogHist);
            end
            
            clear L

        end
        Statistics.(['A' Algorithm]).Hist=AlgorithmHist;
        Statistics.(['A' Algorithm]).BinRanges=BinRanges;

        Statistics.(['A' Algorithm]).LogHist=LogAlgorithmHist;
        Statistics.(['A' Algorithm]).LogBinRanges=LogBinRanges;
        
        clear AlgorithmHist

end

save('RandomSamplingStatistics.mat','Statistics');