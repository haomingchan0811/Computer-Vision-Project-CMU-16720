function H2to1 = computeH(p1,p2)
% INPUTS:
% p1 and p2 - Each are size (2 x N) matrices of corresponding (x, y)'  
%             coordinates between two images
%
% OUTPUTS:
% H2to1 - a 3 x 3 matrix encoding the homography that best matches the linear 
%         equation

% number of points 
N = size(p1, 2);

% append dummy 1s into the point vector
p1 = ([p1; ones(1, N)])';
p2 = ([p2; ones(1, N)])';

% contruct matrix A
A = zeros(2 * N, 9);
for i = 1:N
   A(2 * i - 1, :) = [p2(i,:), 0, 0, 0, -p1(i,1) * p2(i,:)];   % odd rows of A 
   A(2 * i, :) = [0, 0, 0, p2(i,:), -p1(i,2) * p2(i,:)];       % even rows of A 
end


% compute Homography matrix
[V, D] = eig(A' * A);
H2to1 = reshape(V(:,1), 3, 3);
H2to1 = H2to1';

% [U, S, V] = svd(A' * A);
% H2to1 = reshape(U(:,9),3,3);
% H2to1 = H2to1';

end



