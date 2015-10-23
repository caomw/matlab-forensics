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
if ~exist([outputfoldername, '/FFF'], 'dir')
    mkdir([outputfoldername, '/FFF']);
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
        mask(:,1:test_size(2)/2,:) = true;
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'valid');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for t1 = 1:length(JPEGqualities)
            qf1 = JPEGqualities(t1);
            jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
            jpg_filename_FFF = [outputfoldername, '/FFF/', current_file(1:end-4), '_Q', num2str(qf1)];
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
                jpg_t_filename_FFF = [jpg_filename_FFF, '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
                
                Iorig = Itest(k1:end+k1-8,k2:end+k2-8,:);
                Icomp = I2(k1:end+k1-8,k2:end+k2-8,:);
                I_FFF = Iorig(mask);
                % generate forged image according to FFF scenario
                Icomp(mask) = I_FFF;
                imwrite(Icomp, jpg_t_filename_FFF, 'jpg', 'Quality', qf2);
               
%                
            end
        end
        iii = iii + 1;
    end
end

quit