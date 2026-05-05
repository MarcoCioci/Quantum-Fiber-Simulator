function fidelity = compute_fidelity(state_1, state_2)
% COMPUTE_FIDELITY  Compute the quantum fidelity between two states.
%
% Objective:
%   Evaluate the fidelity between two quantum states, each provided either as
%   a normalized pure-state vector or as a density matrix.
%
%   The function supports the following cases:
%
%       1. Pure state vs pure state:
%          F(|ψ⟩,|φ⟩) = |⟨ψ|φ⟩|^2
%
%       2. Density matrix vs pure state:
%          F(ρ,|ψ⟩) = ⟨ψ|ρ|ψ⟩
%
%       3. Pure state vs density matrix:
%          F(|ψ⟩,σ) = ⟨ψ|σ|ψ⟩
%
%       4. Density matrix vs density matrix:
%          F(ρ,σ) = (Tr(sqrt(sqrt(ρ) * σ * sqrt(ρ))))^2
%
% Input:
%   state_1 - either:
%             (a) Nx1 normalized complex column vector, or
%             (b) NxN density matrix
%
%   state_2 - either:
%             (a) Nx1 normalized complex column vector, or
%             (b) NxN density matrix
%
% Output:
%   fidelity - scalar value in the interval [0,1], up to numerical tolerance
%
% Notes:
%   If an input is a vector, it is interpreted as a pure quantum state.
%   If an input is a matrix, it is interpreted as a density matrix and is
%   required to be square, Hermitian, positive semidefinite, and unit trace
%   up to numerical tolerance.
%
%   Numerical imaginary residues and tiny negative eigenvalues may arise from
%   floating-point arithmetic. These are handled only when they are below a
%   prescribed tolerance.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('compute_fidelity:InvalidNumInputs', ...
            'Expected exactly 2 input arguments: state_1 and state_2.');
    end

    if ~isnumeric(state_1)
        error('compute_fidelity:InvalidState1Type', ...
            'Input state_1 must be numeric.');
    end

    if ~isnumeric(state_2)
        error('compute_fidelity:InvalidState2Type', ...
            'Input state_2 must be numeric.');
    end

    if isempty(state_1)
        error('compute_fidelity:EmptyState1', ...
            'Input state_1 must not be empty.');
    end

    if isempty(state_2)
        error('compute_fidelity:EmptyState2', ...
            'Input state_2 must not be empty.');
    end

    if any(~isfinite(state_1), 'all')
        error('compute_fidelity:InvalidState1Values', ...
            'Input state_1 contains NaN or Inf values.');
    end

    if any(~isfinite(state_2), 'all')
        error('compute_fidelity:InvalidState2Values', ...
            'Input state_2 contains NaN or Inf values.');
    end

    tolerance = 1e-12;

    is_vector_1 = isvector(state_1) && size(state_1, 2) == 1;
    is_vector_2 = isvector(state_2) && size(state_2, 2) == 1;

    is_matrix_1 = ismatrix(state_1) && ~is_vector_1;
    is_matrix_2 = ismatrix(state_2) && ~is_vector_2;

    if ~(is_vector_1 || is_matrix_1)
        error('compute_fidelity:InvalidState1Shape', ...
            'Input state_1 must be either an Nx1 column vector or an NxN matrix.');
    end

    if ~(is_vector_2 || is_matrix_2)
        error('compute_fidelity:InvalidState2Shape', ...
            'Input state_2 must be either an Nx1 column vector or an NxN matrix.');
    end


    % =========================
    % Branch 1: vector vs vector
    % =========================

    if is_vector_1 && is_vector_2

        psi = state_1;
        phi = state_2;

        if size(psi, 1) ~= size(phi, 1)
            error('compute_fidelity:DimensionMismatch', ...
                'State vectors must have the same dimension.');
        end

        if abs(norm(psi, 2) - 1) > tolerance
            error('compute_fidelity:State1NotNormalized', ...
                'Pure state vector state_1 must be normalized.');
        end

        if abs(norm(phi, 2) - 1) > tolerance
            error('compute_fidelity:State2NotNormalized', ...
                'Pure state vector state_2 must be normalized.');
        end

        fidelity = abs(psi' * phi)^2;


    % =========================
    % Branch 2: matrix vs vector
    % =========================

    elseif is_matrix_1 && is_vector_2

        rho = state_1;
        psi = state_2;

        [num_rows_rho, num_cols_rho] = size(rho);

        if num_rows_rho ~= num_cols_rho
            error('compute_fidelity:InvalidState1Size', ...
                'Density matrix state_1 must be square.');
        end

        if size(psi, 1) ~= num_rows_rho
            error('compute_fidelity:DimensionMismatch', ...
                'Dimensions of state_1 and state_2 are not compatible.');
        end

        validate_density_matrix(rho, tolerance, 'state_1');
        validate_state_vector(psi, tolerance, 'state_2');

        fidelity = psi' * rho * psi;


    % =========================
    % Branch 3: vector vs matrix
    % =========================

    elseif is_vector_1 && is_matrix_2

        psi = state_1;
        sigma = state_2;

        [num_rows_sigma, num_cols_sigma] = size(sigma);

        if num_rows_sigma ~= num_cols_sigma
            error('compute_fidelity:InvalidState2Size', ...
                'Density matrix state_2 must be square.');
        end

        if size(psi, 1) ~= num_rows_sigma
            error('compute_fidelity:DimensionMismatch', ...
                'Dimensions of state_1 and state_2 are not compatible.');
        end

        validate_state_vector(psi, tolerance, 'state_1');
        validate_density_matrix(sigma, tolerance, 'state_2');

        fidelity = psi' * sigma * psi;


    % =========================
    % Branch 4: matrix vs matrix
    % =========================

    else

        rho = state_1;
        sigma = state_2;

        [num_rows_rho, num_cols_rho] = size(rho);
        [num_rows_sigma, num_cols_sigma] = size(sigma);

        if num_rows_rho ~= num_cols_rho
            error('compute_fidelity:InvalidState1Size', ...
                'Density matrix state_1 must be square.');
        end

        if num_rows_sigma ~= num_cols_sigma
            error('compute_fidelity:InvalidState2Size', ...
                'Density matrix state_2 must be square.');
        end

        if num_rows_rho ~= num_rows_sigma
            error('compute_fidelity:DimensionMismatch', ...
                'Density matrices state_1 and state_2 must have the same dimension.');
        end

        validate_density_matrix(rho, tolerance, 'state_1');
        validate_density_matrix(sigma, tolerance, 'state_2');

        rho_sqrt = matrix_sqrt_psd(rho, tolerance, 'state_1');

        X = rho_sqrt * sigma * rho_sqrt;
        X = (X + X') / 2;   % Enforce Hermiticity against roundoff

        X_sqrt = matrix_sqrt_psd(X, tolerance, 'intermediate_operator');

        fidelity = (trace(X_sqrt))^2;

    end


    % =========================
    % Final numerical cleanup
    % =========================

    if abs(imag(fidelity)) > tolerance
        error('compute_fidelity:NonRealOutput', ...
            'Computed fidelity has a non-negligible imaginary part.');
    end

    fidelity = real(fidelity);

    if fidelity < -tolerance || fidelity > 1 + tolerance
        error('compute_fidelity:OutOfRangeOutput', ...
            'Computed fidelity lies outside [0,1] beyond numerical tolerance.');
    end

    fidelity = min(max(fidelity, 0), 1);

end


% =========================================================================
% Local helper functions
% =========================================================================

function validate_state_vector(psi, tolerance, input_name)
% VALIDATE_STATE_VECTOR  Check whether psi is a valid normalized state vector.

    if ~isvector(psi) || size(psi, 2) ~= 1
        error('compute_fidelity:InvalidVectorShape', ...
            '%s must be a column vector (Nx1).', input_name);
    end

    if abs(norm(psi, 2) - 1) > tolerance
        error('compute_fidelity:VectorNotNormalized', ...
            '%s must be a normalized state vector.', input_name);
    end

end


function validate_density_matrix(rho, tolerance, input_name)
% VALIDATE_DENSITY_MATRIX  Check whether rho is a valid density matrix.

    if ndims(rho) ~= 2
        error('compute_fidelity:InvalidMatrixDimensions', ...
            '%s must be a 2-D matrix.', input_name);
    end

    [num_rows, num_cols] = size(rho);

    if num_rows ~= num_cols
        error('compute_fidelity:InvalidMatrixSize', ...
            '%s must be square.', input_name);
    end

    if norm(rho - rho', 'fro') > tolerance
        error('compute_fidelity:NonHermitianMatrix', ...
            '%s must be Hermitian up to numerical tolerance.', input_name);
    end

    if abs(trace(rho) - 1) > tolerance
        error('compute_fidelity:InvalidMatrixTrace', ...
            '%s must have trace equal to 1 up to numerical tolerance.', input_name);
    end

    eigenvalues = eig((rho + rho') / 2);
    eigenvalues(abs(eigenvalues) < tolerance) = 0;

    if any(real(eigenvalues) < -tolerance) || any(abs(imag(eigenvalues)) > tolerance)
        error('compute_fidelity:MatrixNotPSD', ...
            '%s must be positive semidefinite up to numerical tolerance.', input_name);
    end

end


function A_sqrt = matrix_sqrt_psd(A, tolerance, input_name)
% MATRIX_SQRT_PSD  Compute the square root of a Hermitian PSD matrix.

    A = (A + A') / 2;

    [U, D] = eig(A);
    eigenvalues = diag(D);

    if any(abs(imag(eigenvalues)) > tolerance)
        error('compute_fidelity:ComplexSpectrum', ...
            'The spectrum of %s is not real up to numerical tolerance.', input_name);
    end

    eigenvalues = real(eigenvalues);
    eigenvalues(abs(eigenvalues) < tolerance) = 0;

    if any(eigenvalues < -tolerance)
        error('compute_fidelity:NegativeSpectrum', ...
            '%s must be positive semidefinite up to numerical tolerance.', input_name);
    end

    eigenvalues = max(eigenvalues, 0);

    D_sqrt = diag(sqrt(eigenvalues));
    A_sqrt = U * D_sqrt * U';

    A_sqrt = (A_sqrt + A_sqrt') / 2;

end