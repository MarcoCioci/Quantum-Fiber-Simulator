function rho_out = depolarizing_channel_two_qubits(rho, p)
% DEPOLARIZING_CHANNEL_TWO_QUBITS  Apply a two-qubit depolarizing channel.
%
% Objective:
%   Apply the effective global depolarizing map to a two-qubit density
%   matrix rho, returning the output state
%
%       rho_out = (1 - p) * rho + (p / 4) * I_4
%
%   where p is the depolarization strength and I_4 is the 4x4 identity
%   matrix.
%
% Input:
%   rho - 4x4 complex density matrix representing a two-qubit quantum state
%   p   - real scalar depolarization parameter, with 0 <= p <= 1
%
% Output:
%   rho_out - 4x4 complex density matrix after depolarizing-channel action
%
% Notes:
%   This function implements the effective isotropic depolarization model
%   introduced in the mixed-state channel framework of the simulator.
%   The input is assumed to represent a two-qubit state in the standard
%   computational basis ordering:
%
%       {|00>, |01>, |10>, |11>}
%
%   The function acts directly on density matrices, not on pure-state vectors.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('depolarizing_channel_two_qubits:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: rho and p.');
    end

    if ~isnumeric(rho)
        error('depolarizing_channel_two_qubits:InvalidType', ...
              'rho must be a numeric matrix.');
    end

    if ~ismatrix(rho) || any(size(rho) ~= [4, 4])
        error('depolarizing_channel_two_qubits:InvalidSize', ...
              'rho must be a 4x4 matrix representing a two-qubit density operator.');
    end

    if ~isnumeric(p) || ~isscalar(p) || ~isreal(p)
        error('depolarizing_channel_two_qubits:InvalidParameter', ...
              'p must be a real numeric scalar.');
    end

    if p < 0 || p > 1
        error('depolarizing_channel_two_qubits:InvalidRange', ...
              'p must satisfy 0 <= p <= 1.');
    end

    tolerance = 1e-12;

    if norm(rho - rho', 'fro') > tolerance
        error('depolarizing_channel_two_qubits:NonHermitianInput', ...
              'rho must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho) - 1) > tolerance
        error('depolarizing_channel_two_qubits:InvalidTrace', ...
              'rho must have trace equal to 1 within numerical tolerance.');
    end


    % =========================
    % Main computation
    % =========================

    I_4 = eye(4, 4);
    rho_out = (1 - p) * rho + (p / 4) * I_4;

end