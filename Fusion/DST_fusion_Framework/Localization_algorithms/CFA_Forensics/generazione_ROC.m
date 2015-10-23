figure;
load('/users/ferrara/Desktop/Simulazioni8x8/Sintetiche_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'b','LineWidth',1)
hold
load('/users/ferrara/Desktop/Simulazioni8x8/TIFF_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'r','LineWidth',1);
load('/users/ferrara/Desktop/Simulazioni8x8/JPEG100_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'g','LineWidth',1);
load('/users/ferrara/Desktop/Simulazioni8x8/JPEG95_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'LineWidth',1,'Color',[0.75 0 0.75]);
load('/users/ferrara/Desktop/Simulazioni8x8/JPEG90_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'LineWidth',1,'Color',[0.31 0.31 0.31]);
load('/users/ferrara/Desktop/Simulazioni8x8/JPEG85_128/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'LineWidth',1,'Color',[0.87 0.49 0]);
legend('Bilinear','In-camera','JPEG 100%','JPEG 95%','JPEG 90%','JPEG 85%','Location','SouthEast');
axis square;
xlabel('PFA');
ylabel('PD');