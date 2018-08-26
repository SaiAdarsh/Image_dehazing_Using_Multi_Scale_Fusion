function q = guidedfilt(in_image,guided_image,r,E)
% r is the radius of the kernel window ---%
% E is sthe regularizing parameter which will penalize large a --%
% clc;
% clear all;
% close all;
% r=20;
% E=.01;
% guided_image = im2double(imread('ch.png'));
% in_image = im2double(imread('test.jpg'));
guided_image=im2double(guided_image);
in_image=im2double(in_image);
h = fspecial('average',[r,r]);      % -- Initializing filter function as average in nature--%

meanI = imfilter(guided_image,h,'symmetric');   % -- applying mean filter ---%
meanP = imfilter(in_image,h,'symmetric');

temp = guided_image.*guided_image;
corrI = imfilter(temp,h,'symmetric');
temp2 = in_image.*guided_image;
corrI_P = imfilter(temp2,h,'symmetric');

varI = corrI - meanI.*meanI;
covI_P = corrI_P - meanP.*meanI;

a = (covI_P./(varI+E)) ;
b = meanP - ((a.*meanI));

A = imfilter(a,h,'symmetric');   % taking mean values of a%
B = imfilter(b,h,'symmetric');   % taking mean values of b%

X = (A.*guided_image);
q = X + B;
end

