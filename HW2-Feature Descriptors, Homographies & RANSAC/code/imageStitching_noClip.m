function [panoImg] = imageStitching_noClip(img1, img2, H2to1)
%
% INPUT
% Warps img2 into img1 reference frame using the provided warpH() function
% H2to1 - a 3 x 3 matrix encoding the homography that best matches the linear
%         equation
%
% OUTPUT
% Blends img1 and warped img2 and outputs the panorama image

% % test
% img1 = imread('../data/incline_L.png');
% img2 = imread('../data/incline_R.png');

% initialize the dimension of images 
[H1 W1] = deal(size(img1, 1), size(img1, 2));
[H2 W2] = deal(size(img2, 1), size(img2, 2));
[H_out W_out] =deal(800, 1800);

% define the corners of img2
corner = [1 1 1; 1 H2 1; W2 1 1; W2 H2 1];

% perform warping on the corners
warp_c = H2to1 * corner';

% divided by the last line of dummy
dummy = repmat(warp_c(3,:), 3, 1); 
warp_c = warp_c ./ dummy;

% generate matrix M for scaling and translating
translate_width = min(min(warp_c(1,:)), 1);
width = max(max(warp_c(1,:)), W1) - translate_width;

translate_height = min(min(warp_c(2,:)), 1);
height = max(max(warp_c(2,:)), H1) - translate_height;

scalar = W_out / width;
out_size = [ceil(scalar * height) W_out];

M = [scalar 0 -translate_width; 0 scalar -translate_height; 0 0 1];

% stitch images together to produce panorams

mask_img1 = zeros(size(img1,1), size(img1,2), size(img1,3));
mask_img1(1,:) = 1; mask_img1(end,:) = 1; mask_img1(:,1) = 1; mask_img1(:,end) = 1;
mask_img1 = bwdist(mask_img1, 'city');
mask_img1 = mask_img1/max(mask_img1(:));
mask1_warped = warpH(mask_img1, M, out_size);

warped1 = im2double(warpH(img1, M, out_size));
result1 = warped1 .* mask1_warped;

mask_img2 = zeros(size(img2,1), size(img2,2), size(img2,3));
mask_img2(1,:) = 1; mask_img2(end,:) = 1; mask_img2(:,1) = 1; mask_img2(:,end) = 1;
mask_img2 = bwdist(mask_img2, 'city');
mask_img2 = mask_img2/max(mask_img2(:));
mask2_warped = warpH(mask_img2, M * H2to1, out_size);

warped2 = im2double(warpH(img2, M * H2to1, out_size));
result2 = warped2 .* mask2_warped;

panoImg = (result1 + result2) ./ (mask1_warped + mask2_warped);

% show and write to the disk 
imshow(panoImg);
imwrite(panoImg, '../results/q6_2_pan.jpg');

end 
