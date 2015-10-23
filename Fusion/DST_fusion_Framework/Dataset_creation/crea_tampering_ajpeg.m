%File per generare le varie immagini a jpeg a partire da 
%imamgini di tipo tiff

function crea_tampering_ajpeg(path,destfoldername,test_size,tamp_size,q1values,q2values)
    dirname= fullfile(path,destfoldername);   
    mkdir(dirname);
    filetype='*.tif';
    
    img_list=dir(fullfile(path,filetype));     
    for i=1:length(img_list)
        original_image_name=img_list(i).name;        
        %TIFF=imread(strcat(path,original_image_name)); 
        TIFF = takeCenterBlock(fullfile(path,original_image_name), test_size);
        fprintf('Converto l''immagine %d/%d con AJPEG \n',i,length(img_list));
        for Q2=q2values
            for Q1=q1values
                % define mask for tampering (tamp_size)
                mask = false(size(TIFF));
                pt1 = floor((test_size - tamp_size))/2 + 1;
                pt2 = pt1 + tamp_size - 1;
                mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;           

                %compress target image with Q1 and re-open
                imwrite(TIFF,'tmp.jpg','jpg', 'Quality', Q1);
                reload = imread('tmp.jpg');

                %tamper
                reload(mask) = TIFF(mask);

                %compress with Q2
                name_of_image=fullfile(dirname,[original_image_name,'.AJPEG_Q1_',num2str(Q1),'_Q2_',num2str(Q2),'.jpg']);
                imwrite(reload,name_of_image,'jpg', 'Quality', Q2);
                delete('tmp.jpg');

            end            
        end
    end 
    
end