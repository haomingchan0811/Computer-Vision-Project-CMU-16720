function [locs,desc] = computeBrief(im, GaussianPyramid, locsDoG, k, ...
                                        levels, compareA, compareB)
%%Compute BRIEF feature
% INPUTS
% im      - a grayscale image with values from 0 to 1
% locsDoG - locsDoG are the keypoint locations returned by the DoG detector
% levels  - Gaussian scale levels that were given in Section1
% compareA and compareB - linear indices into the patchWidth x patchWidth image 
%                         patch and are each nbits x 1 vectors
%
% OUTPUTS
% locs - an m x 3 vector, where the first two columns are the image coordinates 
%		 of keypoints and the third column is the pyramid level of the keypoints
% desc - an m x n bits matrix of stacked BRIEF descriptors. m is the number of 
%        valid descriptors in the image and will vary

% % test
% im = imread('../data/model_chickenbroth.jpg');
% sigma0 = 1;
% k = sqrt(2);
% levels = [-1, 0, 1, 2, 3, 4];
% [th_r, th_contrast] = deal(12, 0.03);
% GaussianPyramid = createGaussianPyramid(im, sigma0, k, levels);
% im = rgb2gray(im2double(im));
% [DoGPyramid, DoGLevels] = createDoGPyramid(GaussianPyramid, levels);
% PrincipalCurvature = computePrincipalCurvature(DoGPyramid);
% locsDoG = getLocalExtrema(DoGPyramid, DoGLevels, PrincipalCurvature, th_contrast, th_r)
% [compareA, compareB] = makeTestPattern(9, 256);

% initialize 
nbits = size(compareA, 1);
patchWidth = 9;
b = 4;  % half of the batch size
[H, W] = deal(size(GaussianPyramid,1), size(GaussianPyramid,2));

% filter out the edged points 
validRows = locsDoG(:,1) > b & locsDoG(:,1) <= W-b ...
          & locsDoG(:,2) > b & locsDoG(:,2) <= H-b;
locs = locsDoG(validRows, :);


% initialize desc matrix
m = size(locs, 1);
desc = zeros(m, nbits);

% map indices of batch into coordinates
coor = cell(1, 4);
[coor{1}, coor{2}] = ind2sub([patchWidth,patchWidth], compareA);
[coor{3}, coor{4}] = ind2sub([patchWidth,patchWidth], compareB);

% compute coordinates of the tests
for i = 1:4
    % offset in the batch
    offset = repmat((coor{i}-5)', m, 1);  
    
    if mod(i, 2)   % x-coordinates
        coor{i} = repmat(locs(:,1), 1, nbits) + offset;
    else           % y-coordinates
        coor{i} = repmat(locs(:,2), 1, nbits) + offset;
    end
end

% compute the index of the levels L
L = locs(:,3);
for i = 1:m
    L(i, 1) = find(levels == L(i, 1));
end

% computer descpritor
for i = 1:m
    for j = 1:nbits
        % fetch the corresponding coordinates
        [Ax, Bx] = deal(coor{1}(i,j), coor{3}(i,j));
        [Ay, By] = deal(coor{2}(i,j), coor{4}(i,j));

        l = L(i, 1);  % corresponding level index
        desc(i,j) = GaussianPyramid(Ay,Ax,l) < GaussianPyramid(By,Bx,l);
%         desc(i,j) = im(Ay,Ax,l) < im(By,Bx,l);
    end
end

end
    