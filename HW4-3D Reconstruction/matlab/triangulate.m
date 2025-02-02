function [P, error] = triangulate(C1, p1, C2, p2)

% triangulate:
%       C1 - 3x4 Camera Matrix 1
%       p1 - Nx2 set of points
%       C2 - 3x4 Camera Matrix 2
%       p2 - Nx2 set of points

% Q2.4 - Todo:
%       Implement a triangulation algorithm to compute the 3d locations
%

% linear triangulation
% http://www.ics.uci.edu/~dramanan/teaching/cs217_spring09/lec/stereo.pdf

% parameter initialization
num_points = size(p1, 1);
P = zeros(num_points, 3);  % matrix of 3D coordinates
[c11, c12, c13] = deal(C1(1,:), C1(2,:), C1(3,:));
[c21, c22, c23] = deal(C2(1,:), C2(2,:), C2(3,:));

for i = 1: num_points
    [p1x, p1y] = deal(p1(i, 1), p1(i, 2));
    [p2x, p2y] = deal(p2(i, 1), p2(i, 2));
    
    % generate AP = 0
    A = [p1x * c13 - c11; ... 
         p1y * c13 - c12; ...
         p2x * c23 - c21; ...
         p2y * c23 - c22];
    
    % singular value decomposition to compute P
    [U, S, V] = svd(A);
    v = V(:, 4);  % last column
    P(i, :) = v(1:3)' ./ v(4);  
end 


% homogenous coordinates of 3D points
ONES = ones(1, num_points);
P_h = [P'; ONES];


% projection to 2D points
p1_proj = C1 * P_h;
p2_proj = C2 * P_h;

% convert to homogeneous coordinations
p1_hat = zeros(num_points, 2);
p2_hat = zeros(num_points, 2);
for i = 1: num_points
    scalar1 = p1_proj(3, i);
    scalar2 = p2_proj(3, i);
    p1_hat(i, :) = p1_proj(1:2, i)' / scalar1;
    p2_hat(i, :) = p2_proj(1:2, i)' / scalar2;
end

% compute error using mean squre error
mse1 = sum((p1 - p1_hat) .^ 2);
mse2 = sum((p2 - p2_hat) .^ 2);
error = mse1 + mse2;

end

