# PSO Cloud Resource Allocation

## Overview

This project implements a Particle Swarm Optimization (PSO) algorithm to address cloud resource allocation challenges. The app is built using Flutter and demonstrates how PSO can be applied to optimize the allocation of cloud resources like CPU, Memory, and Bandwidth to various tasks.

## Particle Swarm Optimization (PSO)

Particle Swarm Optimization (PSO) is a computational technique inspired by the social behavior of birds flocking or fish schooling. It is used to find optimal solutions to optimization problems by simulating a group (or swarm) of candidate solutions (particles) moving around in the search space.

### Key Concepts

- **Particles**: Each particle represents a potential solution to the optimization problem. It has a position and velocity in the search space.
- **Swarm**: The entire group of particles that collectively explore the solution space.
- **Fitness Function**: A function that evaluates how good a particle’s solution is. The goal is to maximize or minimize this function.
- **Personal Best (pBest)**: The best solution that a particle has found so far.
- **Global Best (gBest)**: The best solution found by any particle in the swarm.

### How PSO Works

1. **Initialization**: Randomly initialize the positions and velocities of particles in the search space.
2. **Evaluation**: Calculate the fitness of each particle using the fitness function.
3. **Update Personal and Global Bests**: Update each particle’s personal best and the global best if a better solution is found.
4. **Velocity and Position Update**: Adjust each particle’s velocity and position based on its personal best and the global best.
5. **Repeat**: Iterate through the evaluation and update steps until a stopping criterion is met (e.g., a maximum number of iterations or convergence).

The PSO algorithm aims to find the optimal allocation of resources to tasks by exploring different possible solutions and refining them over time.

## Features

- **Dynamic Resource Allocation**: Allocate CPU, Memory, and Bandwidth to tasks using PSO.
- **Random Data Generation**: Generate random tasks and resources to simulate different scenarios.
- **Performance Metrics**: Display Mean Squared Error (MSE) and Mean Absolute Error (MAE) metrics.
- **Visualization**: Shows a line chart of fitness progress and resource allocation details.

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- Dart SDK installed (comes with Flutter).
- A code editor (e.g., Visual Studio Code, Android Studio).

### Installation

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/praneshp1org/cloud-resource-allocation-using-particle-swarm-optimization
    cd pso
    ```

2. **Install Dependencies**:

    Run the following command to get all the required dependencies:

    ```bash
    flutter pub get
    ```

3. **Run the App**:

    Use the following command to run the app on an emulator or a connected device:

    ```bash
    flutter run
    ```

## Usage

1. **Generate Random Data**: Use the refresh button in the app to generate new random data for tasks and resources.
2. **Run PSO**: Start the PSO algorithm by pressing the "Start PSO" button to see the optimization in action.
3. **View Results**: Check the `DataTable` for task details, resource utilization, and the best allocation found by the PSO algorithm.

## Files Description

- **`main.dart`**: Contains the main application logic and UI setup.
- **`lib/algorithm/pso_algorithm.dart`**: Implements the core PSO algorithm for optimizing resource allocation.
- **`lib/utils/best_allocation_table.dart`**: Provides a table displaying the best resource allocation found.
- **`lib/utils/resource_analysis.dart`**: Analyzes and presents resource utilization details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Flutter team for providing the framework to build this application.
- Special thanks to the community for contributing to the development and improvements of PSO algorithms.




## Demo
### iOS
![Demo](/assets/Screenshot%202024-08-05%20at%2022.23.55.png)

### Web
![Demo Web](/assets/Screenshot%202024-08-05%20at%2022.26.04.png)