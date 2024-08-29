%read in sample image and make grayscale
fixed = imread('konklebgs/office_zoom0_4.jpg');
fixed = rgb2gray(fixed);

%wierd transformation to test from matlab demo code, does a shift and shear
A = [1.25 0 0; 0.33 1 0; 0 0 1];
tform = affine2d(A);
moving = imwarp(fixed,tform);  %moving is our distorted (moved if its a shift) image
figure(1);
imshowpair(fixed,moving,"Scaling","joint");  %Gray is where overlap, green and purple are not

%Try to register two images this will give the tform that brings moving
%back to fixed
[optimizer,metric] = imregconfig("monomodal")
reg_tform = imregtform(moving,fixed,"affine",optimizer,metric);
%That transform is the inverse of our original since it goes backwards
disp(inv(reg_tform.T));

%Shift the distorted image back to the original
movingRegistered = imwarp(moving,reg_tform,'OutputView',imref2d(size(fixed)));
figure(2)
imshowpair(fixed,movingRegistered,"Scaling","joint");  %Gray is where overlap, green and purple are not