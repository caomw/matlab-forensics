% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon';

% dimesione della statistica
Nb=2;

% statistica

data=[];

Bayer_G=[0,1;
         1,0];
    
Bayer_R=[1,0;
         0,0];
     
Bayer_B=[0,0; 
         0,1];

directory = dir([folder_name, '\*.tif']);
files = {directory.name};

region_rate=zeros(1,length(files));

for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        
        [statistica,blocks]=modello_CFA_v2(Itest,dim,Nb);
        data=[data;statistica];
        region_rate(i)=sum(sum(double(blocks)))/(h*w/4);

end

x=-6:0.1:20;
h=histc(data,x);figure;
plot(x,h);



