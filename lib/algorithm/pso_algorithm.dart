// import 'dart:math';

// class Particle {
//   List<double> allocation;
//   List<double> velocity;
//   late double fitness;
//   List<double> pBest;

//   Particle(int numTasks, int numResources)
//       : allocation = List<double>.generate(
//             numTasks * numResources, (_) => Random().nextDouble() * 10),
//         velocity = List<double>.generate(
//             numTasks * numResources, (_) => Random().nextDouble()),
//         pBest = List<double>.generate(
//             numTasks * numResources, (_) => Random().nextDouble() * 10);
// }

// class Resource {
//   String name;
//   double capacity;

//   Resource({required this.name, required this.capacity});

//   factory Resource.fromJson(Map<String, dynamic> json) {
//     return Resource(
//       name: json['name'],
//       capacity: json['capacity'].toDouble(),
//     );
//   }
// }

// class Task {
//   int id;
//   double cpu;
//   double memory;
//   double bandwidth;

//   Task(
//       {required this.id,
//       required this.cpu,
//       required this.memory,
//       required this.bandwidth});

//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       id: json['id'],
//       cpu: json['cpu'].toDouble(),
//       memory: json['memory'].toDouble(),
//       bandwidth: json['bandwidth'].toDouble(),
//     );
//   }
// }

// class PSO {
//   final int swarmSize;
//   final int maxIterations;
//   double w;
//   final double c1;
//   final double c2;

//   List<Particle>? swarm;
//   List<double> gBest = [];
//   double gBestFitness = double.maxFinite;

//   PSO({
//     required this.swarmSize,
//     required this.maxIterations,
//     required this.w,
//     required this.c1,
//     required this.c2,
//   });

//   void initialize(List<Task> tasks, List<Resource> resources) {
//     int numTasks = tasks.length;
//     int numResources = resources.length;
//     swarm = List.generate(swarmSize, (_) => Particle(numTasks, numResources));
//     gBest = List<double>.from(swarm![0].allocation);
//     print('PSO initialized with swarm size: $swarmSize');
//   }

//   Future<void> run(
//       List<Task> tasks, Function(Map<String, double>) onIteration) async {
//     if (swarm == null) return;

//     double wMin = 0.1;
//     double inertiaWeightDelta = (w - wMin) / maxIterations;

//     for (int iter = 0; iter < maxIterations; iter++) {
//       // Evaluate particles' fitness in parallel
//       await Future.forEach(swarm!, (particle) {
//         var metrics = evaluate(particle.allocation, tasks);
//         particle.fitness =
//             metrics['mse']!; // Assuming MSE is the primary fitness metric
//         if (particle.fitness < evaluate(particle.pBest, tasks)['mse']!) {
//           particle.pBest = List<double>.from(particle.allocation);
//         }
//         if (particle.fitness < gBestFitness) {
//           gBest = List<double>.from(particle.allocation);
//           gBestFitness = particle.fitness;
//         }
//       });

//       onIteration({'mse': gBestFitness, 'mae': evaluate(gBest, tasks)['mae']!});

//       // Update particle positions and velocities
//       for (var particle in swarm!) {
//         for (int d = 0; d < particle.allocation.length; d++) {
//           particle.velocity[d] = w * particle.velocity[d] +
//               c1 *
//                   Random().nextDouble() *
//                   (particle.pBest[d] - particle.allocation[d]) +
//               c2 * Random().nextDouble() * (gBest[d] - particle.allocation[d]);
//           particle.allocation[d] += particle.velocity[d];
//         }
//       }

//       // Decrease inertia weight
//       w = max(wMin, w - inertiaWeightDelta);

//       await Future.delayed(Duration(milliseconds: 50));
//     }
//   }

//   Map<String, double> evaluate(List<double> allocation, List<Task> tasks) {
//     double mse = 0.0;
//     double mae = 0.0;

//     for (int i = 0; i < tasks.length; i++) {
//       double cpuError = allocation[i * 3] - tasks[i].cpu;
//       double memoryError = allocation[i * 3 + 1] - tasks[i].memory;
//       double bandwidthError = allocation[i * 3 + 2] - tasks[i].bandwidth;

//       mse += pow(cpuError, 2) + pow(memoryError, 2) + pow(bandwidthError, 2);
//       mae += cpuError.abs() + memoryError.abs() + bandwidthError.abs();
//     }

//     mse /= tasks.length * 3;
//     mae /= tasks.length * 3;

//     return {'mse': mse, 'mae': mae};
//   }
// }

import 'dart:math';

class Particle {
  List<double> allocation;
  List<double> velocity;
  late double fitness;
  List<double> pBest;

  static final Random _random = Random();

  Particle(int numTasks, int numResources)
      : allocation = List<double>.generate(
            numTasks * numResources, (_) => _random.nextDouble() * 10),
        velocity = List<double>.generate(
            numTasks * numResources, (_) => _random.nextDouble()),
        pBest = List<double>.generate(
            numTasks * numResources, (_) => _random.nextDouble() * 10);
}

class Resource {
  String name;
  double capacity;

  Resource({required this.name, required this.capacity});

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      name: json['name'],
      capacity: json['capacity'].toDouble(),
    );
  }
}

class Task {
  int id;
  double cpu;
  double memory;
  double bandwidth;

  Task(
      {required this.id,
      required this.cpu,
      required this.memory,
      required this.bandwidth});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      cpu: json['cpu'].toDouble(),
      memory: json['memory'].toDouble(),
      bandwidth: json['bandwidth'].toDouble(),
    );
  }
}

class PSO {
  final int swarmSize;
  final int maxIterations;
  double w;
  final double c1;
  final double c2;

  List<Particle>? swarm;
  List<double> gBest = [];
  double gBestFitness = double.maxFinite;

  PSO({
    required this.swarmSize,
    required this.maxIterations,
    required this.w,
    required this.c1,
    required this.c2,
  });

  void initialize(List<Task> tasks, List<Resource> resources) {
    int numTasks = tasks.length;
    int numResources = resources.length;
    swarm = List.generate(swarmSize, (_) => Particle(numTasks, numResources));
    gBest = List<double>.from(swarm![0].allocation);
    print('PSO initialized with swarm size: $swarmSize');
  }

  Future<void> run(
      List<Task> tasks, Function(Map<String, double>) onIteration) async {
    if (swarm == null) return;

    double wMin = 0.1;
    double inertiaWeightDelta = (w - wMin) / maxIterations;

    for (int iter = 0; iter < maxIterations; iter++) {
      await Future.forEach(swarm!, (particle) {
        var metrics = evaluate(particle.allocation, tasks);
        particle.fitness =
            metrics['mse']!; // Assuming MSE is the primary fitness metric
        if (particle.fitness < evaluate(particle.pBest, tasks)['mse']!) {
          particle.pBest = List<double>.from(particle.allocation);
        }
        if (particle.fitness < gBestFitness) {
          gBest = List<double>.from(particle.allocation);
          gBestFitness = particle.fitness;
        }
      });

      onIteration({'mse': gBestFitness, 'mae': evaluate(gBest, tasks)['mae']!});

      for (var particle in swarm!) {
        for (int d = 0; d < particle.allocation.length; d++) {
          particle.velocity[d] = w * particle.velocity[d] +
              c1 *
                  Random().nextDouble() *
                  (particle.pBest[d] - particle.allocation[d]) +
              c2 * Random().nextDouble() * (gBest[d] - particle.allocation[d]);
          particle.allocation[d] += particle.velocity[d];
        }
      }

      w = max(wMin, w - inertiaWeightDelta);

      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  Map<String, double> evaluate(List<double> allocation, List<Task> tasks) {
    double mse = 0.0;
    double mae = 0.0;

    for (int i = 0; i < tasks.length; i++) {
      double cpuError = allocation[i * 3] - tasks[i].cpu;
      double memoryError = allocation[i * 3 + 1] - tasks[i].memory;
      double bandwidthError = allocation[i * 3 + 2] - tasks[i].bandwidth;

      mse += pow(cpuError, 2) + pow(memoryError, 2) + pow(bandwidthError, 2);
      mae += cpuError.abs() + memoryError.abs() + bandwidthError.abs();
    }

    mse /= tasks.length * 3;
    mae /= tasks.length * 3;

    return {'mse': mse, 'mae': mae};
  }
}

class Range {
  final double min;
  final double max;

  Range(this.min, this.max);

  double random() => min + Random().nextDouble() * (max - min);
}

Future<void> main() async {
  // Define ranges for parameters
  final wRange = Range(0.1, 1.0);
  final c1Range = Range(1.0, 2.0);
  final c2Range = Range(1.0, 2.0);

  // Number of iterations for random search
  final iterations = 10;

  // Initialize best parameters and best fitness
  var bestParams = {'w': 0.0, 'c1': 0.0, 'c2': 0.0};
  var bestFitness = double.infinity;

  // Example data: Initialize tasks and resources with your actual data
  List<Task> tasks = [
    Task(id: 1, cpu: 2.0, memory: 1.5, bandwidth: 1.0),
    Task(id: 2, cpu: 1.0, memory: 2.0, bandwidth: 1.5),
  ];
  List<Resource> resources = [
    Resource(name: 'CPU', capacity: 10.0),
    Resource(name: 'Memory', capacity: 10.0),
    Resource(name: 'Bandwidth', capacity: 10.0),
  ];

  // Random search loop
  for (var i = 0; i < iterations; i++) {
    // Generate random parameters within defined ranges
    var params = {
      'w': wRange.random(),
      'c1': c1Range.random(),
      'c2': c2Range.random(),
    };

    // Initialize PSO with current parameters
    var pso = PSO(
      swarmSize: 20, // Adjust swarm size as needed
      maxIterations: 100, // Adjust max iterations as needed
      w: params['w']!,
      c1: params['c1']!,
      c2: params['c2']!,
    );

    pso.initialize(tasks, resources);

    // Run PSO and get final fitness
    await pso.run(tasks, (metrics) {
      // Evaluate final fitness (MSE or other metrics)
      var fitness = metrics['mse'] ?? double.infinity;

      // Update best parameters if current iteration is better
      if (fitness < bestFitness) {
        bestFitness = fitness;
        bestParams = params;
      }
    });
  }

  // Output best parameters found
  print('Best Parameters: $bestParams');
  print('Best Fitness: $bestFitness');
}
