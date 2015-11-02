clear all;
close all;

DatasetNames={'VIPP2';'CARV';'COLUMB';'CHAL';'FON_REAL';'FON_SYN'}
for Dataset=2:6;
    
    load([DatasetNames{Dataset} 'MATCurves.mat'],'Curves');
    
    LineColors={'b','k','m','c','r','g','b'};
    MarkerStyles={'o','s','^','v','x','d','o'};
    LineStyles={'-','--',':','-.','-','--',':'};
    
    JPEGFields=fieldnames(Curves.JPEG);
    if length(fieldnames(Curves.JPEG))==7
        JPEGNames={'DCT','ADQ1','ADQ2','NADQ','ELA','GHO','BLK'};
    else
        JPEGNames={'DCT','ADQ1','ELA','GHO','BLK'};
    end
    
    figure(1);
    plot(Curves.JPEG.(JPEGFields{1}).Au,Curves.JPEG.(JPEGFields{1}).Sp,[LineColors{1} MarkerStyles{1} LineStyles{1}],'MarkerFaceColor',LineColors{1},'LineWidth',2);
    axis([0 0.3 0 1]);
    xlabel('False Positives');
    ylabel('True Positives');
    title(['Dataset: ' strrep(DatasetNames{Dataset},'_','\_') ' | Algorithms: JPEG']);
    hold on;
    for ii=2:length(JPEGFields)
        plot(Curves.JPEG.(JPEGFields{ii}).Au,Curves.JPEG.(JPEGFields{ii}).Sp,[LineColors{ii} MarkerStyles{ii} LineStyles{ii}],'MarkerFaceColor',LineColors{ii},'LineWidth',2);
    end
    legend(JPEGNames,'Location','best')
    grid on;
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    savefig(['Figures/' DatasetNames{Dataset} '-JPEG.fig']);
    print(['Figures/' DatasetNames{Dataset} '-JPEG.png'],'-dpng','-r1200');
    hold off;
    
    NoiFields=fieldnames(Curves.NOI);
    NoiNames={'CFA1', 'CFA2', 'CFA3', 'NOI1', 'NOI2'};
    figure(2);
    plot(Curves.NOI.(NoiFields{1}).Au,Curves.NOI.(NoiFields{1}).Sp,[LineColors{1} MarkerStyles{1} LineStyles{1}],'MarkerFaceColor',LineColors{1},'LineWidth',2);
    axis([0 0.3 0 1]);
    xlabel('False Positives');
    ylabel('True Positives');
    title(['Dataset: ' strrep(DatasetNames{Dataset},'_','\_') ' | Algorithms: CFA-Noise']);
    hold on;
    for ii=2:length(NoiFields)
        plot(Curves.NOI.(NoiFields{ii}).Au,Curves.NOI.(NoiFields{ii}).Sp,[LineColors{ii} MarkerStyles{ii} LineStyles{ii}],'MarkerFaceColor',LineColors{ii},'LineWidth',2);
    end
    legend(NoiNames,'Location','best')
    grid on;
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    savefig(['Figures/' DatasetNames{Dataset} '-NOISE.fig']);
    print(['Figures/' DatasetNames{Dataset} '-NOISE.png'],'-dpng','-r1200');
    hold off;
    
end