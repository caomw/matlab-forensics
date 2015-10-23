%Name:		Chris Shoemaker
%Course:	EER-280 - Digital Watermarking
%Project: 	Calculates the PSNR (Peak Signal to Noise Ratio)
%            of images A and A', both of size MxN

function [A] = psnr(image,image_prime,M,N)

    % convert to doubles
    image=double(image);
    image_prime=double(image_prime);

    % avoid divide by zero nastiness
    if ((sum(sum(abs(image-image_prime)))) == 0)    
        error('Input images must not be identical')
    else
        psnr_num= 255^2;                                % calculate numerator
        psnr_den=(1/(M*N))*sum(sum((image-image_prime).^2));      % calculate denominator   
        A=psnr_num/psnr_den;                            % calculate PSNR
    end

    A = 10*log10(A);
return

