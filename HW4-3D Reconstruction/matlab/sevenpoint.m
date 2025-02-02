function [F] = sevenpoint(pts1, pts2, M)
% sevenpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.2 - Todo:
%     Implement the sevenpoint algorithm
%     Generate a matrix F from some '../data/some_corresp.mat'
%     Save recovered F (either 1 or 3 in cell), M, pts1, pts2 to q2_2.mat

%     Write recovered F and display the output of displayEpipolarF in your writeup

% load data in the console

I1 = imread('../data/im1.png');
I2 = imread('../data/im2.png');
M = max(size(I1, 1), size(I1, 2));

% cpselect(I1, I2);   % select points manually
% save('../data/q2_2_corresp.mat', 'pts1', 'pts2');

% load('../data/q2_2_corresp.mat');

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

% compute 2 vectores that span the null space of A
[U, S, V] = svd(A);
F1_stacked = V(:, 9);  % the stacked matrix
F2_stacked = V(:, 8);  % the stacked matrix
F1 = reshape(F1_stacked, [3 3]);
F2 = reshape(F2_stacked, [3 3]);
[F1, F2] = deal(F1', F2');

% solve equation: Det(alpha * F1 + (1 - alpha) * F2) = 0
syms w;    % create symbolic variable for the equation
equation = det(w * F1 + (1 - w) * F2) == 0;
sols = solve(equation, w);

% fetch the real solutions
sols = double(sols);
alpha = real(sols);   

% Compute the fundamental matrices
T = eye(3) / M;
T(3, 3) = 1;
size_alpha = size(alpha, 1);
F = cell(1, size_alpha);

for i = 1: size_alpha
   F{i} = alpha(i) * F1 + (1 - alpha(i)) * F2;
end

% unscale the fundamental matrix and points 
for i = 1: size_alpha
   F{i} = T' * F{i} * T;
end
pts1 = pts1 * M;
pts2 = pts2 * M;

% display epipolarF
% F{3}
% displayEpipolarF(I1, I2, F{3});

% save F, M, pts1, pts2 to q2_2.mat
% save('q2_2.mat', 'F', 'M', 'pts1', 'pts2');

end

