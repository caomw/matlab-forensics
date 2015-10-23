% evaluate performance of tampering localization on NA-JPEG images
% JPEGqualities = round(50:50/16:99);
% JPEGqualities = round(50:5:100);
JPEGqualities1 = (50:5:100);
JPEGqualities2 = (50:5:100);
if ispc
    origfoldername = {'test'}; %, 'test2'};
    outputfoldername = 'output';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
    addpath('../JPEGDQ');
else
%     origfoldername = {'/images/Prove/Bianchi/JPEGNA', '/images/Prove/Bianchi/JPEGDQ'};
    origfoldername = {'/images/Prove/Bianchi/JPEGDQ'};
    outputfoldername = '/images/Prove/Bianchi/JPEGNA/output2';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
    addpath('../JPEGDQ');
end

Nfiles = 0;
for ndir = 1:length(origfoldername)
        directory = dir([origfoldername{ndir}, '/*.tif']);
        Nfiles = Nfiles + length(directory);
end
display(['number of files in database ', num2str(Nfiles)])

test_size = [1024, 1024];
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

% number of false positives and true positives in each test
FPmatNA = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmatNA = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

FPmatNA_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);
TPmatNA_s = zeros(length(c2Y),length(JPEGqualities1),length(JPEGqualities2),N);

Q1errNA = zeros(length(JPEGqualities1),length(JPEGqualities2),c2Y(end));
kkerrNA = zeros(length(JPEGqualities1),length(JPEGqualities2));
alpha_avgNA = zeros(length(JPEGqualities1),length(JPEGqualities2),c2Y(end));


% make directory for single compression forgery scenario
if ~exist([outputfoldername, '/FFF'], 'dir')
    mkdir([outputfoldername, '/FFF']);
end

% define mask for tampering (tamp_size)
mask = false([test_size 3]);
mask(:,1:test_size(2)/2,:) = true;

mask_block = filter2(ones(8), mask(:,:,1), 'valid');
mask_block  = mask_block(1:8:end, 1:8:end) > 32;
PNtot = sum(sum(mask_block));
NNtot = sum(sum(~mask_block));
    
% main index
iii = 0;

for ndir = 1:length(origfoldername);
    directory = dir([origfoldername{ndir}, '/*.tif']);
    files = {directory.name};

    for ii=1:length(files)
        current_file = char(files(ii));
        filename = [origfoldername{ndir}, '/', current_file];
        display(['iii = ', num2str(iii)]);

        I = imread(filename);
        [h,w,dummy] = size(I);
        % cut center part (test_size), ensure aligned 8x8 blocks
        p1 = floor(([h w] - test_size)/16)*8 + 1;
        p2 = p1 + test_size - 1;
        ItestNA = I(p1(1):p2(1)+7,p1(2):p2(2)+7,:);
        k1 = 1;
        k2 = 1;
        while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
            k1 = floor(8*rand(1)) + 1;
            k2 = floor(8*rand(1)) + 1;
        end
        ItestDQ = I(p1(1)+k1-1:p2(1)+k1-1,p1(2)+k2-1:p2(2)+k2-1,:);
                
        k1ref = mod(9-k1,8)+1;
        k2ref = mod(9-k2,8)+1;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'valid');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for t1 = 1:length(JPEGqualities1)
            qf1 = JPEGqualities1(t1);
            q1ref = jpeg_qtable(qf1);
%             display(['QF1 = ', num2str(qf1)]);
            jpg_filenameDQ = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
            jpg_filenameNA = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
            jpg_filename_FFF = [outputfoldername, '/FFF/', current_file(1:end-4), '_Q', num2str(qf1)];
            imwrite(ItestDQ, jpg_filenameDQ, 'jpg', 'Quality', qf1);
            imwrite(ItestNA, jpg_filenameNA, 'jpg', 'Quality', qf1);
            I2DQ = imread(jpg_filenameDQ);
            I2NA = imread(jpg_filenameNA);
            % insert tampering
%             I2(mask) = Itest(mask);
            
            for t2 = 1:length(JPEGqualities2)
                qf2 = JPEGqualities2(t2);
                
                
                jpg_t_filename_FFF = [jpg_filename_FFF, '_Q', num2str(qf2), '_NADQ_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
                
                Iorig = I2NA(k1:end+k1-8,k2:end+k2-8,:);
                Icomp = I2DQ;
                I_FFF = Iorig(mask);
                % generate forged image according to FFF scenario
                Icomp(mask) = I_FFF;
                imwrite(Icomp, jpg_t_filename_FFF, 'jpg', 'Quality', qf2);
               
                im = jpeg_read(jpg_t_filename_FFF); 
                
                [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im, 1, c2Y(end));
            
    %             figure
                for c = 1:length(c2Y)
                    maskTampered = imfilter(sum(LLRmap(:,:,1:c),3), ones(3), 'symmetric', 'same');
                    [FP, TP] = computeROC(-maskTampered, mask_block, N);
                    FPmat(c,t1,t2,:) = FPmat(c,t1,t2,:) + reshape(FP,1,1,1,N);
                    TPmat(c,t1,t2,:) = TPmat(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                    % for testing purposes
%                     imagesc(-maskTampered, [-40 40]), axis square
%                     title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                     pause
                end

    %             figure
                for c = 1:length(c2Y)
                    maskTampered = imfilter(sum(LLRmap_s(:,:,1:c2Y(c)),3), ones(3), 'symmetric', 'same');
                    [FP, TP] = computeROC(-maskTampered, mask_block, N);
                    FPmat_s(c,t1,t2,:) = FPmat_s(c,t1,t2,:) + reshape(FP,1,1,1,N);
                    TPmat_s(c,t1,t2,:) = TPmat_s(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                    % for testing purposes
%                     imagesc(-maskTampered, [-40 40]), axis square
%                     title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                     pause
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
%                     imagesc(maskTampered, [-40 40]), axis square
%                     title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                     pause
                end

                [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im, 1, c2Y(end));

    %             figure
                for c = 1:length(c2Y)
                    maskTampered = smooth_unshift(sum(LLRmap(:,:,1:c2Y(c)),3),k1e,k2e);
                    [FP, TP] = computeROC(maskTampered, mask_block, N);
                    FPmatNA(c,t1,t2,:) = FPmatNA(c,t1,t2,:) + reshape(FP,1,1,1,N);
                    TPmatNA(c,t1,t2,:) = TPmatNA(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                    % for testing purposes
    %                 imagesc(maskTampered, [-40 40]), axis square
    %                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
    %                 pause
                end

    %             figure
                for c = 1:length(c2Y)
                    maskTampered = smooth_unshift(sum(LLRmap_s(:,:,1:c2Y(c)),3),k1e,k2e);
                    [FP, TP] = computeROC(maskTampered, mask_block, N);
                    FPmatNA_s(c,t1,t2,:) = FPmatNA_s(c,t1,t2,:) + reshape(FP,1,1,1,N);
                    TPmatNA_s(c,t1,t2,:) = TPmatNA_s(c,t1,t2,:) + reshape(TP,1,1,1,N);    
                    % for testing purposes
%                     imagesc(maskTampered, [-40 40]), axis square
%                     title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                     pause
                end

                Q1errNA(t1,t2,:) = Q1errNA(t1,t2,:) + reshape(q1table(coeff(1:c2Y(end))) ~= q1ref(coeff(1:c2Y(end))), 1, 1, c2Y(end));
                kkerrNA(t1,t2) = kkerrNA(t1,t2) + (k1e ~= k1ref || k2e ~= k2ref);
                alpha_avgNA(t1,t2,:) = alpha_avgNA(t1,t2,:) + reshape(alphat(coeff(1:c2Y(end))), 1, 1, c2Y(end));
%                
                iii = iii + 1;
            end
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

FPmatNA = FPmatNA / NNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);
TPmatNA = TPmatNA / PNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);

FPmatNA_s = FPmatNA_s / NNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);
TPmatNA_s = TPmatNA_s / PNtot / iii * length(JPEGqualities1) * length(JPEGqualities2);

Q1errNA = Q1errNA / iii * length(JPEGqualities1) * length(JPEGqualities2);
kkerrNA = kkerrNA / iii * length(JPEGqualities1) * length(JPEGqualities2);
alpha_avgNA = alpha_avgNA / iii * length(JPEGqualities1) * length(JPEGqualities2);

AUCNA = zeros(length(JPEGqualities1),length(JPEGqualities2),length(c2Y));
for t1 = 1:length(JPEGqualities1)
    for t2 = 1:length(JPEGqualities2)
        for c = 1:length(c2Y)
            AUCNA(t1,t2,c) = trapz(squeeze(FPmatNA(c,t1,t2,:)), squeeze(TPmatNA(c,t1,t2,:)));
        end
    end
end

AUCNA_s = zeros(length(JPEGqualities1),length(JPEGqualities2),length(c2Y));
for t1 = 1:length(JPEGqualities1)
    for t2 = 1:length(JPEGqualities2)
        for c = 1:length(c2Y)
            AUCNA_s(t1,t2,c) = trapz(squeeze(FPmatNA_s(c,t1,t2,:)), squeeze(TPmatNA_s(c,t1,t2,:)));
        end
    end
end

% AUC(:,:,length(c2Y))
% AUC_s(:,:,length(c2Y))
% AUC_c(:,:,length(c2Y))
% AUCNA(:,:,length(c2Y))
% AUCNA_s(:,:,length(c2Y))
save testDQNAoutputFFF_EM AUC FPmat TPmat AUC_s FPmat_s TPmat_s Q1err alpha_avg AUC_c FPmat_c TPmat_c
save testNADQoutputFFF_EM AUCNA FPmatNA TPmatNA AUCNA_s FPmatNA_s TPmatNA_s Q1errNA kkerrNA alpha_avgNA

quit