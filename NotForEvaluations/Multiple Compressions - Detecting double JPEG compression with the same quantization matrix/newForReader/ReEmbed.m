function returnValue = ReEmbed(qFactor,mpnc,doubleDir,TestFilelist,ListLength,numT)

FeaturesVecNum = 1;           
Features = zeros(ListLength,FeaturesVecNum);

for i=1:ListLength 
    img = [doubleDir TestFilelist(i).name];    
    xori = jpeg_read(img);    
    coef = xori.coef_arrays{1};
    coefBackup = coef;
    [a,b] = size(coef);
    num = floor(mpnc * sum(sum(coef~=0)));
    ave = 0;
    for numTimes = 1:numT
        coef = coefBackup;
        pos = randperm(a*b);
        for j=1:num
            coef(pos(j)) = coef(pos(j))+(-1)^(rand(1)>0.5);
        end
        xori.coef_arrays{1} = coef;
        jpeg_write(xori,'reEmbed1.jpg');    
        I = imread('reEmbed1.jpg');
        imwrite(I,'reEmbed2.jpg','quality',qFactor);
        x = jpeg_read('reEmbed1.jpg');
        y = jpeg_read('reEmbed2.jpg');
        z = x.coef_arrays{1} - y.coef_arrays{1};  
        ave = ave + sum(sum(z~=0));
    end
    Features(i,1) = floor(ave/numT);
end

returnValue = Features;
