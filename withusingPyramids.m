clc;
clear all;
close all;
tic
%-------original image---
i=imread('3.jpg');                    %reading input image
imshow(i);
title('original image');

%----------white balancing(first derived input)------------
avgrgb = mean(mean(i));               %calculating mean of all the three channels
factors= (mean(avgrgb))./avgrgb;      %finding factors for each channel as total mean divided by the avg of respective channels
i1(:,:,1)=(i(:,:,1)*factors(1));      % multiplying the factors with respective channels
i1(:,:,2)=(i(:,:,2)*factors(2));
i1(:,:,3)=(i(:,:,3)*factors(3));


%---------second derived image-----
i2=clahe_c(i);                      %calculating the adaptive histogram equalization of input image
i1=im2double(i1);
i2=im2double(i2);
% figure();
% imshow((i2));
% title('second derived image');

%-------------- luminous weight map of i1 -----------------
k1=mean2((0.299*(i1(:,:,1))) + (0.587*(i1(:,:,2))) + (0.114*(i1(:,:,3))));    % formula for calculating luminance value
a1=i1;
p1=sqrt((((a1(:,:,1))-k1).^2+((a1(:,:,2))-k1).^2+((a1(:,:,3))-k1).^2));       % formula for calculating luminance weight map
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
m1=rgb2hsv(i1);     % converting rgb to hsv color map
n1=exp(-((m1(:,:,2)-1).^2)./0.125);   %formula for chromatic weight map
% figure();
% imshow((n1));
% title('chromatic weight map of i1');


%------------chromatic weight map of i2--------------
% m2=rgb2gray(i2);
 m2=rgb2hsv(i2);
% figure();
% imshow(m2(:,:,2));
n2=exp(-((m2(:,:,2)-1).^2)./0.125);
% figure();
% imshow((n2));
% title('chromatic weight map of i2');

%--------------saliency map of i1------------------

i1 = im2double(i1);
h = fspecial('gaussian', [11 11], 1.0);    % creates gaussian kernal of size 11x11
f1 = imfilter(i1, h,'replicate');          % applying kernal to derived input
u1 = mean2(i1);                            % calculate the mean value of image  
sap1=sqrt((((f1(:,:,1))-u1).^2+((f1(:,:,2))-u1).^2+((f1(:,:,3))-u1).^2));     %formula for saliency weight map
% figure
% imshow((sap1));
% title('saliency map of i1');

%----------------- saliency map of i2-------------

i2 = im2double(i2);
h = fspecial('gaussian', [5 5], 1.0); 
f2 = imfilter(i2, h,'replicate');
u2 = mean2(i2);
sap2=sqrt((((f2(:,:,1))-u2).^2+((f2(:,:,2))-u2).^2+((f2(:,:,3))-u2).^2));
% figure
% imshow(sap2);
% title('saliency map of i2');

%---------------- resultant weight map-----------
% p1 and p2 are luminance weight maps for derived input 1 and 2
% n1 and n2 are chromatic weight maps for derived input 1 and 2
% sap1 and sap2 are saliency weight maps for derived input 1 and 2

r11=p1.*n1.*sap1;
r22=p2.*n2.*sap2;
r1=r11./(r11+r22);
r2=r22./(r11+r22);

% r1 and r2 are resultant weight maps for derived input 1 and 2

% figure
% imshow(r1);
% title('resultant weight map of i1');
% figure
% imshow(r2);
% title('resultant weight map of i2');



ga1=cell(1,5);          

ga1{1}=r1;
for j=1:4
    h = fspecial('gaussian', [11 11], 1.0);        %defining the gaussian kernal
k2 = imfilter(ga1{j}, h,'replicate');            %applying gaussian kernal to the input and repeating succesively for the consecutive images to get gaussian pyramid
   
    ga1{j+1}=k2(1:2:end,1:2:end);                % downsampling 
end
ga2=cell(1,5);

ga2{1}=r2;
for j=1:4
    h = fspecial('gaussian', [11 11], 1.0); 
k2 = imfilter(ga2{j}, h,'replicate');
   
    ga2{j+1}=k2(1:2:end,1:2:end);
end

gaa1=cell(1,5);

gaa1{1}=(i1);
for j=1:4
    h = fspecial('gaussian', [11 11], 1.0); 
k2 = imfilter(gaa1{j}, h,'replicate');
   
    gaa1{j+1}=k2(1:2:end,1:2:end,:);
end
gaa2=cell(1,5);

gaa2{1}=(i2);
for j=1:4
    h = fspecial('gaussian', [11 11], 1.0); 
k2 = imfilter(gaa2{j}, h,'replicate');
   
    gaa2{j+1}=k2(1:2:end,1:2:end,:);
end


la1=cell(1,5);
la1(5)=gaa1(5);
for cc=5:-1:2
    pk1{cc-1}=imresize(gaa1{cc},2);
    [ma na ka]=size(gaa1{cc-1});
       pk1{cc-1}=imresize(pk1{cc-1},[ma na]);
    la1{cc-1}=gaa1{cc-1}-pk1{cc-1};                  %subtracting the levels of gaussian levels to get laplacian pyramid
end

la2=cell(1,5);
la2(5)=gaa2(5);
for cc=5:-1:2
    pk2{cc-1}=imresize(gaa2{cc},2);
    [mb nb kb]=size(gaa2{cc-1});
     pk2{cc-1}=imresize(pk2{cc-1},[mb nb]);
    la2{cc-1}=gaa2{cc-1}-pk2{cc-1};
end


%ga1{} is gaussian pyramid of derived input1
%ga2{} is gaussian pyramid of derived input2
%la1{} is laplacian pyramid of derived input1
%la2{} is laplacian pyramid of derived input2

fu=cell(1,5);
  for jj=1:5
      fu{jj}(:,:,1)=(la1{jj}(:,:,1).*ga1{jj})+(la2{jj}(:,:,1).*ga2{jj});
      fu{jj}(:,:,2)=(la1{jj}(:,:,2).*ga1{jj})+(la2{jj}(:,:,2).*ga2{jj});
      fu{jj}(:,:,3)=(la1{jj}(:,:,3).*ga1{jj})+(la2{jj}(:,:,3).*ga2{jj});
  end
 
%  [m ,n, k]=size(fu{5});
% out0=fu{5}+imresize(fu{6},[m,n]);
[m ,n, k]=size(fu{4});
out1=fu{4}+imresize(fu{5},[m,n]);
[m ,n ,k]=size(fu{3});
out2=fu{3}+imresize(out1,[m,n]);
[m ,n ,k]=size(fu{2});
out3=fu{2}+imresize(out2,[m,n]);
[m ,n ,k]=size(fu{1});
out4=fu{1}+imresize(out3,[m,n]);
figure
imshow(out4);                     % out4 is the output fused image using pyramids
title('output with pyramids');

toc

disp('Entropy of output image: ');
entropy(out4)
disp('std deviation of output image:  ');
std2(out4)
disp('psnr of output image:  ')
psnr(i,out4)
