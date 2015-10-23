test_size = [1024, 1024];
tamp_size = [256, 256];
c1Y = 1;
c2Y = 15;
c2Yb = 15;
JPEGqualities = 50:5:100;
% JPEGqualities = [75 80];
if ispc
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGDQ';
    origfoldername='test';
    outputfoldername = 'output';
else
    origfoldername='/images/Prove/Bianchi/JPEGDQ';
    outputfoldername = '/images/Prove/Bianchi/JPEGDQ/output';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
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
if ~exist([outputfoldername, '/FFF'], 'dir')
    mkdir([outputfoldername, '/FFF']);
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
        mask(:,1:test_size(2)/2,:) = true;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'same');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for k1 = 1:length(JPEGqualities)
            qf1 = JPEGqualities(k1);
            jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
            jpg_filename_FFF = [outputfoldername, '/FFF/', current_file(1:end-4), '_Q', num2str(qf1)];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            
            I2 = imread(jpg_filename);
            % insert tampering
            % FFF
            I2(mask) = Itest(mask);
            
            for k2 = 1:length(JPEGqualities)
                qf2 = JPEGqualities(k2);
                jpg_t_filename = [jpg_filename_FFF, '_Q', num2str(qf2), '.jpg'];
                
                % FFF
                imwrite(I2, jpg_t_filename, 'jpg', 'Quality', qf2);
%                 pause(0.05);
%                 
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
quit