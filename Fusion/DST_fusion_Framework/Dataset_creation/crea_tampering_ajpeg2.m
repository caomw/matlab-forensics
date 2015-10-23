%File per generare le varie immagini a jpeg a partire da 
%imamgini di tipo tiff

function crea_tampering_ajpeg2(path,destfoldername,test_size,tamp_size)
    if ispc
        dirname=[path destfoldername];
    else
        dirname=[path destfoldername];
    end
    mkdir(dirname);
    filetype='*.tif';
    
    img_list=dir(strcat(path,filetype));    
    for i=1:length(img_list)
        original_image_name=img_list(i).name;        
        TIFF=imread(strcat(path,original_image_name)); 
        fprintf('Converto l''immagine %d/%d con AJPEG \n',i,length(img_list));
        for Q2=80:10:90
            for Q1=60:10:70                           
                % define mask for tampering (tamp_size)
                mask = false(size(TIFF));
                pt1 = floor((test_size - tamp_size))/2 + 1;
                pt2 = pt1 + tamp_size - 1;
                mask(pt1(1):pt2(1),pt1(2):pt2(2),:) = true;           

                                
                           
                imwrite(TIFF,'tmp.jpg','jpg', 'Quality', Q1);
                reload = imread('tmp.jpg');
               
                tamp = TIFF;
                tamp(mask) = reload(mask);               
                %compress with Q2
                name_of_image=strcat(original_image_name,'_Q1_',num2str(Q1),'_Q2_',num2str(Q2),'.jpg');
                imwrite(tamp,name_of_image,'jpg', 'Quality', Q2);                       
                newdir=strcat('Q2_',num2str(Q2));
                delete('tmp.jpg');
                if ispc
                    if(exist(strcat(dirname,'\',newdir),'dir')==0)
                        mkdir(dirname,newdir);     
                    end
                    movefile('*.jpg',strcat(dirname,'\',newdir));
                else
                    if(exist(strcat(dirname,'/',newdir),'dir')==0)
                        mkdir(dirname,newdir);     
                    end
                    movefile('*.jpg',strcat(dirname,'/',newdir));
                end
            end            
        end
    end 
    
end