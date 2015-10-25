ReportList=dir('ReportRealWorld*.mat');
CarvalhoOptimalKS=[0.45;0.295;0.19;0.325;0.235;0.36;0.14;0.37;0.21;0.225];
CarvalhoOptimalMedian=[0.964;0.964;0.964;0.964;0.964;0.16;0.16;0.16;0.16;0.16;0.16;0.16;];


for Algorithm=1:length(ReportList)
    load(ReportList(Algorithm).name);
    disp(ReportList(Algorithm).name);
    for Dataset=1:length(Report.Curves);
        Ind=1;
        while Ind<=length(Report.Curves(Dataset).KSPositives) && (Ind-1)/(length(Report.Curves(Dataset).KSPositives)-1)<CarvalhoOptimalKS(Algorithm)
            Ind=Ind+1;
        end
        ThresholdedKS(Dataset,Algorithm)=round(Report.Curves(1,Dataset).KSPositives(Ind)*Report.Curves(1,Dataset).NumImages);
        Ind=1;
        while Ind<=length(Report.Curves(Dataset).MedianPositives) && Report.ThreshRange(Ind)<=CarvalhoOptimalMedian(Algorithm)
            Ind=Ind+1;
        end
        ThresholdedMedian(Dataset,Algorithm)=Report.Curves(1,Dataset).MedianPositives(Ind);
    end
end

save('RealWorldKS.mat','ThresholdedKS','ThresholdedMedian');