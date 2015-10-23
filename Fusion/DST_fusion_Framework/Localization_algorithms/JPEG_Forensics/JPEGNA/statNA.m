test_size = [1024, 1024];
% tamp_size = [256, 256];
% c1Y = 1;
% c2Y = 15;
% c2Yb = 15;
JPEGqualities = 50; %:5:95;
% JPEGqualities = round(50:50/16:95);
if ispc
    origfoldername='test';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
    origfoldername='/images/Prove/Bianchi/JPEGNA';
end
% number of tests for each image
Ntest = min(10,length(JPEGqualities));
% % number of false positives and true positives in each test
% FPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat = zeros(length(JPEGqualities),length(JPEGqualities),N);
% FPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat_old = zeros(length(JPEGqualities),length(JPEGqualities),N);
% % number of positives (tampered pixels)
% PN = prod(tamp_size);
% % number of negatives (original pixels)
% NN = prod(test_size) - PN;
% Nfiles = 0;
% PNtot = 0;
% NNtot = 0;
test_size = test_size + 7;

minH1_0 = [];
minH1_1 = [];
minH2_0 = [];
minH2_1 = [];


directory = dir([origfoldername, '/*.tif']);
files = {directory.name};
for i=1:length(files)
    if ~directory(i).isdir
%         Nfiles = Nfiles + 1;
        current_file = char(files(i));
        filename = [origfoldername, '/', current_file];
        
        I = imread(filename);
        [h,w,dummy] = size(I);
        % cut center part (test_size)
        p1 = floor(([h w] - test_size)/2) + 1;
        p2 = p1 + test_size - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        % define mask for tampering (tamp_size)
%         mask = false(size(Itest));
%         pt1 = floor((test_size - tamp_size)/2) + 1;
%         pt2 = pt1 + tamp_size - 1;
%         mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'same');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        Qflag = false(1, length(JPEGqualities)+1);
        Qflag(length(JPEGqualities)+1) = true;
        for k = 1:Ntest
            t = length(JPEGqualities) + 1;
            while Qflag(t) 
                t = ceil(length(JPEGqualities)*rand(1));
            end
            Qflag(t) = true;
            qf1 = JPEGqualities(t);
            jpg_filename = [filename(1:end-4), '_Q', num2str(qf1), '.jpg'];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            
            % no DQ-NA
            image = jpeg_read(jpg_filename); 
            
            [minH0, minH1, minH2] = minHNA_old(image,1,0);
             
            minH1_0 = [minH1_0 minH0];
            minH2_0 = [minH2_0 minH2];
            
            I2 = imread(jpg_filename);


            % DQ-NA, first case: qf2 == qf1
            qf2 = qf1;
            k1 = 1;
            k2 = 1;
            while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
                k1 = floor(8*rand(1)) + 1;
                k2 = floor(8*rand(1)) + 1;
            end
            jpg_t_filename = [jpg_filename(1:end-4), '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
            imwrite(I2(k1:end+k1-8,k2:end+k2-8,:), jpg_t_filename, 'jpg', 'Quality', qf2);
            image = jpeg_read(jpg_t_filename); 
            Q1 = image.quant_tables{1}(1,1);
            
            [minH0, minH1, minH2] = minHNA_old(image,1,Q1);
             
            minH2_1 = [minH2_1 minH2];
            
            % DQ-NA, second case: qf2 ~= qf1
            qf2 = 100;
            while qf2 == 100 || qf2 == qf1 
                qf2 = round(50+50/16*(t+floor((16-t)*rand(1))));
            end
            k1 = 1;
            k2 = 1;
            while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
                k1 = floor(8*rand(1)) + 1;
                k2 = floor(8*rand(1)) + 1;
            end
            jpg_t_filename = [jpg_filename(1:end-4), '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
            imwrite(I2(k1:end+k1-8,k2:end+k2-8,:), jpg_t_filename, 'jpg', 'Quality', qf2);
            image = jpeg_read(jpg_t_filename); 
            
            [minH0, minH1, minH2] = minHNA_old(image,1,Q1);
            
            minH1_1 = [minH1_1 minH1];
        end
    end
end

% save statNAoutQF2gtQF1 minH1_0 minH1_1 minH2_0 minH2_1
% quit

minH1_0 
minH1_1 
minH2_0 
minH2_1
