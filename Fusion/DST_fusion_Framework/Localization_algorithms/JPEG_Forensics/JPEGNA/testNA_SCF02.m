% evaluate performance of tampering localization on NA-JPEG images
% JPEGqualities1 = round(50:50/16:62);
JPEGqualities1 = round(80:5:100);
% JPEGqualities1 = round(75:50/16:87);
% JPEGqualities1 = round(88:50/16:99);
JPEGqualities2 = round(50:5:100);
% JPEGqualities1 = [50 75];
% JPEGqualities2 = [50 75];
if ispc
    outputfoldername = 'output/SCF';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
    outputfoldername = '/images/Prove/Bianchi/JPEGNA/output/SCF';
    addpath('/staff/bianchi/Matlab/Forensics/jpeg_read')
end

test_size = [1024, 1024];
tamp_size = [256, 256];
c2Y = [1 3 6 10 15];

% number of points on ROC
N = 1000;
% number of false positives and true positives in each test
FPmat = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmat = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

FPmat_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmat_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

% number of positives (tampered pixels)
% PN = prod(tamp_size);
% number of negatives (original pixels)
% NN = prod(test_size) - PN;
   
% main index
iii = 0;

% define mask for tampering (tamp_size)
mask = false([test_size 3]);
pt1 = floor((test_size - tamp_size)/2) + 1;
pt2 = pt1 + tamp_size - 1;
mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;

mask_block = filter2(ones(8), mask(:,:,1), 'valid');
mask_block  = mask_block(1:8:end, 1:8:end) > 32;
PNtot = sum(sum(mask_block));
NNtot = sum(sum(~mask_block));

for t1 = 1:length(JPEGqualities1)
    qf1 = JPEGqualities1(t1);

    for t2 = 1:length(JPEGqualities2)
        qf2 = JPEGqualities2(t2);

        directory = dir([outputfoldername, '/*_Q', num2str(qf1), '_Q', num2str(qf2), '*.jpg']);
        files = {directory.name};

        for ii=1:length(files)
            current_file = char(files(ii));

            kidx = regexp(current_file, 'NA_[0-7]_[0-7]');
            k1 = str2double(current_file(kidx+3)) + 1;
            k2 = str2double(current_file(kidx+5)) + 1;
            k1e = mod(9-k1,8)+1;
            k2e = mod(9-k2,8)+1;

            im = jpeg_read([outputfoldername, '/', current_file]); 

            LLRmap = getJmapNA_EM(im, 1, c2Y(end), k1e, k2e, false);
            
%             figure
            for c = 1:length(c2Y)
                maskTampered = smooth_unshift(sum(LLRmap(:,:,1:c2Y(c)),3),k1e,k2e);
                [FP, TP] = computeROC(-maskTampered, mask_block, N);
                FPmat(c,t1,t2,:) = FPmat(c,t1,t2,:) + reshape(FP,1,1,1,N);
                TPmat(c,t1,t2,:) = TPmat(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                % for testing purposes
%                 imagesc(-maskTampered, [-40 40]), axis square
%                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 pause
            end
            
            LLRmap = getJmapNA_EM(im, 1, c2Y(end), k1e, k2e, true);
            
%             figure
            for c = 1:length(c2Y)
                maskTampered = smooth_unshift(sum(LLRmap(:,:,1:c2Y(c)),3),k1e,k2e);
                [FP, TP] = computeROC(-maskTampered, mask_block, N);
                FPmat_s(c,t1,t2,:) = FPmat_s(c,t1,t2,:) + reshape(FP,1,1,1,N);
                TPmat_s(c,t1,t2,:) = TPmat_s(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                % for testing purposes
%                 imagesc(-maskTampered, [-40 40]), axis square
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

save testNAoutputSCF_EM02 AUC FPmat TPmat AUC_s FPmat_s TPmat_s
% AUC
% figure, plot(squeeze(FPmat(1,1,2,:)), squeeze(TPmat(1,1,2,:))), axis square
% figure, plot(squeeze(FPmat(3,1,2,:)), squeeze(TPmat(3,1,2,:))), axis square
% figure, plot(squeeze(FPmat(5,1,2,:)), squeeze(TPmat(5,1,2,:))), axis square

quit