function correlations = compute_correlations_density(rho)
% COMPUTE_CORRELATIONS  Evaluate standard two-qubit Pauli correlations
% for a state represented by a density matrix.
%
% Objective:
%   Compute the expectation values of the aligned two-qubit correlation
%   observables
%
%       sigma_x ⊗ sigma_x
%       sigma_y ⊗ sigma_y
%       sigma_z ⊗ sigma_z
%
%   for a two-qubit quantum state represented in density-matrix form.
%
% Input:
%   rho - 4x4 complex density matrix representing a two-qubit quantum state
%
% Output:
%   correlations - structure containing the correlation values:
%          correlations.c_xx
%          correlations.c_yy
%          correlations.c_zz
%
% Notes:
%   This function is the mixed-state analogue of compute_correlations(psi).
%
%   The expectation values are evaluated through the density-matrix formula
%
%       <O> = Tr(rho * O)
%
%   using the helper function expectation_value_density.
%
%   The input state is assumed to be expressed in the computational basis:
%
%       {|00>, |01>, |10>, |11>}
%
%   This function centralizes the evaluation of the three standard aligned
%   Pauli-Pauli correlations used throughout Experiment 2 and later studies
%   of decoherence and entanglement degradation.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_correlations_density:InvalidNumInputs', ...
              'Expected exactly 1 input argument: rho.');
    end

    if ~isnumeric(rho)
        error('compute_correlations_density:InvalidTypeRho', ...
              'rho must be numeric.');
    end

    if isempty(rho)
        error('compute_correlations_density:EmptyRho', ...
              'rho must be non-empty.');
    end

    if ~isequal(size(rho), [4, 4])
        error('compute_correlations_density:InvalidSizeRho', ...
              'rho must be a 4x4 matrix.');
    end

    if any(~isfinite(rho), 'all')
        error('compute_correlations_density:NonFiniteRho', ...
              'rho must contain only finite values.');
    end


    % =========================
    % Main computations
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    O_xx = tensor_product(sigma_x, sigma_x);
    O_yy = tensor_product(sigma_y, sigma_y);
    O_zz = tensor_product(sigma_z, sigma_z);

    correlations.c_xx = expectation_value_density(rho, O_xx);
    correlations.c_yy = expectation_value_density(rho, O_yy);
    correlations.c_zz = expectation_value_density(rho, O_zz); 

end
