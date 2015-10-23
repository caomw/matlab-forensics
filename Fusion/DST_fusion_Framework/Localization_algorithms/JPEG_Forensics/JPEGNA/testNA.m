% evaluate performance of tampering localization on NA-JPEG images
% JPEGqualities = round(50:50/16:99);
JPEGqualities = round(50:5:100);
% JPEGqualities = [50 75];
if ispc
    origfoldername = {'test'}; %, 'test2'};
    outputfoldername = 'output';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
%     origfoldername = {'/images/Prove/Bianchi/JPEGNA', '/images/Prove/Bianchi/JPEGDQ'};
    origfoldername = {'/images/Prove/Bianchi/JPEGDQ'};
    outputfoldername = '/images/Prove/Bianchi/JPEGNA/output';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
end

Nfiles = 0;
for ndir = 1:length(origfoldername)
        directory = dir([origfoldername{ndir}, '/*.tif']);
        Nfiles = Nfiles + length(directory);
end
display(['number of files in database ', num2str(Nfiles)])

test_size = [1024, 1024];
tamp_size = [256, 256];
c2Y = 1;

% % number of points on ROC
% N = 1000;
% % number of false positives and true positives in each test
% FPmat_SCF = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat_SCF = zeros(length(JPEGqualities),length(JPEGqualities),N);
% FPmat_DCF = zeros(length(JPEGqualities),length(JPEGqualities),N);
% TPmat_DCF = zeros(length(JPEGqualities),length(JPEGqualities),N);

% number of positives (tampered pixels)
% PN = prod(tamp_size);
% number of negatives (original pixels)
% NN = prod(test_size) - PN;
PNtot = 0;
NNtot = 0;

% make directory for single compression forgery scenario
if ~exist([outputfoldername, '/SCF'], 'dir')
    mkdir([outputfoldername, '/SCF']);
end
% make directory for double compression forgery scenario
if ~exist([outputfoldername, '/DCF'], 'dir')
    mkdir([outputfoldername, '/DCF']);
end
    
% main index
iii = 1;

for ndir = 1:length(origfoldername);
    directory = dir([origfoldername{ndir}, '/*.tif']);
    files = {directory.name};

    for ii=1:length(files)
        current_file = char(files(ii));
        filename = [origfoldername{ndir}, '/', current_file];

        I = imread(filename);
        [h,w,dummy] = size(I);
        % cut center part (test_size), ensure aligned 8x8 blocks
        p1 = floor(([h w] - test_size)/16)*8 + 1;
        p2 = p1 + test_size + 7 - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        % define mask for tampering (tamp_size)
        mask = false([test_size 3]);
        pt1 = floor((test_size - tamp_size)/2) + 1;
        pt2 = pt1 + tamp_size - 1;
        mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
        
        mask_block = filter2(ones(8), mask(:,:,1), 'valid');
        mask_block  = mask_block(1:8:end, 1:8:end) > 32;
        PNtot = PNtot + sum(sum(mask_block));
        NNtot = NNtot + sum(sum(~mask_block));

        for t1 = 1:length(JPEGqualities)
            qf1 = JPEGqualities(t1);
            jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
            jpg_filename_SCF = [outputfoldername, '/SCF/', current_file(1:end-4), '_Q', num2str(qf1)];
            jpg_filename_DCF = [outputfoldername, '/DCF/', current_file(1:end-4), '_Q', num2str(qf1)];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            I2 = imread(jpg_filename);
            % insert tampering
%             I2(mask) = Itest(mask);
            
            for t2 = 1:length(JPEGqualities)
                qf2 = JPEGqualities(t2);
                
                k1 = 1;
                k2 = 1;
                while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
                    k1 = floor(8*rand(1)) + 1;
                    k2 = floor(8*rand(1)) + 1;
                end
                jpg_t_filename_SCF = [jpg_filename_SCF, '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
                jpg_t_filename_DCF = [jpg_filename_DCF, '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
                               
                Iorig = Itest(k1:end+k1-8,k2:end+k2-8,:);
                Icomp = I2(k1:end+k1-8,k2:end+k2-8,:);
                I_SCF = Iorig(mask);
                I_DCF = Icomp(mask);
                % generate forged image according to SCF scenario
                Icomp(mask) = I_SCF;
                imwrite(Icomp, jpg_t_filename_SCF, 'jpg', 'Quality', qf2);
                % generate forged image according to DCF scenario
                Iorig(mask) = I_DCF;
                imwrite(Iorig, jpg_t_filename_DCF, 'jpg', 'Quality', qf2);
                
%                 % analyze SCF
%                 im = jpeg_read(jpg_t_filename_SCF); 
%                 
%                 maskTampered = getJmapNA(im, 1, c2Y);
%              
%                 [FP, TP] = computeROC(-maskTampered, mask_block, N);
%                 FPmat_SCF(t1,t2,:) = FPmat_SCF(t1,t2,:) + reshape(FP,1,1,N);
%                 TPmat_SCF(t1,t2,:) = TPmat_SCF(t1,t2,:) +  reshape(TP,1,1,N);
%                 % for testing purposes
% %                 figure
% %                 subplot(1,2,1), imagesc(-maskTampered, [-40 40]), axis square
% %                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
%                 
%                 % analyze SCF
%                 im = jpeg_read(jpg_t_filename_DCF); 
%                 
%                 maskTampered = getJmapNA(im, 1, c2Y);
%                 
%                 [FP, TP] = computeROC(maskTampered, mask_block, N);
%                 FPmat_DCF(t1,t2,:) = FPmat_DCF(t1,t2,:) + reshape(FP,1,1,N);
%                 TPmat_DCF(t1,t2,:) = TPmat_DCF(t1,t2,:) + reshape(TP,1,1,N);
%                 % for testing purposes
% %                 subplot(1,2,2), imagesc(maskTampered, [-40 40]), axis square
% %                 title(['qf1 = ', num2str(qf1), '; qf2 = ', num2str(qf2)])
% %                 pause
            end
        end
        iii = iii + 1;
    end
end

% FPmat_SCF = FPmat_SCF / NNtot;
% TPmat_SCF = TPmat_SCF / PNtot;
% FPmat_DCF = FPmat_DCF / NNtot;
% TPmat_DCF = TPmat_DCF / PNtot;
% 
% AUC_SCF = zeros(length(JPEGqualities));
% AUC_DCF = zeros(length(JPEGqualities));
% for t1 = 1:length(JPEGqualities)
%     for t2 = 1:length(JPEGqualities)
%         AUC_SCF(t1,t2) = trapz(squeeze(FPmat_SCF(t1,t2,:)), squeeze(TPmat_SCF(t1,t2,:)));
%         AUC_DCF(t1,t2) = trapz(squeeze(FPmat_DCF(t1,t2,:)), squeeze(TPmat_DCF(t1,t2,:)));
%     end
% end
% 
% save testNAoutput AUC_SCF AUC_DCF FPmat_SCF TPmat_SCF FPmat_DCF TPmat_DCF
% % AUC_SCF
% % AUC_DCF
% % figure, plot(squeeze(FPmat_SCF(1,2,:)), squeeze(TPmat_SCF(1,2,:))), axis square
% % figure, plot(squeeze(FPmat_DCF(1,2,:)), squeeze(TPmat_DCF(1,2,:))), axis square
% 
% quit