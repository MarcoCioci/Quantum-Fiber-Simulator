function C = concurrence_density_matrix(rho)
% CONCURRENCE_DENSITY_MATRIX  Compute the concurrence of a two-qubit density matrix.
%
% Objective:
%   Given a valid two-qubit density operator rho, compute the concurrence
%   using the general mixed-state definition based on the spin-flipped
%   matrix.
%
%   The concurrence is defined as
%
%       C(rho) = max(0, lambda_1 - lambda_2 - lambda_3 - lambda_4),
%
%   where lambda_i are the square roots of the eigenvalues of the matrix
%
%       rho * rho_tilde,
%
%   ordered such that
%
%       lambda_1 >= lambda_2 >= lambda_3 >= lambda_4 >= 0,
%
%   and where the spin-flipped matrix is given by
%
%       rho_tilde = (sigma_y ⊗ sigma_y) * rho* * (sigma_y ⊗ sigma_y).
%
% Input:
%   rho - 4x4 complex density matrix representing a two-qubit state in the
%         computational basis:
%
%         {|00>, |01>, |10>, |11>}
%
% Output:
%   C   - concurrence value, expected to satisfy 0 <= C <= 1 up to small
%         numerical tolerance.
%
% Notes:
%   Assumptions:
%   - rho must be Hermitian.
%   - rho must have unit trace.
%   - rho must be positive semidefinite up to numerical tolerance.
%
%   Context in simulator:
%   - This routine is the general mixed-state extension of
%     concurrence_pure_state.
%   - It is required for ensemble-averaged states and noisy propagation
%     models.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        error('concurrence_density_matrix:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isnumeric(rho)
        error('concurrence_density_matrix:InvalidType', ...
              'rho must be numeric.');
    end

    if ~ismatrix(rho) || any(size(rho) ~= [4, 4])
        error('concurrence_density_matrix:InvalidSize', ...
              'rho must be a 4x4 matrix.');
    end

    if any(~isfinite(real(rho(:)))) || any(~isfinite(imag(rho(:))))
        error('concurrence_density_matrix:InvalidEntries', ...
              'rho must contain only finite entries.');
    end

    hermitian_tolerance = 1e-12;
    trace_tolerance = 1e-12;
    positivity_tolerance = 1e-12;

    if norm(rho - rho', 'fro') > hermitian_tolerance
        error('concurrence_density_matrix:NonHermitianMatrix', ...
              'rho must be Hermitian within tolerance.');
    end

    if abs(trace(rho) - 1) > trace_tolerance
        error('concurrence_density_matrix:InvalidTrace', ...
              'rho must have unit trace within tolerance.');
    end

    rho_eigenvalues = eig((rho + rho') / 2);

    if any(real(rho_eigenvalues) < -positivity_tolerance)
        error('concurrence_density_matrix:NonPositiveMatrix', ...
              'rho must be positive semidefinite within tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    [~, sigma_y, ~] = pauli_matrices();
    spin_operator = tensor_product(sigma_y, sigma_y);

    rho_tilde = spin_operator * conj(rho) * spin_operator;
    prod_matrix = rho * rho_tilde;

    product_eigenvalues = eig(prod_matrix);
    product_eigenvalues = real(product_eigenvalues);
    product_eigenvalues = max(product_eigenvalues, 0);

    sqrt_eigenvalues = sqrt(product_eigenvalues);
    sqrt_eigenvalues = sort(sqrt_eigenvalues, 'descend');

    % Wootters formula
    C = max(0, sqrt_eigenvalues(1) - sqrt_eigenvalues(2) - sqrt_eigenvalues(3) - sqrt_eigenvalues(4));

    % Guard against tiny numerical drift outside [0, 1]
    tolerance = 1e-12;

    if C > 1 + tolerance
        error('concurrence_density_matrix:InvalidConcurrenceValue', ...
              'Computed concurrence lies outside the admissible range [0, 1].');
    else
        C = min(max(C, 0), 1);
    end

end