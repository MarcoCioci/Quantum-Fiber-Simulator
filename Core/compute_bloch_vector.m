function bloch_struct = compute_bloch_vector(rho)
% COMPUTE_BLOCH_VECTOR  Compute Bloch/Stokes parameters from a density matrix.
%
% Objective:
%   Extract the Bloch vector components of a single-qubit quantum state
%   represented by a density matrix rho. These components correspond to
%   expectation values of the Pauli operators:
%
%       sx = Tr(rho * sigma_x)
%       sy = Tr(rho * sigma_y)
%       sz = Tr(rho * sigma_z)
%
%   The resulting vector fully characterizes the state within the Bloch sphere.
%
% Input:
%   rho          - 2x2 density matrix representing a single-qubit quantum state
%
% Output:
%   bloch_struct - struct containing:
%                  .sx      expectation value of sigma_x
%                  .sy      expectation value of sigma_y
%                  .sz      expectation value of sigma_z
%                  .vector  column vector [sx; sy; sz]
%
% Notes:
%   - The input rho is assumed to be Hermitian and trace-normalized.
%   - For a pure state, ||bloch_struct.vector|| = 1
%   - For a maximally mixed state, bloch_struct.vector = [0; 0; 0]
%
%   This function is equivalent to extracting Stokes parameters in
%   polarization optics.

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

    if ~ismatrix(rho)
        error('compute_bloch_vector:InvalidShape', ...
              'rho must be a 2-D matrix.');
    end

    if ~isequal(size(rho), [2, 2])
        error('compute_bloch_vector:InvalidSize', ...
              'rho must be a 2x2 matrix (single-qubit density operator).');
    end

    if norm(rho - rho', 'fro') > 1e-12
        warning('compute_bloch_vector:NonHermitianInput', ...
                ['rho is not exactly Hermitian within tolerance. ', ...
                 'Check input validity.']);
    end

    trace_rho = trace(rho);
    if abs(trace_rho - 1) > 1e-12
        warning('compute_bloch_vector:TraceNotOne', ...
                ['rho does not have unit trace within tolerance. ', ...
                 'Current trace is %g + %gi.'], real(trace_rho), imag(trace_rho));
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