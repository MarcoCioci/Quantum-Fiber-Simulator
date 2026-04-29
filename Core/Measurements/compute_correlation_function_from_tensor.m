function E_ab = compute_correlation_function_from_tensor(T, a, b)
% COMPUTE_CORRELATION_FUNCTION_FROM_TENSOR  Compute arbitrary-axis correlation from a correlation tensor.
%
% Objective:
%   Compute the two-qubit correlation function
%
%       E(a,b) = a^T T b
%
%   using the 3x3 correlation tensor T and two arbitrary local measurement
%   axes a and b.
%
% Input:
%   T - 3x3 real numeric matrix representing the two-qubit correlation tensor
%       with entries
%
%           T_ij = < sigma_i ⊗ sigma_j >
%
%       for i,j in {x,y,z}.
%
%   a - real numeric vector with 3 components representing the measurement
%       direction on subsystem A:
%
%           a = [a_x; a_y; a_z]
%
%   b - real numeric vector with 3 components representing the measurement
%       direction on subsystem B:
%
%           b = [b_x; b_y; b_z]
%
% Output:
%   E_ab - real scalar correlation value computed as
%
%              E_ab = a^T T b
%
% Notes:
%   This function implements the tensor-level shortcut for arbitrary-axis
%   correlations. It should give the same result as compute_correlation_function_from_state
%   when T is computed from the same state rho_AB.
%
%   This routine is useful when many different pairs of measurement axes are
%   evaluated for the same state, because T only needs to be computed once.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('compute_correlation_function_from_tensor:InvalidNumInputs', ...
              'Expected exactly 3 input arguments.');
    end

    if ~isnumeric(T)
        error('compute_correlation_function_from_tensor:InvalidTensorType', ...
              'T must be numeric.');
    end

    if ~isequal(size(T), [3, 3])
        error('compute_correlation_function_from_tensor:InvalidTensorSize', ...
              'T must be a 3x3 matrix.');
    end

    if ~isreal(T)
        error('compute_correlation_function_from_tensor:InvalidTensorComplexInput', ...
              'T must be real.');
    end

    if ~isnumeric(a)
        error('compute_correlation_function_from_tensor:InvalidTypeA', ...
              'a must be a numeric vector.');
    end

    if ~isnumeric(b)
        error('compute_correlation_function_from_tensor:InvalidTypeB', ...
              'b must be a numeric vector.');
    end

    if ~isreal(a)
        error('compute_correlation_function_from_tensor:InvalidComplexInputA', ...
              'a must be real.');
    end

    if ~isreal(b)
        error('compute_correlation_function_from_tensor:InvalidComplexInputB', ...
              'b must be real.');
    end

    if ~isvector(a)
        error('compute_correlation_function_from_tensor:InvalidShapeA', ...
              'a must be a vector with 3 components.');
    end

    if ~isvector(b)
        error('compute_correlation_function_from_tensor:InvalidShapeB', ...
              'b must be a vector with 3 components.');
    end

    if numel(a) ~= 3
        error('compute_correlation_function_from_tensor:InvalidSizeA', ...
              'a must contain exactly 3 components.');
    end

    if numel(b) ~= 3
        error('compute_correlation_function_from_tensor:InvalidSizeB', ...
              'b must contain exactly 3 components.');
    end

    a = a(:);
    b = b(:);

    normalization_tolerance = 1e-12;

    if abs(norm(a) - 1) > normalization_tolerance
        error('compute_correlation_function_from_tensor:AxisANotNormalized', ...
              'a must be normalized: norm(a) must be equal to 1.');
    end

    if abs(norm(b) - 1) > normalization_tolerance
        error('compute_correlation_function_from_tensor:AxisBNotNormalized', ...
              'b must be normalized: norm(b) must be equal to 1.');
    end


    % =========================
    % Main computation
    % =========================

    E_ab = a.' * T * b;

    realness_tolerance = 1e-10;
    if abs(imag(E_ab)) > realness_tolerance
        error('compute_correlation_function_from_tensor:NotReal', ...
              'E_ab must be real-valued.');
    end

    E_ab = real(E_ab); % Numerical clean up

    range_tolerance = 1e-10;
    if abs((E_ab)) > 1 + range_tolerance
        error('compute_correlation_function_from_tensor:OutOfRange', ...
              'E_ab must satisfy abs(E_ab) <= 1.');
    end

end