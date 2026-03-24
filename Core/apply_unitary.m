function psi_out = apply_unitary(U_A, U_B, psi_in)
% APPLY_UNITARY  Apply local single-qubit unitaries to a two-qubit state.
%
% Objective:
%   This function computes the output state of a bipartite two-qubit system
%   under independent local unitary evolution on subsystems A and B.
%
%   Given:
%       - UA : single-qubit unitary acting on photon A
%       - UB : single-qubit unitary acting on photon B
%       - psi_in : input pure state of the two-qubit system
%
%   the function returns
%
%       psi_out = (UA ⊗ UB) * psi_in
%
%   where ⊗ denotes the tensor (Kronecker) product.
%
%   This implements the basic propagation rule for the first stage of the
%   simulator, in which each fiber acts locally on the polarization qubit
%   associated with one photon, and the global evolution is obtained by
%   combining the two local transformations.
%
% Input:
%   UA      - 2x2 complex unitary matrix acting on subsystem A
%   UB      - 2x2 complex unitary matrix acting on subsystem B
%   psi_in  - 4x1 complex column vector representing the input two-qubit state
%
% Output:
%   psi_out - 4x1 complex column vector representing the evolved state
%
% Notes:
%   The basis ordering is assumed to be fixed as
%
%       {|00⟩, |01⟩, |10⟩, |11⟩}
%
%   throughout the simulator. The order of the tensor product must remain
%   consistent with the subsystem labeling:
%
%       U_A ⊗ U_B
%
%   and not U_B ⊗ U_A.


if ~isnumeric(U_A) || ~isnumeric(U_B) || ~isnumeric(psi_in)
    error('apply_unitary:InvalidInputType', ...
        'U_A, U_B, and psi_in must be numeric arrays.');
end

if (~isequal(size(U_A), [2 2]) || ~isequal(size(U_B), [2 2]) || ~isequal(size(psi_in), [4 1]))
    error('apply_unitary:InvalidInput', ...
        'Dimensions must be: UA,UB = 2x2 and psi_in = 4x1.');
end

psi_out = kron(U_A, U_B) * psi_in;
end



