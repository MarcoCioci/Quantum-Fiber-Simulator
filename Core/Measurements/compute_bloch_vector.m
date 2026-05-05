function bloch_struct = compute_bloch_vector(rho)
% COMPUTE_BLOCH_VECTOR  Compute Bloch/Stokes parameters from a density matrix.
%
% Objective:
%   Extract the Bloch vector components of a single-qubit quantum state
%   represented by a density matrix ρ. These components correspond to
%   expectation values of the Pauli operators:
%
%       s_x = Tr(ρ * σ_x)
%       s_y = Tr(ρ * σ_y)
%       s_z = Tr(ρ * σ_z)
%
% Input:
%   rho - 2x2 density matrix representing a single-qubit quantum state
%
% Output:
%   bloch_struct - struct containing:
%                  .sx      expectation value of σ_x
%                  .sy      expectation value of σ_y
%                  .sz      expectation value of σ_z
%                  .vector  column vector [s_x; s_y; s_z]
%
% Notes:
%   - For a pure state, norm(bloch_struct.vector) = 1.
%   - For a maximally mixed state, bloch_struct.vector = [0; 0; 0].
%   - In polarization optics, these components correspond to normalized
%     Stokes parameters.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('compute_bloch_vector:InvalidNumInputs', ...
              'Expected exactly 1 input argument.');
    end

    if ~isnumeric(rho)
        error('compute_bloch_vector:InvalidType', ...
              'rho must be numeric.');
    end

    if ~isequal(size(rho), [2, 2])
        error('compute_bloch_vector:InvalidSize', ...
              'rho must be a 2x2 density matrix.');
    end

    tolerance = 1e-12;

    if any(~isfinite(real(rho(:)))) || any(~isfinite(imag(rho(:))))
        error('compute_bloch_vector:InvalidEntries', ...
              'rho must contain only finite entries.');
    end

    if norm(rho - rho', 'fro') > tolerance
        error('compute_bloch_vector:NonHermitianInput', ...
              'rho must be Hermitian within tolerance.');
    end

    trace_rho = trace(rho);
    if abs(trace_rho - 1) > tolerance
        error('compute_bloch_vector:TraceNotOne', ...
              'rho must have unit trace. Current trace is %g + %gi.', ...
              real(trace_rho), imag(trace_rho));
    end

    eigenvalues_rho = eig(rho);
    if min(real(eigenvalues_rho)) < -tolerance
        error('compute_bloch_vector:NotPositiveSemidefinite', ...
              'rho must be positive semidefinite.');
    end


    % =========================
    % Main computation
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    sx = real(trace(rho * sigma_x));
    sy = real(trace(rho * sigma_y));
    sz = real(trace(rho * sigma_z));

    bloch_struct.sx = sx;
    bloch_struct.sy = sy;
    bloch_struct.sz = sz;
    bloch_struct.vector = [sx; sy; sz];

end