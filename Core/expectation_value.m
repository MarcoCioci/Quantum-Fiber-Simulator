function exp_val = expectation_value(psi, O)
% EXPECTATION_VALUE  Compute the expectation value of an operator for a pure state.
%
% Objective:
%   Evaluate the expectation value
%
%       exp_val = psi' * O * psi
%
%   for a pure-state vector psi and an operator O acting on the same
%   Hilbert space.
%
% Input:
%   psi - n x 1 complex column vector representing a pure quantum state
%   O   - n x n numeric matrix representing an operator on the same space
%
% Output:
%   exp_val - scalar expectation value of O in the state psi
%
% Notes:
%   This function is dimension-general: it is not restricted to the
%   two-qubit case.
%
%   If O is Hermitian and psi is normalized, then exp_val should be real
%   up to small numerical round-off errors.
%
%   In the present simulator, this function is used for quantities such as
%   two-qubit correlation observables.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('expectation_value:InvalidNumInputs', ...
            'Expected exactly 2 input arguments: psi and O.');
    end

    if ~isnumeric(psi) || ~isvector(psi)
        error('expectation_value:InvalidTypePsi', ...
            'psi must be a numeric state vector.');
    end

    if ~isnumeric(O) || ~ismatrix(O)
        error('expectation_value:InvalidTypeOperator', ...
            'O must be a numeric 2-D matrix.');
    end

    psi = psi(:);
    n = length(psi);

    if ~isequal(size(O), [n n])
        error('expectation_value:DimensionMismatch', ...
            'O must be an n x n matrix, where n = length(psi).');
    end

    if exist('is_normalized', 'file') == 2 && ~is_normalized(psi)
        warning('expectation_value:StateNotNormalized', ...
            ['psi does not appear to be normalized. ', ...
             'The returned value may not correspond to a valid physical expectation value.']);
    end

    
    % =========================
    % Main computations
    % =========================

    exp_val = psi' * O * psi;

    % Post-processing
    tol = 1e-10;

    if norm(O - O', 'fro') <= tol
        if abs(imag(exp_val)) > tol
            warning('expectation_value:NonRealResidual', ...
                ['Expectation value has a non-negligible imaginary part ', ...
                 'despite O being numerically Hermitian.']);
        end
        exp_val = real(exp_val);
    end

end