scenario = (1:1:6)';
tab = [];

figure;

load('/users/ferrara/Desktop/Simulazioni2x2/Sintetiche_128/ROC/AUC.mat');
tab(1,1) = AUC2x2;
tab(1,2) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni2x2/TIFF_128/ROC/AUC.mat');
tab(2,1) = AUC2x2;
tab(2,2) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG100_128/ROC/AUC.mat');
tab(3,1) = AUC2x2;
tab(3,2) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG95_128/ROC/AUC.mat');
tab(4,1) = AUC2x2;
tab(4,2) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG90_128/ROC/AUC.mat');
tab(5,1) = AUC2x2;
tab(5,2) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni2x2/JPEG85_128/ROC/AUC.mat');
tab(6,1) = AUC2x2;
tab(6,2) = AUC8x8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/users/ferrara/Desktop/Simulazioni4x4/Sintetiche_128/ROC/AUC.mat');
tab(1,3) = AUC4x4;
tab(1,4) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni4x4/TIFF_128/ROC/AUC.mat');
tab(2,3) = AUC4x4;
tab(2,4) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni4x4/JPEG100_128/ROC/AUC.mat');
tab(3,3) = AUC4x4;
tab(3,4) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni4x4/JPEG95_128/ROC/AUC.mat');
tab(4,3) = AUC4x4;
tab(4,4) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni4x4/JPEG90_128/ROC/AUC.mat');
tab(5,3) = AUC4x4;
tab(5,4) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni4x4/JPEG85_128/ROC/AUC.mat');
tab(6,3) = AUC4x4;
tab(6,4) = AUC8x8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/users/ferrara/Desktop/Simulazioni8x8/Sintetiche_128/ROC/AUC.mat');
tab(1,5) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni8x8/TIFF_128/ROC/AUC.mat');
tab(2,5) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni8x8/JPEG100_128/ROC/AUC.mat');
tab(3,5) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni8x8/JPEG95_128/ROC/AUC.mat');
tab(4,5) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni8x8/JPEG90_128/ROC/AUC.mat');
tab(5,5) = AUC8x8;

load('/users/ferrara/Desktop/Simulazioni8x8/JPEG85_128/ROC/AUC.mat');
tab(6,5) = AUC8x8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(scenario,tab(:,1),'Color','b','LineWidth',1,'Marker','o');
hold
plot(scenario,tab(:,2),'Color','r','LineWidth',1,'Marker','s');
plot(scenario,tab(:,3),'Color','g','LineWidth',1,'Marker','x');
plot(scenario,tab(:,4),'Color',[0.75 0 0.75],'LineWidth',1,'Marker','.');
plot(scenario,tab(:,5),'Color',[0.87 0.49 0],'LineWidth',1,'Marker','+');
legend('2x2','2x2 cumulated onto 8x8','4x4','4x4 cumulated onto 8x8','8x8','Location', 'NorthEast');
xlabel('Scenario');
ylabel('AUC');


