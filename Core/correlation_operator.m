function O = correlation_operator(A, B)
% CORRELATION_OPERATOR  Construct a bipartite product operator A ⊗ B.
%
% Objective:
%   Construct the tensor-product operator
%
%       O = A ⊗ B
%
%   from two local operators A and B acting on subsystems A and B,
%   respectively.
%
% Input:
%   A - square numeric matrix acting on subsystem A
%   B - square numeric matrix acting on subsystem B
%
% Output:
%   O - numeric matrix representing the bipartite operator A ⊗ B
%
% Notes:
%   This function is dimension-general: A and B do not need to be 2x2.
%
%   If A is n_A x n_A and B is n_B x n_B, then:
%
%       O is (n_A*n_B) x (n_A*n_B)
%
%   In the two-qubit case, this gives standard operators such as:
%
%       sigma_x ⊗ sigma_x
%       sigma_y ⊗ sigma_y
%       sigma_z ⊗ sigma_z
%
%   This function only constructs the tensor-product operator.
%   It does not check whether A and B are Hermitian, unitary,
%   or physically valid observables.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('correlation_operator:InvalidNumInputs', ...
            'Expected exactly 2 input arguments: A and B.');
    end

    if ~isnumeric(A) || ~ismatrix(A)
        error('correlation_operator:InvalidTypeA', ...
            'A must be a numeric 2-D matrix.');
    end

    if ~isnumeric(B) || ~ismatrix(B)
        error('correlation_operator:InvalidTypeB', ...
            'B must be a numeric 2-D matrix.');
    end

    [mA, nA] = size(A);
    [mB, nB] = size(B);

    if mA ~= nA
        error('correlation_operator:ANotSquare', ...
            'A must be a square matrix.');
    end

    if mB ~= nB
        error('correlation_operator:BNotSquare', ...
            'B must be a square matrix.');
    end

    
    % =========================
    % Main computation
    % =========================

    O = tensor_product(A, B);

end