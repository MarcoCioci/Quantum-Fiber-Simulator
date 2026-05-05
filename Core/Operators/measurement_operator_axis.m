function sigma_n = measurement_operator_axis(n)
% MEASUREMENT_OPERATOR_AXIS  Build a single-qubit Pauli observable along an arbitrary axis.
%
% Objective:
%   Construct the Hermitian single-qubit measurement operator
%
%       σ(n) = n_x σ_x + n_y σ_y + n_z σ_z
%
%   associated with a real unit vector n on the Bloch sphere.
%
% Input:
%   n - real numeric vector with 3 components representing the measurement
%       direction:
%
%           n = [n_x; n_y; n_z]
%
%       Row vectors are accepted and internally interpreted as column vectors.
%
% Output:
%   sigma_n - 2x2 Hermitian matrix representing the Pauli observable along
%             direction n.
%
% Notes:
%   This function implements the elementary building block required for
%   arbitrary local measurement axes. It generalizes the fixed Pauli
%   observables σ_x, σ_y, σ_z already used in aligned
%   correlation measurements.
%
%   The input vector must be normalized because σ(n) represents a
%   physical two-outcome Pauli measurement only when ||n|| = 1.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('measurement_operator_axis:InvalidNumInputs', ...
              'Expected exactly 1 input argument.');
    end

    if ~isnumeric(n)
        error('measurement_operator_axis:InvalidType', ...
              'n must be a numeric vector.');
    end

    if ~isreal(n)
        error('measurement_operator_axis:InvalidComplexInput', ...
              'n must be real.');
    end

    if ~isvector(n)
        error('measurement_operator_axis:InvalidShape', ...
              'n must be a vector with 3 components.');
    end

    if numel(n) ~= 3
        error('measurement_operator_axis:InvalidSize', ...
              'n must contain exactly 3 components.');
    end

    n = n(:);

    tolerance = 1e-12;

    if abs(norm(n) - 1) > tolerance
        error('measurement_operator_axis:NotNormalized', ...
              'n must be normalized: norm(n) must be equal to 1.');
    end


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    n_x = n(1);
    n_y = n(2);
    n_z = n(3);

    sigma_n = n_x * sigma_x + n_y * sigma_y + n_z * sigma_z;
    
    hermitian_tolerance = 1e-10;
    if norm(sigma_n - sigma_n', 'fro') > hermitian_tolerance
        error('measurement_operator_axis:NotHermitian', ...
              'sigma_n must be Hermitian: sigma_n must be equal to sigma_n''.');
    end
    sigma_n = (sigma_n + sigma_n') / 2; % Numerical clean-up

end

