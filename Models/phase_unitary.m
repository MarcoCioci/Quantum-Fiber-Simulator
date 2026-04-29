function U = phase_unitary(theta)
% PHASE_UNITARY  Generate the single-qubit phase unitary U(θ).
%
% Objective:
%   Return the 2x2 unitary operator representing the reduced phase model
%   for a single polarization qubit propagating through an optical fiber.
%
%   In the computational / polarization basis
%
%       {|0>, |1>} ≡ {|H>, |V>}
%
%   the operator is defined as
%
%       U(θ) =     [1           0
%                   0    exp(i*θ)]
%
%   up to an irrelevant global phase.
%
%   This model captures the effective relative phase shift between the
%   horizontal and vertical polarization components after propagation.
%
% Input:
%   theta - real scalar phase shift in radians
%
% Output:
%   U     - 2x2 complex unitary matrix
%
% Notes:
%   This function defines only the local single-qubit transformation.
%   The corresponding two-qubit evolution is constructed as
%
%       U_A(theta_A) ⊗ U_B(theta_B)
%
%   within the bipartite Hilbert space.
%
%   This is the first reduced propagation model used in the simulator.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('phase_unitary:InvalidNumInputs', ...
            'Expected exactly 1 input argument: theta.');
    end

    if ~isnumeric(theta) || ~isscalar(theta) || ~isreal(theta)
        error('phase_unitary:InvalidTheta', ...
            'theta must be a real numeric scalar.');
    end

    
    % =========================
    % Main computation
    % =========================

    U = [1, 0;
         0, exp(1i * theta)];

end