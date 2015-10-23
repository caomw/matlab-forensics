function create_tampering_najpeg(origfoldername,destfoldername,test_size,tamp_size,qstep)
%This function creates NAJPEG tampering from the TIFF images in path
%directory.

    JPEGqualities1 = 50:qstep:100;
    JPEGqualities2 = 50:qstep:100;
    
    if ispc
        outputfoldername=[origfoldername destfoldername];
    else
        outputfoldername=[origfoldername destfoldername];
    end

    origfoldername={origfoldername};
    Nfiles = 0;
    for ndir = 1:length(origfoldername)
            directory = dir([origfoldername{ndir}, '/*.tif']);
            Nfiles = Nfiles + length(directory);
    end

    % define the mask for tampering (tamp_size)
    mask = false([test_size 3]);
    pt1 = floor((test_size - tamp_size)) + 1;
    pt2 = pt1 + tamp_size - 1;
    mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;
    mask = ~mask;

    % make directory for single compression forgery scenario
    if ~exist([outputfoldername, '/DCF2'], 'dir')
        mkdir([outputfoldername, '/DCF2']);
    end


    % main index
    iii = 1;

    %for ndir = 1:length(origfoldername);
        directory = dir([origfoldername{ndir}, '/*.tif']);
        files = {directory.name};

        for ii=1:length(files)
            current_file = char(files(ii));
            filename = [origfoldername{ndir}, '/', current_file];
            fprintf('Converto l''immagine %d/%d con NAJPEG \n',ii,length(files));
            I = imread(filename);
            [h,w,dummy] = size(I);
            
            p1=[1 1];
            p2 = [test_size(1) test_size(2)];
            Itest= imread('base.tif');
            Itest(p1(1):p2(1),p1(2):p2(2),:) = I(p1(1):p2(1),p1(2):p2(2),:);

            for t1 = 1:length(JPEGqualities1)
                qf1 = JPEGqualities1(t1);
                if ispc
                    jpg_filename = [outputfoldername, '\', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
                    jpg_filename_FFF = [outputfoldername, '\DCF2\', current_file(1:end-4), '_Q1_', num2str(qf1)];
                else
                    jpg_filename = [outputfoldername, '/', current_file(1:end-4), '_Q', num2str(qf1), '.jpg'];
                    jpg_filename_FFF = [outputfoldername, '/DCF2/', current_file(1:end-4), '_Q1_', num2str(qf1)];
                end
                imwrite(Itest, jpg_filename, 'jpg', 'Quality', qf1);
                I2 = imread(jpg_filename);
                delete(jpg_filename);
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
                    
                    if ispc
                        newdir=[outputfoldername,'\Q2_',num2str(qf2)];
                    else
                        newdir=[outputfoldername,'/Q2_',num2str(qf2)];
                    end
                    
                    if(exist(newdir,'dir')==0)
                        mkdir(newdir);
                    end
                    
                    jpg_t_filename_FFF = [jpg_filename_FFF, '_Q2_', num2str(qf2), '_NA_',num2str(k1-1),'_',num2str(k2-1),'.jpg'];

                    Iorig = Itest(k1:end+k1-8,k2:end+k2-8,:);
                    Icomp = I2(k1:end+k1-8,k2:end+k2-8,:);
                    I_FFF = Iorig(mask);
                    % generate forged image according to FFF scenario
                    Icomp(mask) = I_FFF;
                    imwrite(Icomp, jpg_t_filename_FFF, 'jpg', 'Quality', qf2);
                    movefile(jpg_t_filename_FFF,newdir);
    %                
                end
            end
            iii = iii + 1;
        end
    %end

end

% quit