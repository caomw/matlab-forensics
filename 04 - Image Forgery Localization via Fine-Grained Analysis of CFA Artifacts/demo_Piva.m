% Demo of CFA localization algorithm
%
% Copyright (C) 2011 Signal Processing and Communications Laboratory (LESC),       
% Dipartimento di Elettronica e Telecomunicazioni - Universit� di Firenze                        
% via S. Marta 3 - I-50139 - Firenze, Italy                   
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


filename = {'flowers.tiff','flowers-tampered.tiff','garden.jpg','garden-tampered.jpg'};

% dimensione of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;
% Pattern of CFA on green channel
bayer = [0, 1;
         1, 0];
     
for i = 1:2:3
     
     im_true = imread(filename{i});     
     im = imread(filename{i+1});
    
     for j = 1:2
        
        [map, stat] = CFAloc(im, bayer, Nb(j),Ns);

        [h w] = size(map);

        %    NaN and Inf management

        stat(isnan(stat)) = 1;
        data = log(stat(:)); 
        data = data(not(isinf(data)|isnan(data)));
        % square root rule for bins
        n_bins = round(sqrt(length(data)));

        % plot result
        figure
        subplot(2,2,1), imshow(im_true), title('Not tampered image');
        subplot(2,2,2), imshow(im), title('Manipulated image');
        subplot(2,2,3), imagesc(map), colormap('gray'),axis equal, axis([1 w 1 h]), title(['Probability map (Nb = ',num2str(Nb(j)),')']);
        subplot(2,2,4), hist(data, n_bins), title('Histogram of the proposed feature');

        display('Press any key to continue...')
        pause
   
     end
end


