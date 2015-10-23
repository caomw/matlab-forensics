test_size = [1024, 1024];
tamp_size = [256, 256];
c1Y = 1;
c2Y = 15;
c2Yb = 15;
JPEGqualities = 50:5:100;
% JPEGqualities = [50 75];
if ispc
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGDQ';
    origfoldername='test';
    outputfoldername = 'output';
else
    origfoldername='/images/Prove/Bianchi/JPEGDQ';
    outputfoldername = '/images/Prove/Bianchi/JPEGDQ/output';
end
% % number of points on ROC
% N = 100;
% % number of false positives and true positives in each test
% FPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% FPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% % number of positives (tampered pixels)
% PN = prod(tamp_size);
% % number of negatives (original pixels)
% NN = prod(test_size) - PN;
Nfiles = 0;
% PNtot = 0;
% NNtot = 0;
% make directory for double compression forgery scenario
if ~exist([outputfoldername, '/DCF'], 'dir')
    mkdir([outputfoldername, '/DCF']);
end

directory = dir([origfoldername, '/*.tif']);
files = {directory.name};
for i=1:length(files)
    if ~directory(i).isdir
        Nfiles = Nfiles + 1;
        current_file = char(files(i));
        filename = [origfoldername, '/', current_file];
        
        I = imread(filename);
        [h,w,dummy] = size(I);
        % cut center part (test_size)
        p1 = floor(([h w] - test_size)/2) + 1;
        p2 = p1 + test_size - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        % define mask for tampering (tamp_size)
        mask = false(size(Itest));
        pt1 = floor((test_size - tamp_size)/2) + 1;
        pt2 = pt1 + tamp_size - 1;
        mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'same');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for k1 = 1:length(JPEGqualities)
            qf1 = JPEGqualities(k1);
            jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
%             jpg_filename_SCF = [outputfoldername, '/SCF/', current_file(1:end-4), '_Q', num2str(qf1)];
            jpg_filename_DCF = [outputfoldername, '/DCF/', current_file(1:end-4), '_Q', num2str(qf1)];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            I1 = Itest;
            I2 = imread(jpg_filename);
            % insert tampering
            % SCF
            % I2(mask) = Itest(mask);
            % DCF
            I1(mask) = I2(mask);
            
            for k2 = 1:length(JPEGqualities)
                qf2 = JPEGqualities(k2);
                jpg_t_filename = [jpg_filename_DCF, '_Q', num2str(qf2), '.jpg'];
                % SCF
                % imwrite(I2, jpg_t_filename, 'jpg', 'Quality', qf2);
                % DCF
                imwrite(I1, jpg_t_filename, 'jpg', 'Quality', qf2);
                pause(0.05);
%                 image = jpeg_read(jpg_t_filename); 
                
%                 maskTampered = getJmap(image, 1, c1Y, c2Y);
%                 maskTampered = medfilt2(maskTampered, [5 5], 'symmetric');
%                 [FP, TP] = computeROC(maskTampered, mask_block, N);
%                 FPmat(k1,k2,:) = FPmat(k1,k2,:) + reshape(FP,1,1,N);
%                 TPmat(k1,k2,:) = TPmat(k1,k2,:) +  reshape(TP,1,1,N);
%                 % for testing purposes
% %                 maskTampered(1,1) = 0;
% %                 maskTampered(end,end) = 1;
% %                 figure
% %                 subplot(1,2,1), imagesc(maskTampered)
% %                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 
%                 maskTampered = detectionTamperingLCI(image, c2Yb);
%                 maskTampered = medfilt2(maskTampered, [5 5], 'symmetric');
%                 [FP, TP] = computeROC(maskTampered, mask_block, N);
%                 FPmat_old(k1,k2,:) = FPmat_old(k1,k2,:) + reshape(FP,1,1,N);
%                 TPmat_old(k1,k2,:) = TPmat_old(k1,k2,:) + reshape(TP,1,1,N);
%                 % for testing purposes
% %                 maskTampered(1,1) = 0;
% %                 maskTampered(end,end) = 1;
% %                 subplot(1,2,2), imagesc(maskTampered)
% %                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
% %                 pause
            end
        end
    end
end

% FPmat = FPmat / NNtot;
% TPmat = TPmat / PNtot;
% FPmat_old = FPmat_old / NNtot;
% TPmat_old = TPmat_old / PNtot;
% 
% AUC = zeros(length(JPEGqualities));
% AUC_old = zeros(length(JPEGqualities));
% for k1 = 1:length(JPEGqualities)
%     for k2 = 1:length(JPEGqualities)
%         AUC(k1,k2) = trapz(squeeze(FPmat(k1,k2,:)), squeeze(TPmat(k1,k2,:)));
%         AUC_old(k1,k2) = trapz(squeeze(FPmat_old(k1,k2,:)), squeeze(TPmat_old(k1,k2,:)));
%     end
% end
% 
% save testDQoutput AUC AUC_old FPmat TPmat FPmat_old TPmat_old
% % AUC
% % AUC_old
