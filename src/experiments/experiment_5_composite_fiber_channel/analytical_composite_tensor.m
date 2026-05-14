function T_out = analytical_composite_tensor(theta, p_A, p_B)
% ANALYTICAL_COMPOSITE_TENSOR  Analytical tensor of the composite fiber model.
%
% Objective:
%   Return the analytical correlation tensor associated with the
%   deterministic composite phase--depolarization channel:
%
%       T_out(θ,p_A,p_B)
%       =
%       η T(θ)
%
%   where
%
%       η = (1-p_A)(1-p_B)
%
%   and
%
%       T(θ) =
%           [ cos(θ)  -sin(θ)   0
%             sin(θ)   cos(θ)   0
%                0        0    -1 ]
%
% Input:
%   theta - phase parameter
%   p_A   - depolarization parameter on subsystem A
%   p_B   - depolarization parameter on subsystem B
%
% Output:
%   T_out - 3x3 analytical correlation tensor
%
% Notes:
%   The tensor follows the convention adopted throughout the thesis for the
%   phase-evolved Bell state:
%
%       |ψ(θ)⟩ = (|01⟩ + exp(iθ)|10⟩)/sqrt(2)

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('analytical_composite_tensor:InvalidNumInputs', ...
              'Expected 3 input arguments: theta, p_A, p_B.');
    end

    if ~isnumeric(theta) || ~isscalar(theta) || ~isreal(theta) || ~isfinite(theta)
        error('analytical_composite_tensor:InvalidTheta', ...
              'theta must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A) || ~isfinite(p_A)
        error('analytical_composite_tensor:InvalidParameterA', ...
              'p_A must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B) || ~isfinite(p_B)
        error('analytical_composite_tensor:InvalidParameterB', ...
              'p_B must be a finite real numeric scalar.');
    end

    if p_A < 0 || p_A > 1
        error('analytical_composite_tensor:InvalidRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if p_B < 0 || p_B > 1
        error('analytical_composite_tensor:InvalidRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end


    % =========================
    % Main computation
    % =========================

    eta = (1 - p_A) * (1 - p_B);

    T_out = eta * ...
        [ cos(theta), -sin(theta), 0; ...
          sin(theta),  cos(theta), 0; ...
          0,           0,         -1 ];

end