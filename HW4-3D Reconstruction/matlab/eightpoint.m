function [F] = eightpoint(pts1, pts2, M)

% eightpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.1 - Todo:
%     Implement the eightpoint algorithm
%     Generate a matrix F from some '../data/some_corresp.mat'
%     Save F, M, pts1, pts2 to q2_1.mat

%     Write F and display the output of displayEpipolarF in your writeup

% load data in the console

% load('../data/some_corresp.mat');
% I1 = imread('../data/im1.png');
% I2 = imread('../data/im2.png');
% M = max(size(I1, 1), size(I1, 2));

% scale the data to [0,1]
pts1 = pts1 / M;
pts2 = pts2 / M;

% initialize corrdinates
numOfPoints = size(pts1, 1);
[X1, Y1] = deal(pts1(:, 1), pts1(:, 2));
[X2, Y2] = deal(pts2(:, 1), pts2(:, 2));

% build the matrix A where AF(:) = 0
ONES = ones(numOfPoints, 1);
A = [X1 .* X2, X1 .* Y2, X1, Y1 .* X2, Y1 .* Y2, Y1, X2, Y2, ONES];

% compute fundamental matrix
[U, S, V] = svd(A);
F_stacked = V(:, 9);  % the stacked essential matrix
F = reshape(F_stacked, [3 3]);

% project onto essential space (enforce singularity condition)
[U1, S1, V1] = svd(F);
S1(3, 3) = 0;
F = U1 * S1 * V1';

% redine the solution using local minimization
refineF(F, pts1, pts2);

% unscale the fundamental matrix and points 
T = eye(3) / M;
T(3, 3) = 1;
F = T' * F * T;
pts1 = pts1 * M;
pts2 = pts2 * M;

% % display epipolarF
% displayEpipolarF(I1, I2, F);

% save F, M, pts1, pts2 to q2_1.mat
% save('q2_1.mat', 'F', 'M', 'pts1', 'pts2');

end

