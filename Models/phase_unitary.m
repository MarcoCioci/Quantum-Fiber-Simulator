function U = phase_unitary(theta)
% PHASE_UNITARY  Generate the single-qubit phase unitary U(theta).
%
% Objective:
%   This function returns the 2x2 unitary operator representing the
%   reduced phase model for a single polarization qubit propagating
%   through an optical fiber.
%
%   The operator is defined in the computational / polarization basis
%
%       {|0⟩, |1⟩} ≡ {|H⟩, |V⟩}
%
%   as
%
%       U(theta) = [1      0
%                   0  exp(i*theta)]
%
%   up to an irrelevant global phase.
%
%   This model captures the effective relative phase shift between the
%   horizontal and vertical polarization components after propagation.
%   It is the first propagation model used in the simulator and provides
%   the elementary local transformation acting on each photon separately.
%
% Input:
%   theta  - real scalar phase shift (in radians)
%
% Output:
%   U      - 2x2 complex unitary matrix
%
% Notes:
%   This function defines only the local single-qubit transformation.
%   The corresponding two-photon evolution must later be constructed as
%
%       U_A(theta_A) ⊗ U_B(theta_B)
%
%   using the tensor-product structure of the bipartite Hilbert space.

    if ~isnumeric(theta) || ~isscalar(theta) || ~isreal(theta)
        error('phase_unitary:InvalidTheta', ...
            'theta must be a real numeric scalar.');
    end

    U = [1, 0;
         0, exp(1i * theta)];

end