figure;
load('/users/ferrara/Desktop/Simulazioni ideale/bilineare/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'b','LineWidth',1)
hold
load('/users/ferrara/Desktop/Simulazioni ideale/bicubico/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'r','LineWidth',1);
load('/users/ferrara/Desktop/Simulazioni ideale/gradient/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'g','LineWidth',1);
load('/users/ferrara/Desktop/Simulazioni ideale/median/ROC/ROC.mat');
plot([0; PFA8x8; 1],[0; PD8x8; 1],'LineWidth',1,'Color',[0.75 0 0.75]);
legend('Bilinear','Bicubic','Gradient-based','Median','Location','SouthEast');
axis square;
xlabel('PFA');
ylabel('PD');