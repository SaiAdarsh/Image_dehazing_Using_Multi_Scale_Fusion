function [ PSNR_Value ] = psnr( i,out4 )
i=im2double(i);
out4=im2double(out4);
[rows columns kr] = size(i);
% Calculate mean square error of R, G, B.   
mseRImage = ((i(:,:,1)) - (out4(:,:,1))) .^ 2;
mseGImage = ((i(:,:,2)) - (out4(:,:,2))) .^ 2;
mseBImage = ((i(:,:,3)) - (out4(:,:,3))) .^ 2;

mseR = sum(sum(mseRImage)) / (rows * columns);
mseG = sum(sum(mseGImage)) / (rows * columns);
mseB = sum(sum(mseBImage)) / (rows * columns);

% Average mean square error of R, G, B.
mse = (mseR + mseG + mseB)/3;

% Calculate PSNR (Peak Signal to noise ratio).
PSNR_Value = 10 * log10( 255^2 / mse)


end

