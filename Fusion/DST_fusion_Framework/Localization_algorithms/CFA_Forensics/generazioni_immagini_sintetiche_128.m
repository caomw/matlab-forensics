% Generazione di immagine con CFA di Bayer e interpolazione bilineare
% simulate

% waitbar
h = waitbar(0,'Please wait....');

dim = 512;
t = 128;

tamper_size = [t, t];
folder_name='/users/ferrara/Desktop/Mega Dataset';

% pattern di CFA

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];
     


directory = dir([folder_name, '/*.*']);
files = {directory.name};

for i=3:length(files)
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '/', current_file];
        I = imread(filename);
        [h,w,dummy] = size(I);
       
        % generazione dell'immagine con CFA simulata
        I=uint8(filtro_bilineare(I,Bayer_R,Bayer_G,Bayer_B));
        
        
        % regione manipolata
        p1 = floor(([h w] - tamper_size)/2) + 1;
        p2 = p1 + tamper_size - 1;
        region_tampered = I(p1(1):p2(1),p1(2):p2(2),:);
        region_tampered = imresize(region_tampered,2);
        region_tampered(:,:,2) = medfilt2(region_tampered(:,:,2),[7 7],'symmetric');
        region_tampered(:,:,1) = medfilt2(region_tampered(:,:,1),[7 7],'symmetric');
        region_tampered(:,:,3) = medfilt2(region_tampered(:,:,3),[7 7],'symmetric');
        region_tampered = imresize(region_tampered,0.5);
        
        for k=p1(1):p2(1)
            for j=p1(2):p2(2)
                I(k,j,:)=region_tampered(k-p1(1)+1,j-p1(2)+1,:);
            end
        end
        
        
  
        imwrite(I,['/users/ferrara/Desktop/Dataset/Sintetiche_128','/',current_file]);

        % waiting bar
        waitbar(i/(length(files)));
    
end
