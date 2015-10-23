% evaluate performance of tampering localization on NA-JPEG images
% JPEGqualities = round(50:50/16:99);
% JPEGqualities1 = round(50:5:95);
% JPEGqualities2 = round(50:5:100);
JPEGqualities1 = 95;
JPEGqualities2 = 50;
if ispc
%     origfoldername = {'test'}; %, 'test2'};
%     outputfoldername = 'output';
    origfoldername={'\\GIOTTO\Images\Prove\Bianchi\JPEGDQ'};
    outputfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA\output';
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
% define mask for tampering (tamp_size)
mask = false([test_size 3]);
pt1 = floor((test_size - tamp_size)/2) + 1;
pt2 = pt1 + tamp_size - 1;
mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
mask = ~mask;

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

% make directory for single compression forgery scenario
if ~exist([outputfoldername, '/DCF2'], 'dir')
    mkdir([outputfoldername, '/DCF2']);
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
        % cut random part (test_size), ensure aligned 8x8 blocks
        p1(1) = floor(rand(1)*(h - test_size(1) - 8)/8)*8 + 1;
        p1(2) = floor(rand(1)*(w - test_size(2) - 8)/8)*8 + 1;
        p2 = p1 + test_size + 7 - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        
%         mask_block = filter2(ones(8), mask(:,:,1), 'valid');
%         mask_block  = mask_block(1:8:end, 1:8:end) > 32;
%         PNtot = PNtot + sum(sum(mask_block));
%         NNtot = NNtot + sum(sum(~mask_block));

        for t1 = 1:length(JPEGqualities1)
            qf1 = JPEGqualities1(t1);
            jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
            jpg_filename_FFF = [outputfoldername, '/DCF2/', current_file(1:end-4), '_Q', num2str(qf1)];
            imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
            I2 = imread(jpg_filename);
            % insert tampering
%             I2(mask) = Itest(mask);
            
            for t2 = 1:length(JPEGqualities2)
                qf2 = JPEGqualities2(t2);
                
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

% quit