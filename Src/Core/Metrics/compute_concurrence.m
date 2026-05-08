function C = compute_concurrence(state)
% COMPUTE_CONCURRENCE  Compute the concurrence of a two-qubit pure state or density matrix.
%
% Objective:
%   Compute the concurrence of a two-qubit quantum state represented either
%   as:
%
%       1. a normalized pure state vector
%       2. a valid density matrix
%
%   The routine automatically detects the input type and applies the
%   appropriate formula:
%
%       - Pure-state formula:
%           C = 2 * |a*d - b*c|
%
%       - Mixed-state Wootters formula:
%           C(ρ) = max(0, λ₁ - λ₂ - λ₃ - λ₄)
%
%   where λ_i are the square roots of the eigenvalues of
%
%       ρ * ρ_tilde,
%
%   ordered in descending order, and
%
%       ρ_tilde = (σ_y ⊗ σ_y) * ρ* * (σ_y ⊗ σ_y).
%
% Input:
%   state - either:
%           * 4x1 complex column vector representing a normalized pure
%             two-qubit state in the computational basis
%
%                 {|00⟩, |01⟩, |10⟩, |11⟩}
%
%           * 4x4 complex density matrix representing a two-qubit mixed
%             state in the same basis
%
% Output:
%   C     - concurrence value, expected to satisfy 0 <= C <= 1 up to small
%           numerical tolerance
%
% Notes:
%   Assumptions for vector input:
%   - The input must be a normalized pure two-qubit state.
%
%   Assumptions for matrix input:
%   - The input must be Hermitian.
%   - The input must have unit trace.
%   - The input must be positive semidefinite up to numerical tolerance.
%
%   Context in simulator:
%   - Bell states should give C = 1.
%   - The state (|01⟩ + exp(i*θ)|10⟩)/sqrt(2) should give C = 1
%     for every θ.
%   - Product states should give C = 0.
%   - Mixed noisy or ensemble states require the density-matrix branch.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('compute_concurrence:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(state)
        error('compute_concurrence:InvalidType', ...
              'state must be numeric.');
    end

    if any(~isfinite(real(state(:)))) || any(~isfinite(imag(state(:))))
        error('compute_concurrence:InvalidEntries', ...
              'state must contain only finite entries.');
    end


    % =========================
    % Main computation
    % =========================

    if isvector(state)
        C = compute_concurrence_from_pure_state(state);
        return;
    end

    if ismatrix(state) && all(size(state) == [4, 4])
        C = compute_concurrence_from_density_matrix(state);
        return;
    end

    error('compute_concurrence:InvalidShape', ...
          ['state must be either a 4x1 pure-state vector or a 4x4 ', ...
           'density matrix.']);

end


function C = compute_concurrence_from_pure_state(psi)
% COMPUTE_CONCURRENCE_FROM_PURE_STATE
% Internal helper for pure-state concurrence.

    % =========================
    % Robustness checks
    % =========================

    if ~isvector(psi)
        error('compute_concurrence:PureStateInvalidShape', ...
              'Pure-state input must be a vector.');
    end

    if numel(psi) ~= 4
        error('compute_concurrence:PureStateInvalidSize', ...
              'Pure-state input must contain exactly 4 elements.');
    end

    if size(psi, 2) ~= 1
        error('compute_concurrence:PureStateInvalidOrientation', ...
              'Pure-state input must be provided as a 4x1 column vector.');
    end

    norm_psi = norm(psi);

    if norm_psi == 0
        error('compute_concurrence:PureStateZeroVector', ...
              'Pure-state input must not be the zero vector.');
    end

    tolerance = 1e-12;

    if abs(norm_psi - 1) > tolerance
        error('compute_concurrence:PureStateNonNormalized', ...
              'Pure-state input must be normalized to unit norm within tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    a = psi(1);
    b = psi(2);
    c = psi(3);
    d = psi(4);

    C = 2 * abs(a * d - b * c);

    if C > 1 + tolerance
        error('compute_concurrence:PureStateInvalidValue', ...
              'Computed concurrence lies outside the admissible range [0, 1].');
    end

    C = min(max(C, 0), 1);

end


function C = compute_concurrence_from_density_matrix(rho)
% COMPUTE_CONCURRENCE_FROM_DENSITY_MATRIX
% Internal helper for density-matrix concurrence.

    % =========================
    % Robustness checks
    % =========================

    if ~ismatrix(rho) || any(size(rho) ~= [4, 4])
        error('compute_concurrence:DensityInvalidSize', ...
              'Density-matrix input must be a 4x4 matrix.');
    end

    hermitian_tolerance  = 1e-12;
    trace_tolerance      = 1e-12;
    positivity_tolerance = 1e-12;
    concurrence_tolerance = 1e-12;

    if norm(rho - rho', 'fro') > hermitian_tolerance
        error('compute_concurrence:DensityNonHermitian', ...
              'Density-matrix input must be Hermitian within tolerance.');
    end

    if abs(trace(rho) - 1) > trace_tolerance
        error('compute_concurrence:DensityInvalidTrace', ...
              'Density-matrix input must have unit trace within tolerance.');
    end

    rho_hermitian = (rho + rho') / 2;
    rho_eigenvalues = eig(rho_hermitian);

    if any(real(rho_eigenvalues) < -positivity_tolerance)
        error('compute_concurrence:DensityNonPositive', ...
              'Density-matrix input must be positive semidefinite within tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    [~, sigma_y, ~] = pauli_matrices();
    spin_operator = tensor_product(sigma_y, sigma_y);

    rho_tilde = spin_operator * conj(rho) * spin_operator;
    product_matrix = rho * rho_tilde;

    product_eigenvalues = eig(product_matrix);

    % Numerical cleanup:
    % rho * rho_tilde is theoretically real and non-negative in spectrum,
    % but small numerical imaginary parts may appear.
    product_eigenvalues = real(product_eigenvalues);
    product_eigenvalues = max(product_eigenvalues, 0);

    sqrt_eigenvalues = sqrt(product_eigenvalues);
    sqrt_eigenvalues = sort(sqrt_eigenvalues, 'descend');

    C = max(0, ...
        sqrt_eigenvalues(1) - sqrt_eigenvalues(2) - ...
        sqrt_eigenvalues(3) - sqrt_eigenvalues(4));

    if C > 1 + concurrence_tolerance
        error('compute_concurrence:DensityInvalidValue', ...
              'Computed concurrence lies outside the admissible range [0, 1].');
    end

    C = min(max(C, 0), 1);

end