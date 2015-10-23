
JPEGqualities = round(50:50/16:99);
% JPEGqualities = round(50:50/16:54);
if ispc
    addpath('Z:/Matlab/Forensics/DJPG/double jpeg');
    addpath('Z:/Matlab/Forensics/DJPG/periodicity analysis');
    origfoldername = {'test', 'test2'};
    outputfoldername = 'output';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
    addpath('/staff/bianchi/Matlab/Forensics/DJPG/double jpeg');
    addpath('/staff/bianchi/Matlab/Forensics/DJPG/periodicity analysis');
    origfoldername = {'/images/Prove/Bianchi/JPEGNA', '/images/Prove/Bianchi/JPEGDQ', '/images/Prove/Bianchi/Others'};
    outputfoldername = '/images/Prove/Bianchi/JPEGNA/output';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
end

index_min = 1; %3*length(JPEGqualities) * length(JPEGqualities) + 1;
index_max = 500 * length(JPEGqualities) * length(JPEGqualities);

Nfiles = 0;
for ndir = 1:length(origfoldername)
        directory = dir([origfoldername{ndir}, '/*.tif']);
        Nfiles = Nfiles + length(directory);
end
display(['number of files in database ', num2str(Nfiles)])
        
test_sizes = [1024];
% test_sizes = [128, 256];
test_shift = 1200;

for ts = test_sizes
    test_size = [ts, ts];
    test_size = test_size + 7;
    
    if ~exist([outputfoldername, '/', num2str(ts)], 'dir')
        mkdir([outputfoldername, '/', num2str(ts)]);
    end
    display(['testing size ', num2str(ts)])
    
    clear NA DJ PA
    
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

            for icut = -1:1
                if iii < index_min 
                    iii = iii + length(JPEGqualities) * length(JPEGqualities);
                elseif iii < index_max
                    % cut center part (test_size)
                    p1 = floor(([h w] - test_size)/2) + 1;
                    if h > w
                        p1(1) = p1(1) + icut * test_shift;
                    else
                        p1(2) = p1(2) + icut * test_shift;
                    end
                    p2 = p1 + test_size - 1;
                    Itest = I(p1(1):p2(1),p1(2):p2(2),:);

                    for t1 = 1:length(JPEGqualities)

                        qf1 = JPEGqualities(t1);
                        jpg_filename = [outputfoldername, '/', num2str(ts), '/', current_file(1:end-4), '_cut', num2str(icut+1), '_Q', num2str(qf1), '.jpg'];
                        imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);

                        % no DQ-NA 

                        im = jpeg_read(jpg_filename); 
                        f = zeros(1,2);
                        [f(1), f(2)] = minHNA(im,1);

                        NA.features(iii,:) = f; %#ok<AGROW>
                        NA.group(iii,1) = 0; %#ok<AGROW>

                        NA.group_qf1(iii,1) = 0; %#ok<AGROW>
                        NA.group_qf2(iii,1) = t1; %#ok<AGROW>

                        f = DJextractFeatures(jpg_filename); 

                        DJ.features(iii,:) = f; %#ok<AGROW>
                        DJ.group(iii,1) = 0; %#ok<AGROW>

                        DJ.group_qf1(iii,1) = 0; %#ok<AGROW>
                        DJ.group_qf2(iii,1) = t1; %#ok<AGROW>

                        f = PAextractFeatures(jpg_filename); 

                        PA.features(iii,:) = f; %#ok<AGROW>
                        PA.group(iii,1) = 0; %#ok<AGROW>

                        PA.group_qf1(iii,1) = 0; %#ok<AGROW>
                        PA.group_qf2(iii,1) = t1; %#ok<AGROW>

                        iii = iii + 1;

                        if t1 < length(JPEGqualities)
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

                                im = jpeg_read(jpg_t_filename); 
                                f = zeros(1,2);
                                [f(1), f(2)] = minHNA(im,1);

                                NA.features(iii,:) = f; %#ok<AGROW>
                                NA.group(iii,1) = 1; %#ok<AGROW>

                                NA.group_qf1(iii,1) = t1; %#ok<AGROW>
                                NA.group_qf2(iii,1) = t2; %#ok<AGROW>

                                f = DJextractFeatures(jpg_t_filename); 

                                DJ.features(iii,:) = f; %#ok<AGROW>
                                DJ.group(iii,1) = 1; %#ok<AGROW>

                                DJ.group_qf1(iii,1) = t1; %#ok<AGROW>
                                DJ.group_qf2(iii,1) = t2; %#ok<AGROW>

                                f = PAextractFeatures(jpg_t_filename); 

                                PA.features(iii,:) = f; %#ok<AGROW>
                                PA.group(iii,1) = 1; %#ok<AGROW>

                                PA.group_qf1(iii,1) = t1; %#ok<AGROW>
                                PA.group_qf2(iii,1) = t2; %#ok<AGROW>

                                delete(jpg_t_filename);

                                iii = iii + 1;
                            end
                        end

                        delete(jpg_filename);
                    end
                    
                    savefile = [outputfoldername, '/', num2str(ts), '/NA_feat_', num2str(index_min), '_', num2str(index_max)];
                    save(savefile, 'NA')

                    savefile = [outputfoldername, '/', num2str(ts), '/DJ_feat_', num2str(index_min), '_', num2str(index_max)];
                    save(savefile, 'DJ')

                    savefile = [outputfoldername, '/', num2str(ts), '/PA_feat_', num2str(index_min), '_', num2str(index_max)];
                    save(savefile, 'PA')
                end
            end
        end
    end  
    
%     NA 
%     DJ 
%     PA 

end
quit

