function X_out = two_arm_depolarizing_channel(X, p_A, p_B)
% TWO_ARM_DEPOLARIZING_CHANNEL  Apply independent local depolarization to two qubits.
%
% Objective:
%   Apply the two-arm depolarizing operator map
%
%       E_{p_A,p_B} = D_{p_A} ⊗ D_{p_B}
%
%   to a 4x4 bipartite two-qubit operator X.
%
% Input:
%   X   - 4x4 bipartite operator or density matrix
%   p_A - depolarization parameter for subsystem A, with 0 <= p_A <= 1
%   p_B - depolarization parameter for subsystem B, with 0 <= p_B <= 1
%
% Output:
%   X_out - 4x4 bipartite operator after independent local depolarization
%
% Notes:
%   The single-qubit depolarizing map is assumed to follow the convention:
%
%       D_p(X) = (1-p) X + p (I_2/2) Tr(X)
%
%   The two-arm channel acts on the full bipartite operator, not on the
%   reduced states separately.
%
%   For a two-qubit density matrix ρ_AB, the explicit action is:
%
%       ρ_out =
%           (1-p_A)(1-p_B) ρ_AB
%         + p_A(1-p_B) (I_2/2 ⊗ ρ_B)
%         + (1-p_A)p_B (ρ_A ⊗ I_2/2)
%         + p_A p_B (I_2/2 ⊗ I_2/2)
%
%   where:
%
%       ρ_A = Tr_B(ρ_AB)
%       ρ_B = Tr_A(ρ_AB)
%
%   For traceless Pauli-product operators, the two-body correlation terms
%   are contracted by:
%
%       η = (1-p_A)(1-p_B)
%
%   so that:
%
%       σ_i ⊗ σ_j -> η σ_i ⊗ σ_j
%
%   This channel is not equivalent to global depolarization.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('two_arm_depolarizing_channel:InvalidNumInputs', ...
              'Expected 3 input arguments: X, p_A, and p_B.');
    end

    if ~isnumeric(X)
        error('two_arm_depolarizing_channel:InvalidType', ...
              'X must be numeric.');
    end

    if isempty(X)
        error('two_arm_depolarizing_channel:EmptyInput', ...
              'X must not be empty.');
    end

    if ~ismatrix(X)
        error('two_arm_depolarizing_channel:InvalidDimensions', ...
              'X must be a 2-D matrix.');
    end

    if ~isequal(size(X), [4, 4])
        error('two_arm_depolarizing_channel:InvalidSize', ...
              'X must be a 4x4 bipartite two-qubit operator.');
    end

    if any(~isfinite(X), 'all')
        error('two_arm_depolarizing_channel:InvalidValuesX', ...
              'X must not contain NaN or Inf values.');
    end

    tolerance = 1e-12;

    if norm(X - X', 'fro') > tolerance
        error('two_arm_depolarizing_channel:NonHermitianInput', ...
              'X must be Hermitian within numerical tolerance.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A)
        error('two_arm_depolarizing_channel:InvalidParameterTypeA', ...
              'p_A must be a real numeric scalar.');
    end

    if ~isfinite(p_A)
        error('two_arm_depolarizing_channel:InvalidValueA', ...
              'p_A must not be NaN or Inf.');
    end

    if p_A < 0 || p_A > 1
        error('two_arm_depolarizing_channel:InvalidParameterRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B)
        error('two_arm_depolarizing_channel:InvalidParameterTypeB', ...
              'p_B must be a real numeric scalar.');
    end

    if ~isfinite(p_B)
        error('two_arm_depolarizing_channel:InvalidValueB', ...
              'p_B must not be NaN or Inf.');
    end

    if p_B < 0 || p_B > 1
        error('two_arm_depolarizing_channel:InvalidParameterRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    X_A = partial_trace_B(X);
    X_B = partial_trace_A(X);

    I2 = eye(2, 'like', X);

    X_out = (1 - p_A) * (1 - p_B) * X ...
          + p_A * (1 - p_B) * tensor_product(I2/2, X_B) ...
          + (1 - p_A) * p_B * tensor_product(X_A, I2/2) ...
          + p_A * p_B * tensor_product(I2/2, I2/2) * trace(X);

    % Remove small numerical anti-Hermitian residues.
    X_out = (X_out + X_out') / 2;

end