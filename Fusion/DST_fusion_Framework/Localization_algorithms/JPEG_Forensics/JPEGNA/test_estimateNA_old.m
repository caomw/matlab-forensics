
JPEGqualities = round(50:50/16:99);
% JPEGqualities = round(50:50/16:54);
Qtrue = 16:-1:1;
if ispc
    origfoldername='output';
%     origfoldername='\\GIOTTO\Images\Prove\Bianchi\JPEGNA';
else
    origfoldername='/images/Prove/Bianchi/JPEGNA/output';
    path(path, '/staff/bianchi/Matlab/Forensics/jpeg_read')
end
% number of tests for each image
% Ntest = min(10,length(JPEGqualities));
test_sizes = [128, 256, 512, 1024];
% test_sizes = [128, 256];
load thresholds

nts = 0;
for ts = test_sizes
    nts = nts + 1;
       
    pmiss = zeros(length(JPEGqualities),length(JPEGqualities));
    perrQ = zeros(length(JPEGqualities),length(JPEGqualities));
    perrkk = zeros(length(JPEGqualities),length(JPEGqualities));   
    
    jpg_filename = [origfoldername, '/', num2str(ts)];
           
    for t1 = 1:length(JPEGqualities)

        qf1 = JPEGqualities(t1);
        
        for t2 = 1:length(JPEGqualities)

            qf2 = JPEGqualities(t2);
            
            directory = dir([jpg_filename, '/*_Q', num2str(qf1), '_Q', num2str(qf2), '*.jpg']);
            files = {directory.name};
            Nfiles = 0;

            for ii=1:length(files)
                current_file = char(files(ii));
                Nfiles = Nfiles + 1;
                kidx = regexp(current_file, 'NA_[0-7]_[0-7]');
                k1 = str2double(current_file(kidx+3)) + 1;
                k2 = str2double(current_file(kidx+5)) + 1;
                
                image = jpeg_read([jpg_filename, '/', current_file]); 
                
                [k1e,k2e,Qe] = detectNA(image,1,thresholds1(nts,t2),thresholds2(nts,t2));

                if Qe == 0
                    pmiss(t1,t2) = pmiss(t1,t2) + 1;
                else
                    if Qe ~= Qtrue(t1)
                        perrQ(t1,t2) = perrQ(t1,t2) + 1;
                    end
                    if k1e-1 ~= mod(9-k1,8) || k2e-1 ~= mod(9-k2,8)
                        perrkk(t1,t2) = perrkk(t1,t2) + 1;
                    end
                end
            end
            
            perrQ(t1,t2) = perrQ(t1,t2) / Nfiles;
            perrkk(t1,t2) = perrkk(t1,t2) / Nfiles;
            pmiss(t1,t2) = pmiss(t1,t2) / Nfiles;
        end
    end
    
%     Nfiles
   
    savefile = ['estNAout_', num2str(ts)];
    
    save(savefile, 'perrQ', 'perrkk', 'pmiss')
    
%     perrQ
%     perrkk
%     pmiss
end
quit

