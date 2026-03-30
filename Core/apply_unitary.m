function psi_out = apply_unitary(U_A, U_B, psi_in)
% APPLY_UNITARY  Apply local single-qubit unitaries to a two-qubit state.
%
% Objective:
%   Compute the output state of a bipartite two-qubit system under
%   independent local unitary evolution on subsystems A and B.
%
%   Given:
%       U_A    - single-qubit unitary acting on subsystem A
%       U_B    - single-qubit unitary acting on subsystem B
%       psi_in - input pure state of the two-qubit system
%
%   the function returns:
%
%       psi_out = (U_A ⊗ U_B) * psi_in
%
%   where ⊗ denotes the tensor (Kronecker) product.
%
% Input:
%   U_A    - 2x2 complex unitary matrix acting on subsystem A
%   U_B    - 2x2 complex unitary matrix acting on subsystem B
%   psi_in - 4x1 complex column vector representing the input two-qubit state
%
% Output:
%   psi_out - 4x1 complex column vector representing the evolved state
%
% Notes:
%   The basis ordering is assumed to be fixed as
%
%       {|00>, |01>, |10>, |11>}
%
%   throughout the simulator.
%
%   The tensor-product order must remain consistent with subsystem labeling:
%
%       U_A ⊗ U_B
%
%   and not:
%
%       U_B ⊗ U_A
%
%   This function does not renormalize the state. If psi_in is normalized
%   and U_A, U_B are unitary, then psi_out is automatically normalized.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('apply_unitary:InvalidNumInputs', ...
            'Expected exactly 3 input arguments: U_A, U_B, psi_in.');
    end

    if ~isnumeric(U_A) || ~ismatrix(U_A)
        error('apply_unitary:InvalidTypeUA', ...
            'U_A must be a numeric 2x2 matrix.');
    end

    if ~isnumeric(U_B) || ~ismatrix(U_B)
        error('apply_unitary:InvalidTypeUB', ...
            'U_B must be a numeric 2x2 matrix.');
    end

    if ~isnumeric(psi_in) || ~ismatrix(psi_in)
        error('apply_unitary:InvalidTypePsi', ...
            'psi_in must be a numeric 4x1 column vector.');
    end

    if ~isequal(size(U_A), [2 2])
        error('apply_unitary:InvalidSizeUA', ...
            'U_A must be a 2x2 matrix.');
    end

    if ~isequal(size(U_B), [2 2])
        error('apply_unitary:InvalidSizeUB', ...
            'U_B must be a 2x2 matrix.');
    end

    if ~isequal(size(psi_in), [4 1])
        error('apply_unitary:InvalidSizePsi', ...
            'psi_in must be a 4x1 column vector.');
    end

    if ~is_unitary(U_A)
        error('apply_unitary:NonUnitaryUA', ...
            'U_A must be unitary.');
    end

    if ~is_unitary(U_B)
        error('apply_unitary:NonUnitaryUB', ...
            'U_B must be unitary.');
    end

    if exist('is_normalized', 'file') == 2 && ~is_normalized(psi_in)
        warning('apply_unitary:InputStateNotNormalized', ...
            ['psi_in does not appear to be normalized. ' ...
             'The output will still be computed, but may not represent a valid quantum state.']);
    end

    
    % =========================
    % Main computations
    % =========================

    U_global = kron(U_A, U_B);
    psi_out = U_global * psi_in;

end