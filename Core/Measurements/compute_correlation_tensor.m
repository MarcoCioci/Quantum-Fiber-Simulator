function T = compute_correlation_tensor(state)
% COMPUTE_CORRELATION_TENSOR  Compute the full two-qubit Pauli correlation tensor
%
% Objective:
%   Compute the 3x3 correlation tensor T whose entries are
%   T(i,j) = Tr[ρ_AB * (σ_i ⊗ σ_j)],
%   with σ_i, σ_j in {σ_x, σ_y, σ_z}.
%
% Input:
%   state - either:
%           * 4x1 complex column vector (pure state)
%           * 4x4 complex density matrix (mixed state)
%
% Output:
%   T - 3x3 real matrix containing all Pauli correlation terms
%
% Notes:
%   The computational basis ordering is assumed to be:
%       {|00⟩, |01⟩, |10⟩, |11⟩}
%
%   The output indices correspond to:
%       1 -> x
%       2 -> y
%       3 -> z
%
%   Therefore:
%       T(1,1) = ⟨σ_x ⊗ σ_x⟩
%       T(1,2) = ⟨σ_x ⊗ σ_y⟩
%       T(2,1) = ⟨σ_y ⊗ σ_x⟩
%       T(3,3) = ⟨σ_z ⊗ σ_z⟩

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_correlation_tensor:InvalidNumInputs', ...
              'Expected exactly 1 input argument.');
    end

    if ~isnumeric(state)
        error('compute_correlation_tensor:InvalidType', ...
              'state must be numeric.');
    end

    if ~isequal(size(state), [4 4]) && ~isequal(size(state), [4 1])
        error('compute_correlation_tensor:InvalidSize', ...
              'state must be either a 4x4 density matrix or a 4x1 pure state vector.');
    end

    tolerance = 1e-12;

    if isequal(size(state), [4 1])
        if abs(norm(state) - 1) > tolerance
            error('compute_correlation_tensor:NotNormalized', ...
                  'Pure state vector must be normalized.');
        end

        rho_AB = state_to_density_matrix(state);
    else
        rho_AB = state;
    end

    if norm(rho_AB - rho_AB', 'fro') > tolerance
        error('compute_correlation_tensor:NotHermitian', ...
              'rho_AB must be Hermitian.');
    end

    if abs(trace(rho_AB) - 1) > tolerance
        error('compute_correlation_tensor:InvalidTrace', ...
              'rho_AB must have trace equal to 1.');
    end

    eigenvalues_rho = eig(rho_AB);
    if min(real(eigenvalues_rho)) < -tolerance
        error('compute_correlation_tensor:NotPositiveSemidefinite', ...
              'rho_AB must be positive semidefinite.');
    end


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();
    pauli_array = {sigma_x, sigma_y, sigma_z};

    T = zeros(3, 3);

    for i = 1:3
        for j = 1:3
            observable_ij = tensor_product(pauli_array{i}, pauli_array{j});
            value_ij = trace(rho_AB * observable_ij);

            if abs(imag(value_ij)) < tolerance
                T(i, j) = real(value_ij);
            else
                error('compute_correlation_tensor:NotReal', ...
                      'Correlation tensor entry T(%d,%d) has a non-negligible imaginary part.', i, j);
            end
        end
    end

end