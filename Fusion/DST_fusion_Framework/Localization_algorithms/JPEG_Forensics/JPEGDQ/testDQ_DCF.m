% evaluate performance of tampering localization on NA-JPEG images
% JPEGqualities1 = round(50:50/16:62);
JPEGqualities1 = round(50:5:100);
% JPEGqualities1 = round(75:50/16:87);
% JPEGqualities1 = round(88:50/16:99);
JPEGqualities2 = round(50:5:100);
% JPEGqualities1 = [50 75];
% JPEGqualities2 = [50 75];
if ispc
    outputfoldername = 'output/DCF';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
    addpath('../JPEGNA');
else
    outputfoldername = '/images/Prove/Bianchi/JPEGDQ/output/DCF';
    addpath('/staff/bianchi/Matlab/Forensics/jpeg_read')
    addpath('/staff/bianchi/Matlab/Forensics/JPEGNA');
end

test_size = [1024, 1024];
tamp_size = [256, 256];
% define mask for tampering (tamp_size)
mask = false([test_size 3]);
pt1 = floor((test_size - tamp_size)/2) + 1;
pt2 = pt1 + tamp_size - 1;
mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
mask = ~mask;
%
c2Y = [1 3 6 10 15];
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

% number of points on ROC
N = 1000;
% number of false positives and true positives in each test
FPmat = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmat = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

FPmat_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmat_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

FPmat_c = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmat_c = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

Q1err = zeros(length(JPEGqualities1),length(JPEGqualities2),c2Y(end));
alpha_avg = zeros(length(JPEGqualities1),length(JPEGqualities2),c2Y(end));

% number of positives (tampered pixels)
% PN = prod(tamp_size);
% number of negatives (original pixels)
% NN = prod(test_size) - PN;
   
% main index
iii = 0;

mask_block = filter2(ones(8), mask(:,:,1), 'valid');
mask_block  = mask_block(1:8:end, 1:8:end) > 32;
PNtot = sum(sum(mask_block));
NNtot = sum(sum(~mask_block));

for t1 = 1:length(JPEGqualities1)
    qf1 = JPEGqualities1(t1);
    q1ref = jpeg_qtable(qf1);
    display(['QF1 = ', num2str(qf1)]);

    for t2 = 1:length(JPEGqualities2)
        qf2 = JPEGqualities2(t2);

        directory = dir([outputfoldername, '/*_Q', num2str(qf1), '_Q', num2str(qf2), '*.jpg']);
        files = {directory.name};
        
        for ii=1:length(files)
            current_file = char(files(ii));
            im = jpeg_read([outputfoldername, '/', current_file]); 

            [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2Y(end));
            
%             figure
            for c = 1:length(c2Y)
                maskTampered = imfilter(sum(LLRmap(:,:,1:c),3), ones(3), 'symmetric', 'same');
                [FP, TP] = computeROC(-maskTampered, mask_block, N);
                FPmat(c,t1,t2,:) = FPmat(c,t1,t2,:) + reshape(FP,1,1,1,N);
                TPmat(c,t1,t2,:) = TPmat(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                % for testing purposes
%                 imagesc(-maskTampered, [-40 40]), axis square
%                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 pause
            end
                       
%             figure
            for c = 1:length(c2Y)
                maskTampered = imfilter(sum(LLRmap_s(:,:,1:c2Y(c)),3), ones(3), 'symmetric', 'same');
                [FP, TP] = computeROC(-maskTampered, mask_block, N);
                FPmat_s(c,t1,t2,:) = FPmat_s(c,t1,t2,:) + reshape(FP,1,1,1,N);
                TPmat_s(c,t1,t2,:) = TPmat_s(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                % for testing purposes
%                 imagesc(-maskTampered, [-40 40]), axis square
%                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 pause
            end
            
            Q1err(t1,t2,:) = Q1err(t1,t2,:) + reshape(q1table(coeff(1:c2Y(end))) ~= q1ref(coeff(1:c2Y(end))), 1, 1, c2Y(end));
            alpha_avg(t1,t2,:) = alpha_avg(t1,t2,:) + reshape(alphat(coeff(1:c2Y(end))), 1, 1, c2Y(end));
            
            LLRmap = getJmap_China(im, c2Y(end));
            
%             figure
            for c = 1:length(c2Y)
                maskTampered = imfilter(sum(LLRmap(:,:,1:c2Y(c)),3), ones(3), 'symmetric', 'same');
                [FP, TP] = computeROC(-maskTampered, mask_block, N);
                FPmat_c(c,t1,t2,:) = FPmat_c(c,t1,t2,:) + reshape(FP,1,1,1,N);
                TPmat_c(c,t1,t2,:) = TPmat_c(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                % for testing purposes
%                 imagesc(maskTampered, [-40 40]), axis square
%                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 pause
            end
            iii = iii + 1;
        end
    end
    
end

FPmat = FPmat / NNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);
TPmat = TPmat / PNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);

FPmat_s = FPmat_s / NNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);
TPmat_s = TPmat_s / PNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);

FPmat_c = FPmat_c / NNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);
TPmat_c = TPmat_c / PNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);

Q1err = Q1err / iii * length(JPEGqualities1) * length(JPEGqualities2);
alpha_avg = alpha_avg / iii * length(JPEGqualities1) * length(JPEGqualities2);

AUC = zeros(length(JPEGqualities1),length(JPEGqualities2),length(c2Y));
for t1 = 1:length(JPEGqualities1)
    for t2 = 1:length(JPEGqualities2)
        for c = 1:length(c2Y)
            AUC(t1,t2,c) = trapz(squeeze(FPmat(c,t1,t2,:)), squeeze(TPmat(c,t1,t2,:)));
        end
    end
end

AUC_s = zeros(length(JPEGqualities1),length(JPEGqualities2),length(c2Y));
for t1 = 1:length(JPEGqualities1)
    for t2 = 1:length(JPEGqualities2)
        for c = 1:length(c2Y)
            AUC_s(t1,t2,c) = trapz(squeeze(FPmat_s(c,t1,t2,:)), squeeze(TPmat_s(c,t1,t2,:)));
        end
    end
end

AUC_c = zeros(length(JPEGqualities1),length(JPEGqualities2),length(c2Y));
for t1 = 1:length(JPEGqualities1)
    for t2 = 1:length(JPEGqualities2)
        for c = 1:length(c2Y)
            AUC_c(t1,t2,c) = trapz(squeeze(FPmat_c(c,t1,t2,:)), squeeze(TPmat_c(c,t1,t2,:)));
        end
    end
end


save testDQoutputDCF_EM AUC FPmat TPmat AUC_s FPmat_s TPmat_s Q1err alpha_avg AUC_c FPmat_c TPmat_c
% AUC
% figure, plot(squeeze(FPmat(1,1,2,:)), squeeze(TPmat(1,1,2,:))), axis square
% figure, plot(squeeze(FPmat(3,1,2,:)), squeeze(TPmat(3,1,2,:))), axis square
% figure, plot(squeeze(FPmat(5,1,2,:)), squeeze(TPmat(5,1,2,:))), axis square
% 
% Q1err
% alpha_avg

quit