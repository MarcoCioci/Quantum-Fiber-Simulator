function rho = state_to_density_matrix(psi)
% STATE_TO_DENSITY_MATRIX  Convert a normalized pure state vector into a density matrix.
%
% Objective:
%   Given a normalized pure state |ψ⟩ represented as an Nx1 complex column
%   vector, construct the corresponding density operator
%
%       ρ = |ψ⟩⟨ψ|
%
%   This function is used to move from a pure-state vector description to a
%   density-matrix description, which is required for reduced states,
%   purity, fidelity, ensemble averages, and later entanglement diagnostics.
%
% Input:
%   psi - Nx1 complex column vector representing a normalized pure quantum state
%
% Output:
%   rho - NxN complex density matrix associated with ψ
%
% Notes:
%   The returned operator should satisfy the standard properties of a pure
%   state density matrix:
%
%       - Hermitian: ρ = ρ'
%       - Unit trace: Tr(ρ) = 1
%       - Rank one, if ψ is normalized and valid
%
%   This function is intentionally dimension-independent. In the current
%   simulator it will mainly be used for:
%
%       - single-qubit test states (2x1),
%       - two-qubit bipartite states (4x1).
%
%   In ensemble-based simulations, this function may be called repeatedly to
%   convert each pure-state realization into a density matrix before
%   averaging.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('state_to_density_matrix:InvalidNumInputs', ...
            'Expected exactly 1 input argument: psi.');
    end

    if ~isnumeric(psi)
        error('state_to_density_matrix:InvalidType', ...
            'psi must be numeric.');
    end

    if isempty(psi)
        error('state_to_density_matrix:EmptyInput', ...
            'psi cannot be an empty vector.');
    end

    if ~isvector(psi) || size(psi,2) ~= 1
        error('state_to_density_matrix:InvalidShape', ...
            'psi must be a column vector (Nx1).');
    end

    if size(psi,1) < 2
        error('state_to_density_matrix:InvalidSize', ...
            'psi must contain at least two components.');
    end

    if any(~isfinite(psi))
        error('state_to_density_matrix:InvalidValues', ...
            'psi contains NaN or Inf values.');
    end

    tolerance = 1e-12;

    if abs(norm(psi, 2) - 1) > tolerance
        error('state_to_density_matrix:NotNormalized', ...
            'psi must be a normalized state vector.');
    end


    % =========================
    % Main computation
    % =========================

    rho = psi * psi';   % |psi><psi|, where '' is conjugate transpose

end