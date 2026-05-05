function correlations = compute_diagonal_correlations(state)
% COMPUTE_DIAGONAL_CORRELATIONS  Extract aligned Pauli correlations from full tensor
%
% Objective:
%   Compute the standard aligned two-qubit correlation observables:
%
%       σ_x ⊗ σ_x
%       σ_y ⊗ σ_y
%       σ_z ⊗ σ_z
%
%   by extracting the diagonal entries of the full correlation tensor.
%
% Input:
%   state - either:
%           * 4x1 complex column vector (pure state)
%           * 4x4 complex density matrix (mixed state)
%
% Output:
%   correlations - structure containing:
%       correlations.c_xx
%       correlations.c_yy
%       correlations.c_zz
%
% Notes:
%   This function acts as a wrapper around compute_correlation_tensor(),
%   ensuring consistency across all correlation computations.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_diagonal_correlations:InvalidNumInputs', ...
              'Expected exactly 1 input argument.');
    end

    if ~isnumeric(state)
        error('compute_diagonal_correlations:InvalidType', ...
              'state must be numeric.');
    end


    % =========================
    % Main computation
    % =========================

    T = compute_correlation_tensor(state);

    correlations = struct();

    correlations.c_xx = T(1,1);
    correlations.c_yy = T(2,2);
    correlations.c_zz = T(3,3);

end