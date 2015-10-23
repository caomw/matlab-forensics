function [] = detectTampering_plus(jpeg, c1Y, c2Y, c1C, c2C)

image = jpeg_read(jpeg); 

if nargin == 5
    maskTamperedY = getJmap(image, 1, c1Y, c2Y);
    maskTamperedCb = getJmap(image, 2, c1C, c2C);
    maskTamperedCr = getJmap(image, 3, c1C, c2C);

    [rY,cY] = size(maskTamperedY);
    hRC = image.comp_info(1).h_samp_factor;
    vRC = image.comp_info(1).v_samp_factor;

    maskTamperedCb = kron(maskTamperedCb, ones(vRC,hRC));
    maskTamperedCr = kron(maskTamperedCr, ones(vRC,hRC));

    maskTampered = maskTamperedY .* maskTamperedCb(1:rY,1:cY) .* maskTamperedCr(1:rY,1:cY);
    maskUntampered = (1 - maskTamperedY) .* (1 - maskTamperedCb(1:rY,1:cY)) .* (1 - maskTamperedCr(1:rY,1:cY));
    maskTampered = maskTampered ./ (maskTampered + maskUntampered);
else
%     [maskTampered, Q1, alphat, dummy, dummy, relt] = getJmap_rel(image, 1, c1Y, c2Y);
    [maskTampered, Q1, alphat] = getJmap(image, 1, c1Y, c2Y);
    Q2 = image.quant_tables{image.comp_info(1).quant_tbl_no};
    image_ref = simulateDQ(image, Q1);
    
%     [maskTampered_ref, maskD] = getJmap_cheat(image_ref, 1, c1Y, c2Y, Q1, alphat, relt);
    [maskTampered_ref, maskD] = getJmap_cheat(image_ref, 1, c1Y, c2Y, Q1, alphat, ones(size(Q1)));
    Q2
    Q1
    
    save([jpeg(1:end-4) '_map'], 'maskTampered');
    save([jpeg(1:end-4) '_mapref'], 'maskTampered_ref');
end


N = 7;
w = fspecial('gaussian', [N N], N/6);
[r,c] = size(maskTampered_ref);
maskTampered_norm = 1 - (1 - maskTampered(1:r,1:c)) ./ (1 - maskTampered_ref);
% maskTampered_norm = 2*(maskTampered(1:r,1:c) - maskTampered_ref) ./ max(maskD + 1 - 2*maskTampered_ref, 0);
maskTampered_norm = max(maskTampered_norm, 0);
maskTampered_norm = min(maskTampered_norm, 1);
% maskTampered_norm = maskTampered_norm .* (maskD > 0);


% LLRT = log(maskTampered./(1 - maskTampered));
% LLRT = imfilter(LLRT, w);

maskTampered = medfilt2(maskTampered, [5 5]);
% maskTfilt = exp(imfilter(log(maskTampered), w));
% maskUfilt = exp(imfilter(log(1 - maskTampered), w));
% maskTampered = 1 ./ (1 + exp(maskUfilt - maskTfilt));
figure, imagesc(maskTampered, [0 1]) %, colorbar
% figure, imagesc(1./(1 + exp(-LLRT)), [0 1]) %, colorbar
% figure, imagesc(maskTampered > 0.5)

% LLRT_ref = log(maskTampered_ref./(1 - maskTampered_ref));
% LLRT_ref = imfilter(LLRT_ref, w);

maskTampered_ref = medfilt2(maskTampered_ref, [5 5]);
% maskTfilt = exp(imfilter(log(maskTampered), w));
% maskUfilt = exp(imfilter(log(1 - maskTampered), w));
% maskTampered = 1 ./ (1 + exp(maskUfilt - maskTfilt));
% figure, imagesc(1./(1 + exp(-LLRT_ref)), [0 1]) %, colorbar
figure, imagesc(maskTampered_ref, [0 1]) %, colorbar


N = 7;
w = fspecial('gaussian', [N N], N/6);
% LLRT_norm = log(maskTampered_norm./(1 - maskTampered_norm));
% LLRT_norm = max(LLRT_norm, log(eps));
% LLRT_norm = min(LLRT_norm, -log(eps));
% LLRT_norm = imfilter(LLRT_norm, w);

maskTampered_norm = medfilt2(maskTampered_norm, [7 7]);
% maskUntampered_norm = (1 - maskTampered(1:r,1:c)) .* maskTampered_ref;
% maskTampered_norm = maskTampered_norm ./ (maskTampered_norm + maskUntampered_norm);
figure, imagesc(maskTampered_norm, [0 1]) %, colorbar
% figure, imagesc(1./(1 + exp(-LLRT_norm)), [0 0.5]) %, colorbar
% figure, imagesc(1./(1 + exp(-LLRT)) - 1./(1 + exp(-LLRT_ref)), [0 1])
% figure, imagesc(maskD, [0 1])
% mask_norm = 2*(1./(1 + exp(-LLRT)) - 1./(1 + exp(-LLRT_ref))) ./ max(maskD + 1 - 2./(1 + exp(-LLRT_ref)), 0);
% mask_norm = mask_norm .* (maskD > 0);
% mask_norm = 1 - (1 - 1./(1 + exp(-LLRT))) ./ (1 - 1./(1 + exp(-LLRT_ref)));
% figure, imagesc(mask_norm, [0 1])


% img = imread(jpeg);
% m = size(img);
% maskbppmlarge = imresize(maskTampered > 0.5,[m(1) m(2)]);
% %img(:,:,1) = uint8(double(img(:,:,1)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,1))) .* maskbppmlarge);
% %img(:,:,2) = uint8(double(img(:,:,2)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,2))) .* maskbppmlarge);
% %img(:,:,3) = uint8(double(img(:,:,3)) .* (1 - maskbppmlarge) + (255 - double(img(:,:,3))) .* maskbppmlarge);
% %img(:,:,1) = uint8(double(img(:,:,1)) .* (1 - maskbppmlarge));
% img(:,:,2) = uint8(double(img(:,:,2)) .* (1 - maskbppmlarge));
% %img(:,:,3) = uint8(double(img(:,:,3)) .* (1 - maskbppmlarge));
% figure, imshow(img);
% 
% 
% 
% map = colormap;
% sizemap = size(map);
% mapint = uint8(255*map);
% 
% masklarge = imresize(maskTampered,[m(1) m(2)]);
% maskint = ceil(masklarge*sizemap(1));
% maskint(maskint < 1) = 1;
% maskint(maskint > sizemap(1)) = sizemap(1);
% 
% 
% c = mapint(:,1);
% mask(:,:,1) = c(maskint);
% c = mapint(:,2);
% mask(:,:,2) = c(maskint);
% c = mapint(:,3);
% mask(:,:,3) = c(maskint);

return