clear all;
close all;

DatasetNames={'CARV';'COLUMB';'CHAL';'FON_REAL';'FON_SYN'}
AlgorithmNames={'DCT','ADQ1','ADQ2','NADQ','ELA','GHO','BLK','CFA1', 'CFA2', 'CFA3', 'NOI1', 'NOI2'};
ColumnNames={'Original','100','95','85','75','65'};


load('FP05.mat');



for Dataset=1:5;
    figure(1);
    bar(Output.Value{Dataset,3});
    axis([0 13 0 1]);
    legend(ColumnNames,'Location','best')
    
    
    xlabel(['Dataset: ' strrep(DatasetNames{Dataset},'_','\_')]);
    ylabel('True Positives for FP=5%');
    %title(['Dataset: ' strrep(DatasetNames{Dataset},'_','\_') ' | Algorithms: JPEG']);
    grid on;
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    set(gca,'fontsize',11,'XTickLabel',AlgorithmNames)
    set(gcf,'Position',[220 320 860 330 ]);
    set(gcf,'PaperPositionMode','auto')
    savefig(['Figures/' DatasetNames{Dataset} 'Bar.fig']);
    print(['Figures/' DatasetNames{Dataset} 'Bar.png'],'-dpng','-r1200');
    
end