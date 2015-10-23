% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='C:\Users\Pasquale\Desktop\512Nikon';

% dimesione della statistica
Nb=2;

% statistica

data=[];


directory = dir([folder_name, '\*.tif']);
files = {directory.name};

detection_rate=zeros(1,length(files));

for i=1:length(files)
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '\', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
       
        
        data=[data;modello_CFA(Itest,dim,Nb)];
       

end

x=-6:0.1:10;
h=histc(data,x);
figure;
plot(x,h)