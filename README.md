# Quantum Fiber Simulator

**Quantum Fiber Simulator** is a MATLAB-based scientific framework for the modeling and simulation of polarization-entangled photon propagation in optical fibers.

The project combines concepts from quantum information theory, quantum optics, and numerical simulation to study how fiber-induced effects influence bipartite entangled states, measurable correlations, and nonlocal quantum properties.

The repository is developed in parallel with an MSc thesis in High Performance Computing Engineering at Politecnico di Milano and follows a progressive modeling philosophy: starting from analytically tractable Bell-state models and extending toward effective noisy fiber channels and experimentally motivated propagation scenarios.

---

# Main Objectives

The framework is designed to:

* model polarization-entangled Bell states,
* simulate local fiber-induced transformations,
* study phase evolution and decoherence effects,
* evaluate quantum correlations and CHSH nonlocality,
* analyze entanglement degradation under noisy channels,
* maintain a direct correspondence between:

  * physical assumptions,
  * mathematical formalism,
  * numerical implementation.

The simulator is intentionally modular and structured as a reusable research-oriented environment rather than a collection of isolated scripts.

---

# Current Features

## Quantum-State Modeling

* Bell-state initialization
* Pure-state and density-matrix representations
* Local unitary evolution
* Reduced phase evolution models
* Partial trace operations

## Quantum Channels

* Global depolarizing channels
* Local depolarizing channels
* Two-arm fiber-channel models
* Composite phase + depolarization modeling

## Measurements and Correlations

* Pauli-based observables
* Correlation tensor computation
* Arbitrary local measurement axes
* Expectation-value evaluation
* CHSH Bell inequality analysis

## Quantum Metrics

* Purity
* Fidelity
* Concurrence
* Reduced density operators
* Bloch-vector evaluation

## Numerical Experiments

Implemented experiments currently include:

1. Deterministic phase evolution
2. Random phase ensemble averaging
3. Depolarizing-channel dynamics
4. CHSH nonlocality analysis
5. Composite fiber-channel analytics (ongoing)

---

# Repository Structure

Quantum-Fiber-Simulator/
│
├── src/
│   ├── core/           # Quantum-state operations and channels
│   ├── experiments/    # Numerical experiment pipelines
│   ├── models/         # Effective fiber models
│   ├── tests/          # Validation and consistency tests
│   └── utils/          # Shared utilities and plotting tools
│
├── text/
│   ├── thesis/         # Main LaTeX thesis manuscript
│   ├── derivations/    # Analytical derivations
│   ├── sources/        # Papers, books, and references
│   └── notes/          # Development notes and planning
│
├── images/             # Generated plots and figures
│
└── main.m              # Main MATLAB entry point


---

# Modeling Philosophy

The project follows a progressive hierarchy of physical models:

Ideal Bell State
    ↓
Local Phase Evolution
    ↓
Random Phase Ensembles
    ↓
Mixed-State Formalism
    ↓
Quantum Channels
    ↓
Effective Fiber Models

This approach allows:

* analytical validation at each stage,
* controlled numerical verification,
* gradual introduction of physical realism,
* modular simulator growth.

---

# Example Topics Covered

The simulator currently investigates:

* phase-induced evolution of Bell states,
* polarization correlations in arbitrary bases,
* correlation tensors and Bloch representations,
* ensemble averaging over stochastic phase realizations,
* entanglement degradation,
* depolarization effects,
* CHSH nonlocality under coherent and incoherent evolution.

---

# Technologies

* MATLAB
* LaTeX
* Quantum Information Theory formalism
* Numerical linear algebra
* Density-operator methods
* Scientific plotting and validation pipelines

---

# Validation Strategy

Particular emphasis is placed on analytical consistency.

Most numerical routines are validated against:

* closed-form analytical predictions,
* tensor identities,
* Hermiticity and trace-preservation checks,
* physical consistency conditions.

Dedicated automated tests are included in:

src/tests/

---

# Thesis Context

This repository accompanies the thesis:

> *Mathematical and Physical Modeling of Entangled Photon Propagation in Optical Fibers*

The manuscript develops the theoretical foundations, derivations, and numerical interpretation associated with the simulator architecture.

---

# Future Directions

Planned extensions include:

* stochastic composite fiber channels,
* time-dependent propagation models,
* infinitesimal propagation approaches,
* dynamic compensation strategies,
* advanced entanglement measures,
* tomography-oriented reconstruction tools.

---

# Author

Marco Cioci
MSc in High Performance Computing Engineering
Politecnico di Milano

---

# Notes

This project is currently under active development and research-oriented restructuring.
Interfaces, APIs, and experiment pipelines may evolve as the theoretical framework progresses.
