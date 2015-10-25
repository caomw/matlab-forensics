javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');


Reports=dir('CompactReport_*.mat');
OutputFile='CompactReport.xls';

Sheets={'Median', 'Mean', 'KS'};

for Algorithm=1:length(Reports)
    load(Reports(Algorithm).name);
    for Sheet=1:length(Sheets)
        SheetName=[strrep(strrep(Reports(Algorithm).name,'.mat',''),'CompactReport_','') Sheets{Sheet}];
        
        xlwrite(OutputFile,{'VIPP2'},SheetName,'A1');
        xlwrite(OutputFile,{'Carvalho'},SheetName,'A15');
        xlwrite(OutputFile,{'ColumbiaU'},SheetName,'A35');
        xlwrite(OutputFile,{'1stChal'},SheetName,'A55');
        xlwrite(OutputFile,{'VIPPR'},SheetName,'A75');
        xlwrite(OutputFile,{'VIPPS'},SheetName,'A95');
        
        VIPP2Inds={'0' 'Thr';'' 'Sp';'100' 'Thr';'' 'Sp';'95' 'Thr';'' 'Sp';'85' 'Thr';'' 'Sp';'75' 'Thr';'' 'Sp';'65' 'Thr';'' 'Sp'};
        xlwrite(OutputFile,VIPP2Inds,SheetName,'B1');
        
        OtherInds={'0' 'Thr';'' 'Au';'' 'Sp';'100' 'Thr';'' 'Au';'' 'Sp';'95' 'Thr';'' 'Au';'' 'Sp';'85' 'Thr';'' 'Au';'' 'Sp';'75' 'Thr';'' 'Au';'' 'Sp';'65' 'Thr';'' 'Sp';'' 'Au'};
        for Line=15:20:95
            xlwrite(OutputFile,OtherInds,SheetName,['B' num2str(Line)]);
        end
        

        
        PrintIndex=1;
        for Dataset=1:length(Report.CompactCurves)
            for Version=1:length(Report.CompactCurves{1,Dataset}.([Sheets{Sheet} 'Positives']));
                ToWrite=round(Report.CompactCurves{Dataset}.([Sheets{Sheet} 'Positives']){Version}*100)/100;
                xlwrite(OutputFile,ToWrite,SheetName,['D' num2str(PrintIndex)]);
                PrintIndex=PrintIndex+size(ToWrite,1);
            end
            PrintIndex=PrintIndex+2;
        end
    end
end