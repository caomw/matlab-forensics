
% number of points on ROC
N = 1000;
% number of JPEG qualities
NJQ = 16;
% number C
NC = 5;
% number of false positives and true positives in each test
FPmat_EM = zeros(NC,NJQ,NJQ,N);
TPmat_EM = zeros(NC,NJQ,NJQ,N);
AUC_EM = zeros(NJQ,NJQ,NC);

load testNAoutputDCF01
FPmat_EM(:,1:4,:,:) = FPmat;
TPmat_EM(:,1:4,:,:) = TPmat;
AUC_EM(1:4,:,:) = AUC;
load testNAoutputDCF02
FPmat_EM(:,5:8,:,:) = FPmat;
TPmat_EM(:,5:8,:,:) = TPmat;
AUC_EM(5:8,:,:) = AUC;
load testNAoutputDCF03
FPmat_EM(:,9:12,:,:) = FPmat;
TPmat_EM(:,9:12,:,:) = TPmat;
AUC_EM(9:12,:,:) = AUC;
load testNAoutputDCF04
FPmat_EM(:,13:16,:,:) = FPmat;
TPmat_EM(:,13:16,:,:) = TPmat;
AUC_EM(13:16,:,:) = AUC;

% figure, imagesc(AUC_EM(:,:,1), [0.5 1])
% figure, imagesc(AUC_EM(:,:,2), [0.5 1])
% figure, imagesc(AUC_EM(:,:,3), [0.5 1])
% figure, imagesc(AUC_EM(:,:,4), [0.5 1])
% figure, imagesc(AUC_EM(:,:,5), [0.5 1])

save testNAoutputDCF_EM AUC_EM FPmat_EM TPmat_EM