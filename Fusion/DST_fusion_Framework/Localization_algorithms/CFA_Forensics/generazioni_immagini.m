% Generazione di immagini in formato TIFF di dimensione arbitraria dim

% waitbar
h=waitbar(0,'Please wait....');

dim=512;
test_size = [dim, dim];
folder_name='/users/ferrara/Desktop/NikonD50';


directory = dir([folder_name, '/*.*']);
files = {directory.name};

for i=3:length(files)
        
        % image selection
        current_file = char(files(i));
        filename = [folder_name, '/', current_file];
        I = imread(filename);
        [h,w,dummy] = size(I);
        
        % cut center part (test_size)
        p1 = floor(([h w] - test_size)/2)+1 - 512;
       
        % allineamento alla CFA 
        if (mod(p1,2)==0)
            p1=p1+1;
        end
        
        p2 = p1 + test_size - 1;
        Itest = I(p1(1):p2(1),p1(2):p2(2),:);
        
        
        imwrite(Itest,['/users/ferrara/Desktop/512NikonD50-3','/',current_file]);

        % waiting bar
        waitbar(i/(length(files)));
    
end