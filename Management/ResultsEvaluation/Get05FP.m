clear all
List=dir('CompactReport*.mat');

CorrectOrder=[1 2 4 5 7 8 3 6 9 10];

for AlgorithmInd=1:length(List)
    Algorithm=CorrectOrder(AlgorithmInd);
    R=load(List(Algorithm).name);
    Fields=fieldnames(R.Report.CompactCurves{1,1});
    for Y=2:size(R.Report.CompactCurves,2)
        for FieldInd=1:length(Fields)
            for Quality=1:6
                    NewSeries=R.Report.CompactCurves{1,Y}.(Fields{FieldInd}){Quality};
                    Ind=1;
                    while NewSeries(2,Ind)>0.05
                        Ind=Ind+1;
                    end
                    Output.Threshold{Y-1,FieldInd}(AlgorithmInd,Quality)=NewSeries(1,Ind);
                    Output.Value{Y-1,FieldInd}(AlgorithmInd,Quality)=NewSeries(3,Ind);
                end
            end

    end
end

save('FP05.mat','Output');

