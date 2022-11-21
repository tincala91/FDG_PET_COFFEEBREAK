function ViewSUV3D(filename, sub_info)

%VIEWSUV3D Summary of this function goes here
%   Detailed explanation goes here

%filename = 'wSUV_ScCh_19591229_20210510.nii'
%Load image
nii = load_nii(filename);
img_SUV = double(nii.img);

%Get image shape
[xdim, ydim, zdim] = size(img_SUV);

%Determine slices as in MRIcron
xcut = ceil(xdim/2);
ycut = ceil(ydim*0.6);
zcut = floor(zdim*0.38);

%Flip images as in MRIcron
imgxz = flip(squeeze(img_SUV(:,ycut,:))',1);
imgyz = flip(squeeze(img_SUV(xcut,:,:))',1);
imgxy = flip(squeeze(img_SUV(:,:,zcut))',1);
imgzero = zeros(ydim,ydim);

%Order Images next to each other
img_all = [imgxz, imgyz; imgxy, imgzero];

%Create the lines
%colorvalue = 3;
%img_all(:,xcut) = colorvalue; % vertical line img on the upper left
%img_all(1:zdim,xdim+ycut)=colorvalue; %vertical line img on the right (half)
%img_all(zdim-zcut,:) = colorvalue; %horizontal line upper panel
%img_all(zdim+ydim-ycut,1:xdim) = colorvalue; % horizontal line lower panel (half)

%Create the lines (center is left open)
colorvalue = 3;
openness=5;

img_all(1:(zdim-zcut)-openness,xcut) = colorvalue; % vertical line img on the upper left (upper part)
img_all((zdim-zcut)+openness:(zdim+ydim-ycut)-openness,xcut) = colorvalue; % vertical line img on the upper left (middle part) 
img_all((zdim+ydim-ycut)+openness:end,xcut) = colorvalue;% vertical line img on the upper left (lower part)

img_all(1:(zdim-zcut)-openness,xdim+ycut) = colorvalue; % vertical line img on the upper left (upper part)
img_all((zdim-zcut)+openness:zdim,xdim+ycut) = colorvalue; % vertical line img on the upper left (lower part)

img_all(zdim-zcut,1:(xdim-xcut)-openness)=colorvalue; %horizontal line upper panel (left part)
img_all(zdim-zcut,(xdim-xcut)+openness:(xdim+ycut)-openness)=colorvalue; %horizontal line upper panel (middle part) 
img_all(zdim-zcut,(xdim+ycut)+openness:end)=colorvalue; %horizontal line upper panel (right part)

img_all(zdim+ydim-ycut,1:(xdim-xcut)-openness) = colorvalue; % horizontal line lower panel (half), left part
img_all(zdim+ydim-ycut,(xdim-xcut)+openness:xdim) = colorvalue; % horizontal line lower panel (half), middle part

%Get colormap
map = nih_lut(256);

% Show image
% figure
% imshow(img_all)% 
% colormap(gca, map)
% caxis([0 12])
% %caxis([0 3.2828])
% saveas(gcf, 'test.jpg')

%Save image
%Scale image to a 0-255 scale (assuming 12 as maximum)
test = round(img_all/12*255);
%Set values bigger than the highest value to maximum
test(test>255) = 255;
%Make it bigger to copy-paste in report as is
test = imresize(test, 2.2);
%Save image

imgname=strcat('wSUV_',sub_info.code,'.png');
imwrite(test, map, imgname)

end


