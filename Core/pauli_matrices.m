function [sigma_x, sigma_y, sigma_z] = pauli_matrices()
% PAULI_MATRICES  Return the standard Pauli operators for a single qubit.
%
% Objective:
%   Provide the three Pauli matrices, which form a basis for
%   single-qubit operators and are used to construct multi-qubit
%   observables via tensor products.
%
% Output:
%   sigma_x - 2x2 Pauli X matrix
%   sigma_y - 2x2 Pauli Y matrix
%   sigma_z - 2x2 Pauli Z matrix
%
% Notes:
%   The Pauli matrices are defined as:
%
%       sigma_x = [0  1;
%                  1  0]
%
%       sigma_y = [0 -i;
%                  i  0]
%
%       sigma_z = [1  0;
%                  0 -1]
%
%   These operators act on a single-qubit Hilbert space.
%   Multi-qubit operators are constructed via tensor products.
%
%   The matrices are Hermitian and unitary, and satisfy:
%
%       sigma_i^2 = I
%       [sigma_i, sigma_j] = 2i · epsilon_ijk · sigma_k

    % =========================
    % Main computations
    % =========================

    sigma_x = [0 1;
               1 0];

    sigma_y = [0 -1i;
               1i  0];

    sigma_z = [1  0;
               0 -1];

end