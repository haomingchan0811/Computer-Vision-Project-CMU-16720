function [output, act_h, act_a] = Forward(W, b, X)
% [OUT, act_h, act_a] = Forward(W, b, X) performs forward propogation on the
% input data 'X' uisng the network defined by weights and biases 'W' and 'b'
% (as generated by InitializeNetwork(..)).
%
% This function should return the final softmax output layer activations in OUT,
% as well as the hidden layer post activations in 'act_h', and the hidden layer
% pre activations in 'act_a'.

% retrieve parameters
sizeL = length(W);
input = X;   % initialize input (N X 1)

% initialize intermediate matrices
act_a = cell(sizeL, 1);
act_h = cell(sizeL, 1);

    % sigmoid function for a vector (K x 1)
    function [h] = sigmoid(M)
        h = 1.0 ./ (exp(-M) + 1);   
    end 

% forward propogation
for i = 1:sizeL
    act_a{i} = W{i}' * input + b{i}';   % pre-activation: (K x 1)
    act_h{i} = sigmoid(act_a{i});       % post-activation
    input = act_h{i};  % update input for next layer
end

% softmax for classification
Y = act_a{sizeL};               % pre-activation of the final layer
sumOfExp = sum(exp(Y)); 
output = exp(Y) / sumOfExp;     % softmax output (C x 1)
act_h{sizeL} = output;

end
