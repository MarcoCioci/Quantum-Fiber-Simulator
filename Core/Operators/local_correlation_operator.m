function O_ab = local_correlation_operator(a, b)
% LOCAL_CORRELATION_OPERATOR  Build a two-qubit correlation observable for arbitrary local axes.
%
% Objective:
%   Construct the bipartite measurement operator
%
%       O_ab = σ(a) ⊗ σ(b)
%
%   where σ(a) and σ(b) are single-qubit Pauli observables along
%   arbitrary real unit vectors a and b on the Bloch sphere.
%
% Input:
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
%   O_ab - 4x4 Hermitian matrix representing the two-qubit observable
%
%              σ(a) ⊗ σ(b)
%
%          in the fixed computational basis:
%
%              {|00⟩, |01⟩, |10⟩, |11⟩}
%
% Notes:
%   This function implements the operator-level form of the arbitrary-axis
%   correlation measurement.
%
%   It does not evaluate the expectation value. It only builds the observable
%   to be passed later to expectation_value_density or a dedicated
%   arbitrary-axis correlation function.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('local_correlation_operator:InvalidNumInputs', ...
              'Expected exactly 2 input arguments.');
    end

    if ~isnumeric(a)
        error('local_correlation_operator:InvalidTypeA', ...
              'a must be a numeric vector.');
    end

    if ~isnumeric(b)
        error('local_correlation_operator:InvalidTypeB', ...
              'b must be a numeric vector.');
    end

    if ~isreal(a)
        error('local_correlation_operator:InvalidComplexInputA', ...
              'a must be real.');
    end

    if ~isreal(b)
        error('local_correlation_operator:InvalidComplexInputB', ...
              'b must be real.');
    end

    if ~isvector(a)
        error('local_correlation_operator:InvalidShapeA', ...
              'a must be a vector with 3 components.');
    end

    if ~isvector(b)
        error('local_correlation_operator:InvalidShapeB', ...
              'b must be a vector with 3 components.');
    end

    if numel(a) ~= 3
        error('local_correlation_operator:InvalidSizeA', ...
              'a must contain exactly 3 components.');
    end

    if numel(b) ~= 3
        error('local_correlation_operator:InvalidSizeB', ...
              'b must contain exactly 3 components.');
    end


    % =========================
    % Main computation
    % =========================

    sigma_a = measurement_operator_axis(a);
    sigma_b = measurement_operator_axis(b);
    
    O_ab = tensor_product(sigma_a, sigma_b);

    hermitian_tolerance = 1e-10;
    if norm(O_ab - O_ab', 'fro') > hermitian_tolerance
        error('local_correlation_operator:NotHermitian', ...
              'O_ab must be Hermitian: O_ab must be equal to O_ab''.');
    end
    O_ab = (O_ab + O_ab') / 2; % Numerical clean-up

end