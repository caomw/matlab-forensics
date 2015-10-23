% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='/users/ferrara/Desktop/Mega Dataset';

% dimesione della statistica
Nb=8;

% statistica

data=[];


directory = dir([folder_name, '/*.*']);
files = {directory.name};

region_rate=zeros(1,100);

for i=3:27
    
        % waiting bar update
        waitbar(i/(length(files)));
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '/', current_file];
        Itest = imread(filename);
        [h,w,dummy] = size(Itest);
        Itest = uint8(filtro_bilineare(Itest, Bayer_R, Bayer_G, Bayer_B));
        [data_scatter,blocks]=modello_CFA_v3(Itest,dim,Nb);
        data=[data;data_scatter];
        region_rate(i)=sum(sum(double(blocks)))/(length(blocks)^2);

end

data1=data(not(isnan(data(:,1))|isinf(data(:,1))),1);
data2=data(not(isnan(data(:,1))|isinf(data(:,1))),2);
figure;
scatter(data2,data1);
