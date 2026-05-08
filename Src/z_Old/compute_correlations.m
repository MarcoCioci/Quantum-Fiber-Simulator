function correlations = compute_diagonal_correlations(state)
% COMPUTE_DIAGONAL_CORRELATIONS  Evaluate standard two-qubit Pauli correlations.
%
% Objective:
%   Compute the expectation values of the aligned two-qubit correlation
%   observables
%
%       sigma_x ⊗ sigma_x
%       sigma_y ⊗ sigma_y
%       sigma_z ⊗ sigma_z
%
%   for a two-qubit quantum state represented either as:
%
%       1. a pure state vector
%       2. a density matrix
%
% Input:
%   state - either:
%           * 4x1 complex column vector (pure state)
%           * 4x4 complex density matrix (mixed state)
%
% Output:
%   correlations - structure containing:
%          correlations.c_xx
%          correlations.c_yy
%          correlations.c_zz
%
% Notes:
%   The expectation values are computed as:
%
%       Pure state:      <O> = <psi|O|psi>
%       Density matrix:  <O> = Tr(rho * O)
%
%   The input is assumed in the computational basis:
%
%       {|00>, |01>, |10>, |11>}
%
%   Context in simulator:
%   - Core diagnostic observable in Experiment 1 and 2
%   - Used to validate phase model and noise effects

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_correlations:InvalidNumInputs', ...
              'Expected exactly 1 input argument: state.');
    end

    if ~isnumeric(state)
        error('compute_correlations:InvalidType', ...
              'state must be numeric.');
    end

    if any(~isfinite(real(state(:)))) || any(~isfinite(imag(state(:))))
        error('compute_correlations:InvalidEntries', ...
              'state must contain only finite entries.');
    end


    % =========================
    % Main computation
    % =========================

    if isvector(state)
        correlations = compute_correlations_from_pure_state(state);
        return;
    end

    if ismatrix(state) && all(size(state) == [4, 4])
        correlations = compute_correlations_from_density_matrix(state);
        return;
    end

    error('compute_correlations:InvalidShape', ...
          ['state must be either a 4x1 pure-state vector or a 4x4 ', ...
           'density matrix.']);

end


function correlations = compute_correlations_from_pure_state(psi)
% Internal helper: pure-state branch

    % =========================
    % Robustness checks
    % =========================

    if ~isvector(psi)
        error('compute_correlations:PureStateInvalidShape', ...
              'Pure-state input must be a vector.');
    end

    psi = psi(:);

    if numel(psi) ~= 4
        error('compute_correlations:PureStateInvalidSize', ...
              'Pure-state input must contain exactly 4 elements.');
    end

    if exist('is_normalized', 'file') == 2 && ~is_normalized(psi)
        warning('compute_correlations:StateNotNormalized', ...
            ['psi does not appear to be normalized. ', ...
             'Returned expectation values may not correspond to a valid quantum state.']);
    end


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    O_xx = tensor_product(sigma_x, sigma_x);
    O_yy = tensor_product(sigma_y, sigma_y);
    O_zz = tensor_product(sigma_z, sigma_z);

    correlations = struct();

    correlations.c_xx = real(expectation_value(psi, O_xx));
    correlations.c_yy = real(expectation_value(psi, O_yy));
    correlations.c_zz = real(expectation_value(psi, O_zz));

end


function correlations = compute_correlations_from_density_matrix(rho)
% Internal helper: density-matrix branch

    % =========================
    % Robustness checks
    % =========================

    if ~isequal(size(rho), [4, 4])
        error('compute_correlations:DensityInvalidSize', ...
              'Density-matrix input must be a 4x4 matrix.');
    end

    hermitian_tolerance = 1e-12;

    if norm(rho - rho', 'fro') > hermitian_tolerance
        error('compute_correlations:DensityNonHermitian', ...
              'rho must be Hermitian within tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    O_xx = tensor_product(sigma_x, sigma_x);
    O_yy = tensor_product(sigma_y, sigma_y);
    O_zz = tensor_product(sigma_z, sigma_z);

    correlations = struct();

    correlations.c_xx = real(expectation_value_density(rho, O_xx));
    correlations.c_yy = real(expectation_value_density(rho, O_yy));
    correlations.c_zz = real(expectation_value_density(rho, O_zz));

end