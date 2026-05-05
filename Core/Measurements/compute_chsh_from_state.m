function S = compute_chsh_from_state(state, a1, a2, b1, b2)
% COMPUTE_CHSH_FROM_STATE  Compute the CHSH parameter from a two-qubit state.
%
% Objective:
%   Compute the CHSH parameter
%
%       S = E(a₁,b₁) + E(a₁,b₂) + E(a₂,b₁) - E(a₂,b₂)
%
%   for a two-qubit quantum state and four local measurement directions
%   a₁, a₂, b₁, b₂ on the Bloch sphere.
%
% Input:
%   state - quantum state of the two-qubit system. Accepted formats:
%
%             4x1 complex vector      pure state ket |ψ⟩
%             4x4 complex matrix      density matrix ρ_AB
%
%   a₁    - 3x1 real unit vector defining the first measurement axis
%           for subsystem A
%
%   a₂    - 3x1 real unit vector defining the second measurement axis
%           for subsystem A
%
%   b₁    - 3x1 real unit vector defining the first measurement axis
%           for subsystem B
%
%   b₂    - 3x1 real unit vector defining the second measurement axis
%           for subsystem B
%
% Output:
%   S     - real scalar CHSH parameter associated with the selected axes
%
% Notes:
%   The input axes must be normalized Bloch-sphere directions.
%
%   This function evaluates CHSH directly from the input state by calling
%   the arbitrary-axis correlation routine:
%
%       E(a,b) = Tr[ρ_AB * (σ(a) ⊗ σ(b))]
%
%   If the input state is a pure vector, the correlation routine handles the
%   conversion to the corresponding density matrix.
%
%   The function does not maximize over measurement settings. It only evaluates
%   S for the axes explicitly provided as input.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 5
        error('compute_chsh_from_state:InvalidNumInputs', ...
              'Expected 5 input arguments: state, a1, a2, b1, b2.');
    end

    if ~isnumeric(state)
        error('compute_chsh_from_state:InvalidTypeState', ...
              'state must be numeric.');
    end

    if ~(isvector(state) || ismatrix(state))
        error('compute_chsh_from_state:InvalidShapeState', ...
              'state must be either a 4x1 state vector or a 4x4 density matrix.');
    end

    if isvector(state)
        if ~isequal(size(state), [4, 1])
            error('compute_chsh_from_state:InvalidStateVectorSize', ...
                  'Pure state input must be a 4x1 ket vector. Row vectors are not accepted.');
        end

        if any(~isfinite(state), 'all')
            error('compute_chsh_from_state:InvalidValuesState', ...
                  'state must contain only finite values.');
        end

        normalization_tolerance = 1e-12;
        if abs(norm(state) - 1) > normalization_tolerance
            error('compute_chsh_from_state:StateNotNormalized', ...
                  'Pure state input must be normalized.');
        end

    elseif ismatrix(state)
        if ~isequal(size(state), [4, 4])
            error('compute_chsh_from_state:InvalidDensityMatrixSize', ...
                  'Density matrix input must be 4x4.');
        end

        if any(~isfinite(state), 'all')
            error('compute_chsh_from_state:InvalidValuesState', ...
                  'state must contain only finite values.');
        end

        hermiticity_tolerance = 1e-12;
        if norm(state - state', 'fro') > hermiticity_tolerance
            error('compute_chsh_from_state:DensityMatrixNotHermitian', ...
                  'Density matrix input must be Hermitian.');
        end

        trace_tolerance = 1e-12;
        if abs(trace(state) - 1) > trace_tolerance
            error('compute_chsh_from_state:DensityMatrixTraceInvalid', ...
                  'Density matrix input must have trace equal to 1.');
        end
    end

    axes = {a1, a2, b1, b2};
    axes_names = {'a1', 'a2', 'b1', 'b2'};

    axis_norm_tolerance = 1e-12;
    axis_real_tolerance = 1e-12;

    for k = 1:numel(axes)
        current_axis = axes{k};

        if ~isnumeric(current_axis)
            error('compute_chsh_from_state:InvalidTypeAxis', ...
                  '%s must be numeric.', axes_names{k});
        end

        if ~isequal(size(current_axis), [3, 1])
            error('compute_chsh_from_state:InvalidSizeAxis', ...
                  '%s must be a 3x1 vector.', axes_names{k});
        end

        if any(~isfinite(current_axis), 'all')
            error('compute_chsh_from_state:InvalidValuesAxis', ...
                  '%s must contain only finite values.', axes_names{k});
        end

        if any(abs(imag(current_axis)) > axis_real_tolerance)
            error('compute_chsh_from_state:ComplexAxis', ...
                  '%s must be real-valued within numerical tolerance.', axes_names{k});
        end

        if abs(norm(current_axis) - 1) > axis_norm_tolerance
            error('compute_chsh_from_state:NonUnitAxis', ...
                  '%s must be normalized to unit length.', axes_names{k});
        end
    end


    % =========================
    % Main computation
    % =========================

    E11 = compute_correlation_function_from_state(state, a1, b1);
    E12 = compute_correlation_function_from_state(state, a1, b2);
    E21 = compute_correlation_function_from_state(state, a2, b1);
    E22 = compute_correlation_function_from_state(state, a2, b2);

    S = E11 + E12 + E21 - E22;

    realness_tolerance = 1e-10;
    if abs(imag(S)) > realness_tolerance
        error('compute_chsh_from_state:NotReal', ...
              'S must be real-valued within numerical tolerance.');
    end

    S = real(S); % Numerical clean up

end