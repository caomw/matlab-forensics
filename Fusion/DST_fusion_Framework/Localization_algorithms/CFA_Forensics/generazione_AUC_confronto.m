scenario = (1:1:6)';
tab = [];

figure;

load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\Sintetiche_128\ROC\AUC.mat');
tab(1,1) = AUC8x8;


load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\TIFF_128\ROC\AUC.mat');
tab(2,1) = AUC8x8;


load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\JPEG100_128\ROC\AUC.mat');
tab(3,1) = AUC8x8;


load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\JPEG95_128\ROC\AUC.mat');
tab(4,1) = AUC8x8;


load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\JPEG90_128\ROC\AUC.mat');
tab(5,1) = AUC8x8;


load('\\IAPP\users\ferrara\Desktop\Simulazioni8x8\JPEG85_128\ROC\AUC.mat');
tab(6,1) = AUC8x8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\Sintetiche_128\ROC\AUC.mat');
tab(1,2) = AUC8x8;


load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\TIFF_128\ROC\AUC.mat');
tab(2,2) = AUC8x8;


load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\JPEG100_128\ROC\AUC.mat');
tab(3,2) = AUC8x8;


load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\JPEG95_128\ROC\AUC.mat');
tab(4,2) = AUC8x8;


load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\JPEG90_128\ROC\AUC.mat');
tab(5,2) = AUC8x8;


load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\Dirik\8x8\JPEG85_128\ROC\AUC.mat');
tab(6,2) = AUC8x8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\Sintetiche_128\ROC\AUC.mat');
tab(1,3) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\TIFF_128\ROC\AUC.mat');
tab(2,3) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\JPEG100_128\ROC\AUC.mat');
tab(3,3) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\JPEG95_128\ROC\AUC.mat');
tab(4,3) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\JPEG90_128\ROC\AUC.mat');
tab(5,3) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherBlock\8x8\JPEG85_128\ROC\AUC.mat');
tab(6,3) = AUC8x8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\Sintetiche_128\ROC\AUC.mat');
tab(1,4) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\TIFF_128\ROC\AUC.mat');
tab(2,4) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\JPEG100_128\ROC\AUC.mat');
tab(3,4) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\JPEG95_128\ROC\AUC.mat');
tab(4,4) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\JPEG90_128\ROC\AUC.mat');
tab(5,4) = AUC8x8;

load('\\IAPP\Staff\bianchi\Matlab\Forensics\CFA\Results\GallagherLocal\8x8\JPEG85_128\ROC\AUC.mat');
tab(6,4) = AUC8x8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(scenario,tab(:,1),'Color','b','LineWidth',1,'Marker','o');
hold
plot(scenario,tab(:,2),'Color','r','LineWidth',1,'Marker','s');
plot(scenario,tab(:,3),'Color','g','LineWidth',1,'Marker','x');
plot(scenario,tab(:,4),'Color',[0.75 0 0.75],'LineWidth',1,'Marker','.');
legend('Our','DM','GC-B','GC-L','Location', 'NorthEast');
xlabel('Scenario');
ylabel('AUC');