clc;
clear all;
close all;
tic
%-------original image---
i=imread('3.jpg');
imshow(i);
title('original image');

%----------white balancing(first derived input)------------
avgrgb = mean(mean(i));
factors= (mean(avgrgb))./avgrgb;
i1(:,:,1)=(i(:,:,1)*factors(1));
i1(:,:,2)=(i(:,:,2)*factors(2));
i1(:,:,3)=(i(:,:,3)*factors(3));
%---------second derived image-----
i2=clahe_c(i);
i1=im2double(i1);
i2=im2double(i2);
% figure();
% imshow((i2));
% title('second derived image');

%-------------- luminous weight map of i1 -----------------
k1=mean2((0.299*(i1(:,:,1))) + (0.587*(i1(:,:,2))) + (0.114*(i1(:,:,3))));
a1=i1;
p1=sqrt((((a1(:,:,1))-k1).^2+((a1(:,:,2))-k1).^2+((a1(:,:,3))-k1).^2));
% figure();
% imshow((p1));
% title('luminous weight map of i1');


%--------------luminous weight map of i2------------------
k2=mean2((0.299*(i2(:,:,1))) + (0.587*(i2(:,:,2))) + (0.114*(i2(:,:,3))));
a2=i2;
p2=sqrt((((a2(:,:,1))-k2).^2+((a2(:,:,2))-k2).^2+((a2(:,:,3))-k2).^2));
% figure();
% imshow((p2));
% title('luminous weight map of i2');

%--------------chromatic weight map of i1-----------------
% m1=rgb2gray(i1);
m1=rgb2hsv(i1);
n1=exp(-((m1(:,:,2)-1).^2)./0.125);
% figure();
% imshow((n1));
% title('chromatic weight map of i1');


%------------chromatic weight map of i2--------------
% m2=rgb2gray(i2);
m2=rgb2hsv(i2);
n2=exp(-((m2(:,:,2)-1).^2)./0.125);
% figure();
% imshow((n2));
% title('chromatic weight map of i2');

%--------------saliency map of i1------------------

i1 = im2double(i1);
h = fspecial('gaussian', [11 11], 1.0); 
f1 = imfilter(i1, h,'replicate');
u1 = mean2(i1);
sap1=sqrt((((f1(:,:,1))-u1).^2+((f1(:,:,2))-u1).^2+((f1(:,:,3))-u1).^2));
% figure
% imshow((sap1));
% title('saliency map of i1');

%----------------- saliency map of i2-------------

i2 = im2double(i2);
h = fspecial('gaussian', [11 11], 1.0); 
f2 = imfilter(i2, h,'replicate');
u2 = mean2(i2);
sap2=sqrt((((f2(:,:,1))-u2).^2+((f2(:,:,2))-u2).^2+((f2(:,:,3))-u2).^2));
% figure
% imshow(sap2);
% title('saliency map of i2');

r11=p1.*n1.*sap1;
r22=p2.*n2.*sap2;
r1=r11./(r11+r22);
r2=r22./(r11+r22);

r1=guidedfilt(r1,rgb2gray(i),20,0.01);
r2=guidedfilt(r2,rgb2gray(i),20,0.01);

% figure
% imshow(r1);
% title('resultant weight map of i1');
% figure
% imshow(r2);
% title('resultant weight map of i2');


out_p1(:,:,1)=i1(:,:,1).*r1;
out_p2(:,:,1)=i2(:,:,1).*r2;
out_p1(:,:,2)=i1(:,:,2).*r1;
out_p2(:,:,2)=i2(:,:,2).*r2;
out_p1(:,:,3)=i1(:,:,3).*r1;
out_p2(:,:,3)=i2(:,:,3).*r2;

out_p=(out_p1+out_p2);



figure
imshow(out_p);
title('output without pyramids');

disp('Entropy of output image: ');
entropy(out_p)
disp('std deviation of output image:  ');
std2(out_p)
disp('psnr of output image:  ')
psnr(i,out_p)

toc