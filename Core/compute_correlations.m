function corr = compute_correlations(psi)
% COMPUTE_CORRELATIONS  Evaluate standard two-qubit correlation observables.
%
% Objective:
%   Compute the expectation values of the standard two-qubit
%   correlation operators:
%
%       sigma_x ⊗ sigma_x
%       sigma_y ⊗ sigma_y
%       sigma_z ⊗ sigma_z
%
%   for a given two-qubit pure state psi.
%
% Input:
%   psi  - 4x1 complex column vector representing a two-qubit pure state
%
% Output:
%   corr - structure containing the correlation values:
%          corr.c_xx
%          corr.c_yy
%          corr.c_zz
%
% Notes:
%   The input state is assumed to be expressed in the computational basis:
%
%       {|00>, |01>, |10>, |11>}
%
%   This function centralizes correlation evaluation for the three
%   aligned Pauli-Pauli observables and simplifies experiment scripts.
%
%   If psi is normalized and represents a valid pure state, then the
%   returned correlations should be real and lie in the interval [-1, 1],
%   up to small numerical round-off errors.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_correlations:InvalidNumInputs', ...
            'Expected exactly 1 input argument: psi.');
    end

    if ~isnumeric(psi) || ~isvector(psi)
        error('compute_correlations:InvalidType', ...
            'psi must be a numeric state vector.');
    end

    psi = psi(:);

    if ~isequal(size(psi), [4 1])
        error('compute_correlations:InvalidSize', ...
            'psi must be a 4x1 column vector.');
    end

    if exist('is_normalized', 'file') == 2 && ~is_normalized(psi)
        warning('compute_correlations:StateNotNormalized', ...
            ['psi does not appear to be normalized. ', ...
             'Returned expectation values may not correspond to a valid quantum state.']);
    end

    
    % =========================
    % Main computations
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    O_xx = correlation_operator(sigma_x, sigma_x);
    O_yy = correlation_operator(sigma_y, sigma_y);
    O_zz = correlation_operator(sigma_z, sigma_z);

    corr = struct();

    corr.c_xx = real(expectation_value(psi, O_xx));
    corr.c_yy = real(expectation_value(psi, O_yy));
    corr.c_zz = real(expectation_value(psi, O_zz));

end