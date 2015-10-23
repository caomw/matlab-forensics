AuSp=[2 -1;1 +1;2 -1;1 +1;1 +1];


List=dir('Report*.mat');

for ii=1:length(List)
    R=load(List(ii).name);
    Fields=fieldnames(R.Report.Curves{1,1});
    for X=1:size(R.Report.Curves,1)
        Y=1;
        for FieldInd=1:length(Fields)
            if ~strcmp(Fields{FieldInd},'Name')
                for Vert=1:size(R.Report.Curves{X,Y}.(Fields{FieldInd}),1)
                    NewSeries=R.Report.Curves{X,Y}.(Fields{FieldInd})(Vert,:);
                    if ~strcmp(Fields{FieldInd},'KSPositives')
                        TmpRange=R.Report.ThreshRange;
                    else
                        TmpRange=0:1/(size(NewSeries,2)-1):1;
                    end
                    Term=size(NewSeries,2)-2;
                    Ind=1;
                    while Ind<=Term
                        if round(NewSeries(1,Ind)*100)==round(NewSeries(1,Ind+1)*100)
                            NewSeries=NewSeries(:,[1:Ind Ind+2:end]);
                            TmpRange=TmpRange([1:Ind Ind+2:end]);
                        else
                            Ind=Ind+1;
                        end
                        Term=size(NewSeries,2)-2;
                    end
                    R.Report.CompactCurves{X,Y}.(Fields{FieldInd}){Vert}=[TmpRange;NewSeries];
                end
            end
        end
        
        for Y=2:size(R.Report.Curves,2)
            for FieldInd=1:length(Fields)
                if ~strcmp(Fields{FieldInd},'Name')
                    for Vert=AuSp(Y-1,1):2:size(R.Report.Curves{X,Y}.(Fields{FieldInd}),1)
                        NewSeries=R.Report.Curves{X,Y}.(Fields{FieldInd})([Vert Vert+AuSp(Y-1,2)],:);
                        if ~strcmp(Fields{FieldInd},'KSPositives')
                            TmpRange=R.Report.ThreshRange;
                        else
                            TmpRange=0:1/(size(NewSeries,2)-1):1;
                        end
                        Term=size(NewSeries,2)-2;
                        Ind=1;
                        while Ind<=Term
                            if round(NewSeries(1,Ind)*100)==round(NewSeries(1,Ind+1)*100)
                                NewSeries=NewSeries(:,[1:Ind Ind+2:end]);
                                TmpRange=TmpRange([1:Ind Ind+2:end]);
                            else
                                Ind=Ind+1;
                            end
                            Term=size(NewSeries,2)-2;
                        end
                        R.Report.CompactCurves{X,Y}.(Fields{FieldInd}){ceil(Vert/2)}=[TmpRange;NewSeries];
                    end
                end
            end
        end
    end
    save(strrep(List(ii).name,'Report','CompactReport'),'-struct','R');
end