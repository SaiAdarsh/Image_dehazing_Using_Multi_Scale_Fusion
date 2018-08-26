clc;
clear all;
close all;
tic
%-------original image---
i=imread('3.png');              %input image
imshow(i);
title('original image');

%----------white balancing(first derived input) using gray world assumption------------
avgrgb = mean(mean(i));                      %avg of each plane
factors= (mean(avgrgb))./avgrgb;             %avg of all the planes divided by avg of each plane
i1(:,:,1)=(i(:,:,1)*factors(1));             
i1(:,:,2)=(i(:,:,2)*factors(2));
i1(:,:,3)=(i(:,:,3)*factors(3));
figure();
imshow(i1);
title('white balanced image');


%---------second derived image-----
%l=mean2(rgb2gray(i));
l1=((0.299*(i(:,:,1))) + (0.587*(i(:,:,2))) + (0.114*(i(:,:,3))));      %luminance value calculation
l1 = im2double(l1); 
i = im2double(i);
l=mean2(l1);
i2=2.5*((i)-l);                                    %formula for second derived image
figure();
imshow((i2));
title('second derived image');
i2 = im2uint8(i2);
i = im2uint8(i);
i1=im2double(i1);
i2=im2double(i2);
%-------------- luminous weight map of i1 -----------------
k1=mean2((0.299*(i1(:,:,1))) + (0.587*(i1(:,:,2))) + (0.114*(i1(:,:,3))));        %average luminance
a1=i1;
p1=sqrt((((a1(:,:,1))-k1).^2+((a1(:,:,2))-k1).^2+((a1(:,:,3))-k1).^2)/3);         %luminance weight map formula
figure();
imshow((p1));
title('luminous weight map of i1');


%--------------luminous weight map of i2------------------
k2=mean2((0.299*(i2(:,:,1))) + (0.587*(i2(:,:,2))) + (0.114*(i2(:,:,3))));         %average luminance
a2=i2;
p2=sqrt((((a2(:,:,1))-k2).^2+((a2(:,:,2))-k2).^2+((a2(:,:,3))-k2).^2)/3);          %luminance weight map formula
figure();
imshow((p2));
title('luminous weight map of i2');

%--------------chromatic weight map of i1-----------------
m1=rgb2hsv(i1);                                    %converting rgb to hsv plane to extract saturation values        
% figure();
% imshow(m1(:,:,2));
n1=exp(-((m1(:,:,2)-1).^2)./0.18);                  %formula for chromatic weight map
figure();
imshow((n1));
title('chromatic weight map of i1');


%------------chromatic weight map of i2--------------

m2=rgb2hsv(i2);
% figure();
% imshow(m2(:,:,2));
n2=exp(-((m2(:,:,2)-1).^2)./0.18);                   %formula for chromatic weight map
figure();
imshow((n2));
title('chromatic weight map of i2');

%--------------saliency map of i1------------------

i1 = im2double(i1);
% fil1=fspecial('gaussian',[5 5],3);
 fil1=(1/16)*[1,1,1,1,1;                              %5x5 binomial kernal
      1,1,4,1,1;
      1,4,6,4,1;
      1,1,4,1,1;
      1,1,1,1,1;];
f1=imfilter(i1,fil1,'replicate');                      %applying above filter to the white balanced image
u1 = mean2(i1);                                        %averge value calculation
sap1=sqrt((((f1(:,:,1))-u1).^2+((f1(:,:,2))-u1).^2+((f1(:,:,3))-u1).^2));       %second order norm (formula for saliency map)
figure
imshow((sap1));
title('saliency map of i1');

%----------------- saliency map of i2-------------

i2 = im2double(i2);
% fil1=fspecial('gaussian',[5 5],3);
 fil1=(1/16)*[1,1,1,1,1;
      1,1,4,1,1;
      1,4,6,4,1;
      1,1,4,1,1;
      1,1,1,1,1;];
f2=imfilter(i2,fil1,'replicate');                 %applying above filter to the second derived image
u2 = mean2(i2);
sap2=sqrt((((f2(:,:,1))-u2).^2+((f2(:,:,2))-u2).^2+((f2(:,:,3))-u2).^2));
figure
imshow(sap2);
title('saliency map of i2');

%--------------------resultant weight map and gaussian pyramid of weightmaps--------------
r11=p1.*n1.*sap1;            %multipying weight maps of i1
r22=p2.*n2.*sap2;            %multipying weight maps of i2
r1=r11./(r11+r22);           %normalizing  resultant weight maps of i1
r2=r22./(r11+r22);           %normalizing  resultant weight maps of i2 
figure
imshow(r1);
title('resultant weight map of i1');
a=0.375;
h=[1/4-a/2,1/4,a,1/4,1/4-a/2];       %1-d gaussian filter
c1=cell(1,6);
c1{1}=r1;
for j=1:5
    k=imfilter(c1{j},h);             %applying gaussian filter to resultant weight maps
    c1{j+1}=k(1:2:end,1:2:end);      %downsampling
end


%-------------------- gaussian pyramid of weightmaps --------------
figure
imshow(r2);
title('resultant weight map of i2');
c2=cell(1,6);
c2{1}=r2;
for j=1:5
    k2=imfilter(c2{j},h);
    c2{j+1}=k2(1:2:end,1:2:end);
end

%-----------------laplacian pyramid of i1------------------
ga=cell(1,6);
la=cell(1,6);
ga{1}=i1;
for cc=1:5
    pp=imfilter(ga{cc},h);
    la{cc}=abs(ga{cc}-pp);               %laplacian pyramid
    ga{cc+1}=imresize(pp,.5);             
end
la{6}=ga{6};

%-----------------laplacian pyramid of i2------------------
ga2=cell(1,6);
ga2{1}=i2;
la2=cell(1,6);
for cc2=1:5
    ff2=imfilter(ga2{cc2},h);
    la2{cc2}=abs(ga2{cc2}-ff2);
    ga2{cc2+1}=imresize(ff2,0.5);
end
la2{6}=ga2{6};

%--------------fusion----------------------

fu=cell(1,5);
 for jj=1:5
     fu{jj}(:,:,1)=(la{jj}(:,:,1).*c1{jj})+(la2{jj}(:,:,1).*c2{jj});
     fu{jj}(:,:,2)=(la{jj}(:,:,2).*c1{jj})+(la2{jj}(:,:,2).*c2{jj});
     fu{jj}(:,:,3)=(la{jj}(:,:,3).*c1{jj})+(la2{jj}(:,:,3).*c2{jj});
 end
 
[m ,n, k]=size(fu{4});
out1=fu{4}+imresize(fu{5},[m,n]);
[m ,n ,k]=size(fu{3});
out2=fu{3}+imresize(out1,[m,n]);
[m ,n ,k]=size(fu{2});
out3=fu{2}+imresize(out2,[m,n]);
[m ,n ,k]=size(fu{1});
out4=fu{1}+imresize(out3,[m,n]);



figure
imshow(out4)












toc



