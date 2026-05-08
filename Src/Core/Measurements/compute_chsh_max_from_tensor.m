function S_max = compute_chsh_max_from_tensor(T)
% COMPUTE_CHSH_MAX_FROM_TENSOR  Compute the maximal CHSH value from a correlation tensor.
%
% Objective:
%   Compute the maximal CHSH parameter achievable by a two-qubit state,
%   using the Horodecki tensor criterion:
%
%       S_max = 2 * sqrt(λ₁ + λ₂)
%
%   where λ₁ and λ₂ are the two largest eigenvalues of
%
%       U = T.' * T.
%
% Input:
%   T     - 3x3 real correlation tensor with entries
%
%              T_ij = Tr[ρ_AB * (σ_i ⊗ σ_j)]
%
%           using the fixed Pauli ordering:
%
%              x, y, z
%
% Output:
%   S_max - real nonnegative scalar representing the maximal CHSH value
%           achievable by optimizing over local measurement axes.
%
% Notes:
%   This function does not evaluate CHSH for specific measurement settings.
%   It computes the maximum possible CHSH value associated with the tensor T.
%
%   A state violates the CHSH inequality if:
%
%       S_max > 2
%
%   The maximal quantum value allowed by quantum mechanics is:
%
%       S_max = 2 * sqrt(2)

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_chsh_max_from_tensor:InvalidNumInputs', ...
              'Expected exactly 1 input argument: T.');
    end

    if ~isnumeric(T)
        error('compute_chsh_max_from_tensor:InvalidTypeTensor', ...
              'T must be numeric.');
    end

    if ~isequal(size(T), [3, 3])
        error('compute_chsh_max_from_tensor:InvalidSizeTensor', ...
              'T must be a 3x3 correlation tensor.');
    end

    if any(~isfinite(T), 'all')
        error('compute_chsh_max_from_tensor:InvalidValuesTensor', ...
              'T must contain only finite values.');
    end

    tensor_real_tolerance = 1e-12;

    if any(abs(imag(T)) > tensor_real_tolerance, 'all')
        error('compute_chsh_max_from_tensor:ComplexTensor', ...
              'T must be real-valued within numerical tolerance.');
    end

    T = real(T);

    tensor_range_tolerance = 1e-12;

    if any(abs(T) > 1 + tensor_range_tolerance, 'all')
        error('compute_chsh_max_from_tensor:TensorOutOfRange', ...
              'Tensor entries exceed physical bounds [-1, 1] beyond tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    U = T.' * T;

    eigenvalues_U = eig(U);

    eigenvalue_real_tolerance = 1e-12;

    if any(abs(imag(eigenvalues_U)) > eigenvalue_real_tolerance)
        error('compute_chsh_max_from_tensor:ComplexEigenvalues', ...
              'Eigenvalues of T.'' * T must be real within numerical tolerance.');
    end

    eigenvalues_U = sort(real(eigenvalues_U), 'descend');

    eigenvalue_negative_tolerance = 1e-12;

    if any(eigenvalues_U < -eigenvalue_negative_tolerance)
        error('compute_chsh_max_from_tensor:NegativeEigenvalue', ...
              'T.'' * T has negative eigenvalues beyond numerical tolerance.');
    end

    eigenvalues_U = max(eigenvalues_U, 0);

    lambda_1 = eigenvalues_U(1);
    lambda_2 = eigenvalues_U(2);

    S_max = 2 * sqrt(lambda_1 + lambda_2);

    chsh_max_range_tolerance = 1e-10;

    if S_max > 2 * sqrt(2) + chsh_max_range_tolerance
        error('compute_chsh_max_from_tensor:AboveTsirelsonBound', ...
              'S_max exceeds the Tsirelson bound 2*sqrt(2) beyond numerical tolerance.');
    end

    S_max = real(S_max);

end