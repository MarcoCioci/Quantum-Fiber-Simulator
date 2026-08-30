function state_out = apply_unitary(U_A, U_B, state_in)
% APPLY_UNITARY  Apply local single-qubit unitaries to a two-qubit state.
%
% Objective:
%   Evolve a two-qubit pure state |ψ_in⟩ or density matrix ρ_in under
%   independent local unitary transformations on subsystems A and B:
%
%       U_AB = U_A ⊗ U_B.
%
%   For a pure-state input:
%
%       |ψ_out⟩ = U_AB |ψ_in⟩.
%
%   For a density-matrix input:
%
%       ρ_out = U_AB ρ_in U_AB†.
%
% Input:
%   U_A      - 2x2 unitary matrix acting on subsystem A.
%   U_B      - 2x2 unitary matrix acting on subsystem B.
%   state_in - Either:
%              - 4x1 complex column vector representing |ψ_in⟩, or
%              - 4x4 complex matrix representing ρ_in.
%
% Output:
%   state_out - Evolved state in the same representation as state_in:
%               - 4x1 pure-state vector |ψ_out⟩;
%               - 4x4 density matrix ρ_out.
%
% Notes:
%   The fixed computational basis ordering is:
%
%       {|00⟩, |01⟩, |10⟩, |11⟩}.
%
%   The tensor-product order follows the subsystem ordering:
%
%       U_AB = U_A ⊗ U_B.
%
%   No normalization or physical-state validation is performed on state_in.
%   If |ψ_in⟩ is normalized, or if ρ_in is a valid density matrix, these
%   properties are preserved by the unitary evolution.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('apply_unitary:InvalidNumInputs', ...
            'Expected exactly 3 input arguments: U_A, U_B, state_in.');
    end

    if ~isnumeric(U_A) || ~isequal(size(U_A), [2, 2]) || ...
            any(~isfinite(U_A), 'all')
        error('apply_unitary:InvalidUA', ...
            'U_A must be a finite numeric 2x2 matrix.');
    end

    if ~isnumeric(U_B) || ~isequal(size(U_B), [2, 2]) || ...
            any(~isfinite(U_B), 'all')
        error('apply_unitary:InvalidUB', ...
            'U_B must be a finite numeric 2x2 matrix.');
    end

    if ~isnumeric(state_in) || ...
            (~isequal(size(state_in), [4, 1]) && ...
             ~isequal(size(state_in), [4, 4])) || ...
            any(~isfinite(state_in), 'all')
        error('apply_unitary:InvalidInputState', ...
            ['state_in must be a finite 4x1 pure-state vector or ', ...
             'a finite 4x4 density matrix.']);
    end

    if ~is_unitary(U_A)
        error('apply_unitary:NonUnitaryUA', ...
            'U_A must be unitary.');
    end

    if ~is_unitary(U_B)
        error('apply_unitary:NonUnitaryUB', ...
            'U_B must be unitary.');
    end

    % =========================
    % Main computation
    % =========================

    U_AB = tensor_product(U_A, U_B);

    if isequal(size(state_in), [4, 1])
        state_out = U_AB * state_in;
    else
        state_out = U_AB * state_in * U_AB';
    end

end