function T = tensor_product(A, B)
% TENSOR_PRODUCT  Compute the tensor (Kronecker) product of two matrices.
%
% Objective:
%   Provide a wrapper around MATLAB's kron function to explicitly
%   represent the tensor product:
%
%       T = A ⊗ B
%
%   This improves code readability and aligns implementation with
%   the mathematical notation used in the theoretical model.
%
% Input:
%   A - numeric 2-D matrix
%   B - numeric 2-D matrix
%
% Output:
%   T - matrix representing the tensor product A ⊗ B
%
% Notes:
%   This function centralizes tensor-product operations in the simulator.
%
%   It allows future extensions such as:
%       - dimension checks
%       - sparse implementations
%       - custom tensor structures

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('tensor_product:InvalidNumInputs', ...
            'Expected exactly 2 input arguments: A and B.');
    end

    if ~isnumeric(A) || ~ismatrix(A)
        error('tensor_product:InvalidTypeA', ...
            'A must be a numeric 2-D matrix.');
    end

    if ~isnumeric(B) || ~ismatrix(B)
        error('tensor_product:InvalidTypeB', ...
            'B must be a numeric 2-D matrix.');
    end

    
    % =========================
    % Main computation
    % =========================

    T = kron(A, B);

end