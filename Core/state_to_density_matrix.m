function rho = state_to_density_matrix(psi)
% STATE_TO_DENSITY_MATRIX  Convert a pure two-qubit state vector into a density matrix.
%
% Objective:
%   Given a normalized pure state |psi> represented as a 4x1 complex column
%   vector in the two-qubit computational basis, construct the corresponding
%   density operator
%
%       rho = |psi><psi|
%
%   This is the first fundamental step needed to move from the pure-state
%   simulator used in Experiment 1 to the mixed-state / ensemble description
%   required in Experiment 2.
%
% Input:
%   psi - 4x1 complex column vector representing a normalized two-qubit
%         pure state in the computational basis:
%
%         {|00>, |01>, |10>, |11>}
%
% Output:
%   rho - 4x4 complex density matrix associated with psi
%
% Notes:
%   The returned operator should satisfy the standard properties of a pure
%   state density matrix:
%
%       - Hermitian: rho = rho'
%       - Unit trace: trace(rho) = 1
%       - Rank one, if psi is normalized and valid
%
%   This function is intentionally specialized to the current simulator stage,
%   where the system of interest is a two-qubit bipartite state.
%
%   In Experiment 2, this function will be used repeatedly to convert each
%   random-phase realization |psi(theta_k)> into rho_k before performing
%   ensemble averaging.
%
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

    % Enforce column vector structure
    if ~isvector(psi) || size(psi,2) ~= 1
        error('state_to_density_matrix:InvalidShape', ...
            'psi must be a column vector (4x1).');
    end

    % Check dimension (two-qubit system)
    if size(psi,1) ~= 4
        error('state_to_density_matrix:InvalidSize', ...
            'psi must be a 4x1 vector.');
    end

    % Check finite values
    if any(~isfinite(psi))
        error('state_to_density_matrix:InvalidValues', ...
            'psi contains NaN or Inf values.');
    end

    % Check normalization
    tol = 1e-10;
    if abs(norm(psi,2) - 1) > tol
        error('state_to_density_matrix:NotNormalized', ...
            'psi must be a normalized state vector.');
    end


    % =========================
    % Main computations
    % =========================

    rho = psi * psi';   % |psi><psi|, where ' is conjugate transpose

end
