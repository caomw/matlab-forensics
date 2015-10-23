
JPEGqualities = round(50:50/16:99);
% JPEGqualities = round(50:50/16:54);
% JPEGqualities = [50 63 75];
if ispc
    origfoldername = {'test', 'test2'};
    outputfoldername = 'output';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
    origfoldername = {'/images/Prove/Bianchi/JPEGNA', '/images/Prove/Bianchi/JPEGDQ'};
    outputfoldername = '/images/Prove/Bianchi/JPEGNA/output';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
end

Nfiles = 0;
for ndir = 1:length(origfoldername)
        directory = dir([origfoldername{ndir}, '/*.tif']);
        Nfiles = Nfiles + length(directory);
end
display(['number of files in database ', num2str(Nfiles)])
        
% test_sizes = [128, 256, 512, 1024];
% test_sizes = [128, 256];
test_sizes = [1024];

for ts = test_sizes
    test_size = [ts, ts];
    test_size = test_size + 7;
    
    if ~exist([outputfoldername, '/', num2str(ts)], 'dir')
        mkdir([outputfoldername, '/', num2str(ts)]);
    end
    display(['testing size ', num2str(ts)])
    
    minH1_0 = zeros(length(JPEGqualities),2*Nfiles);
    minH1_1 = zeros(length(JPEGqualities),length(JPEGqualities),Nfiles);
    minH2_0 = zeros(length(JPEGqualities),Nfiles);
    minH2_1 = zeros(length(JPEGqualities),Nfiles);
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
            % cut center part (test_size)
            p1 = floor(([h w] - test_size)/2) + 1;
            p2 = p1 + test_size - 1;
            Itest = I(p1(1):p2(1),p1(2):p2(2),:);

            for t1 = 1:length(JPEGqualities)

                qf1 = JPEGqualities(t1);
                jpg_filename = [outputfoldername, '/', num2str(ts), '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
                imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);

                % no DQ-NA 
                image = jpeg_read(jpg_filename); 

                [minH1, minH2] = minHNA(image,1);

                minH1_0(t1,iii) = minH1;
                minH2_0(t1,iii) = minH2;

                for t2 = 1:length(JPEGqualities)

                    qf2 = JPEGqualities(t2);
                    I2 = imread(jpg_filename);

                    k1 = 1;
                    k2 = 1;
                    while (k1 == 1 && k2 == 1) || k1 > 8 || k2 > 8
                        k1 = floor(8*rand(1)) + 1;
                        k2 = floor(8*rand(1)) + 1;
                    end
                    jpg_t_filename = [jpg_filename(1:end-4), '_Q', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];
                    imwrite(I2(k1:end+k1-8,k2:end+k2-8,:), jpg_t_filename, 'jpg', 'Quality', qf2);
                    image = jpeg_read(jpg_t_filename); 

                    [minH1, minH2] = minHNA(image,1);

                    % DQ-NA, first case: qf2 == qf1
                    if qf1 == qf2
                        minH1_0(t2,Nfiles+iii) = minH1;
                        minH2_1(t2,iii) = minH2;
                    % DQ-NA, second case: qf2 ~= qf1
                    else
                        minH1_1(t1,t2,iii) = minH1;
                    end
                end
            end
            iii = iii + 1;
        end
    end
    
%     savefile = ['statNAout_', num2str(ts)];
    
%     save(savefile, 'minH1_0', 'minH1_1', 'minH2_0', 'minH2_1')
    
%     minH1_0 
%     minH1_1 
%     minH2_0 
%     minH2_1

end
% quit

