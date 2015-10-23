%File per generare le varie immagini a jpeg a partire da 
%imamgini di tipo tiff

function crea_tampering_a_na(path,destfoldername,test_size,tamp_size,q1values,q2values)
    dirname=fullfile(path, destfoldername);
    mkdir(dirname);
    filetype='*.tif';
    Crop_possib = [1 2 3 5 6 7];
    
    img_list=dir(fullfile(path,filetype));    
    for i=1:length(img_list)
        original_image_name=img_list(i).name;        
        %TIFF=imread(fullfile(path,original_image_name)); 
        TIFF = takeCenterBlock(fullfile(path,original_image_name), test_size);

        fprintf('Converto l''immagine %d/%d con NAJPEG e AJPEG \n',i,length(img_list));
        for Q2=q2values
            for Q1=q1values
                % define mask for tampering (tamp_size)
                mask = false(size(TIFF));
                pt1 = floor((test_size - tamp_size))/2 + 1;
                pt2 = pt1 + tamp_size - 1;
                mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;           

                %compress target image with Q1 and re-open
                imwrite(TIFF,'tmp_a.jpg','jpg', 'Quality', Q1);
                reload_a = imread('tmp_a.jpg');
                
                s = Crop_possib(fix(1 + length(Crop_possib).*rand(1,2)));
                R=s(1);
                C=s(2);

                %crop TIFF and compress with Q1
                cropped = TIFF(R+1:end, C+1:end, :);
                imwrite(cropped,'tmp_na.jpg','jpg', 'Quality', Q1);
                %reload and take tampering block
                reload_na = imread('tmp_na.jpg');
                virtualX = pt1(1) - R;
                virtualY = pt1(2) - C;
                tamp_blk = reload_na(virtualX : virtualX+tamp_size(1)-1 , virtualY : virtualY+tamp_size(2)-1, :);

                tamp = reload_a;
                tamp(pt1(1):pt2(1),pt1(2):pt2(2),:) = tamp_blk;                                                                           

                %compress with Q2
                name_of_image=fullfile(dirname,[original_image_name,'.ANAJPEG_Q1_',num2str(Q1),'_Q2_',num2str(Q2),'.jpg']);
                imwrite(tamp,name_of_image,'jpg', 'Quality', Q2);                       
                delete('tmp_a.jpg');
                delete('tmp_na.jpg');
            end            
        end
    end 
    
end