function [ out ] = clahe_c( i )
% applying adaptive histogram for each plane saperately
out(:,:,1) = adapthisteq(i(:,:,1),'cliplimit',0.009);
out(:,:,2) = adapthisteq(i(:,:,2),'cliplimit',0.009);
out(:,:,3) = adapthisteq(i(:,:,3),'cliplimit',0.009);

end

