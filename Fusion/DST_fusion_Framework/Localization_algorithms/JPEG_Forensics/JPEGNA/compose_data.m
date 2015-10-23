load testNAoutputSCF_EM01

AUC2 = zeros(11,11,5);
% number of points on ROC
N = 1000;
% number of false positives and true positives in each test
FPmat2 = zeros(5,11,11,N);
TPmat2 = zeros(5,11,11,N);

AUC_s2 = zeros(11,11,5);
% number of points on ROC
% number of false positives and true positives in each test
FPmat_s2 = zeros(5,11,11,N);
TPmat_s2 = zeros(5,11,11,N);

AUC2(1:6,:,:) = AUC;
FPmat2(:,1:6,:,:) = FPmat;
TPmat2(:,1:6,:,:) = TPmat;

AUC_s2(1:6,:,:) = AUC_s;
FPmat_s2(:,1:6,:,:) = FPmat_s;
TPmat_s2(:,1:6,:,:) = TPmat_s;

load testNAoutputSCF_EM02

AUC2(7:11,:,:) = AUC;
FPmat2(:,7:11,:,:) = FPmat;
TPmat2(:,7:11,:,:) = TPmat;

AUC_s2(7:11,:,:) = AUC_s;
FPmat_s2(:,7:11,:,:) = FPmat_s;
TPmat_s2(:,7:11,:,:) = TPmat_s;

AUC = AUC2;
FPmat = FPmat2;
TPmat = TPmat2;

AUC_s = AUC_s2;
FPmat_s = FPmat_s2;
TPmat_s = TPmat_s2;

save testNAoutputSCF_EM AUC FPmat TPmat AUC_s FPmat_s TPmat_s

load testNAoutputDCF_EM01

AUC2 = zeros(11,11,5);
% number of points on ROC
N = 1000;
% number of false positives and true positives in each test
FPmat2 = zeros(5,11,11,N);
TPmat2 = zeros(5,11,11,N);

AUC_s2 = zeros(11,11,5);
% number of points on ROC
% number of false positives and true positives in each test
FPmat_s2 = zeros(5,11,11,N);
TPmat_s2 = zeros(5,11,11,N);

AUC2(1:6,:,:) = AUC;
FPmat2(:,1:6,:,:) = FPmat;
TPmat2(:,1:6,:,:) = TPmat;

AUC_s2(1:6,:,:) = AUC_s;
FPmat_s2(:,1:6,:,:) = FPmat_s;
TPmat_s2(:,1:6,:,:) = TPmat_s;

load testNAoutputDCF_EM02

AUC2(7:11,:,:) = AUC;
FPmat2(:,7:11,:,:) = FPmat;
TPmat2(:,7:11,:,:) = TPmat;

AUC_s2(7:11,:,:) = AUC_s;
FPmat_s2(:,7:11,:,:) = FPmat_s;
TPmat_s2(:,7:11,:,:) = TPmat_s;

AUC = AUC2;
FPmat = FPmat2;
TPmat = TPmat2;

AUC_s = AUC_s2;
FPmat_s = FPmat_s2;
TPmat_s = TPmat_s2;

save testNAoutputDCF_EM AUC FPmat TPmat AUC_s FPmat_s TPmat_s