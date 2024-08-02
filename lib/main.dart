import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pso/utils/best_allocation_table.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PSOSimulation(),
    );
  }
}

class PSOSimulation extends StatefulWidget {
  @override
  _PSOSimulationState createState() => _PSOSimulationState();
}

class _PSOSimulationState extends State<PSOSimulation> {
  static const int swarmSize = 30;
  static const int maxIterations = 100;
  final double w = 0.5;
  final double c1 = 1.5;
  final double c2 = 1.5;

  List<Resource>? resources;
  List<Task>? tasks;
  List<Particle>? swarm;
  List<double>? gBest;
  double gBestFitness = double.maxFinite;
  bool isRunning = false;
  List<double> fitnessProgress = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      String data = await rootBundle.loadString('assets/cloud_resources.json');
      final jsonResult = json.decode(data);
      resources = (jsonResult['resources'] as List)
          .map((r) => Resource.fromJson(r))
          .toList();
      tasks =
          (jsonResult['tasks'] as List).map((t) => Task.fromJson(t)).toList();

      // Notify Flutter that the data has been loaded and the widget needs to rebuild
      setState(() {
        initializePSO();
      });
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  void initializePSO() {
    if (tasks == null || resources == null) return;
    int numTasks = tasks!.length;
    int numResources = resources!.length;
    swarm = List.generate(swarmSize, (_) => Particle(numTasks, numResources));
    gBest = List<double>.from(swarm![0].allocation);
    print('PSO initialized with swarm size: $swarmSize');
  }

  void runPSO() async {
    setState(() {
      isRunning = true;
      fitnessProgress.clear(); // Clear previous progress
    });

    if (swarm == null) return;

    // Start timing
    final stopwatch = Stopwatch()..start();

    for (int iter = 0; iter < maxIterations; iter++) {
      for (var particle in swarm!) {
        particle.fitness = evaluate(particle.allocation);
        if (particle.fitness < evaluate(particle.pBest)) {
          particle.pBest = List<double>.from(particle.allocation);
        }
        if (particle.fitness < gBestFitness) {
          gBest = List<double>.from(particle.allocation);
          gBestFitness = particle.fitness;
        }
      }

      // Track fitness progress
      fitnessProgress.add(gBestFitness);

      for (var particle in swarm!) {
        for (int d = 0; d < particle.allocation.length; d++) {
          particle.velocity[d] = w * particle.velocity[d] +
              c1 *
                  Random().nextDouble() *
                  (particle.pBest[d] - particle.allocation[d]) +
              c2 * Random().nextDouble() * (gBest![d] - particle.allocation[d]);
          particle.allocation[d] += particle.velocity[d];
        }
      }
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {});
    }

    // Stop timing
    stopwatch.stop();
    print('PSO completed in ${stopwatch.elapsedMilliseconds} ms');

    setState(() {
      isRunning = false;
    });
  }

  double evaluate(List<double> allocation) {
    double fitness = 0.0;
    for (int i = 0; i < tasks!.length; i++) {
      fitness += pow(allocation[i * 3] - tasks![i].cpu, 2).toDouble();
      fitness += pow(allocation[i * 3 + 1] - tasks![i].memory, 2).toDouble();
      fitness += pow(allocation[i * 3 + 2] - tasks![i].bandwidth, 2).toDouble();
    }
    return fitness;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PSO Cloud Resource Allocation'),
      ),
      body: resources == null && tasks == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Text(
                          'Cloud Resources',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        for (var resource in resources!)
                          Card(
                            child: ListTile(
                              title: Text(resource.name),
                              subtitle: Text(
                                  'Capacity: ${resource.capacity.toStringAsFixed(2)}'),
                            ),
                          ),
                        SizedBox(height: 20),
                        Text(
                          'Tasks',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        for (var task in tasks!)
                          ListTile(
                            title: Text('Task ${task.id}'),
                            subtitle: Text(
                                'CPU: ${task.cpu}, Memory: ${task.memory}, Bandwidth: ${task.bandwidth}'),
                          ),
                        SizedBox(height: 20),
                        if (gBest != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Allocation:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(gBest!.toStringAsFixed(2)),
                              SizedBox(height: 20),
                              BestAllocationTable(
                                gBest: gBest,
                                gBestFitness: gBestFitness,
                                tasks: tasks!,
                              ),
                              SizedBox(height: 20),
                              // Fitness Chart
                              Text(
                                'Fitness Progress:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              FitnessChart(fitnessValues: fitnessProgress),
                            ],
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isRunning ? null : runPSO,
                    child: Text(isRunning ? 'Running...' : 'Start PSO'),
                  ),
                ],
              ),
            ),
    );
  }
}

class Particle {
  List<double> allocation;
  List<double> velocity;
  late double fitness;
  List<double> pBest;

  Particle(int numTasks, int numResources)
      : allocation = List<double>.generate(
            numTasks * numResources, (_) => Random().nextDouble() * 10),
        velocity = List<double>.generate(
            numTasks * numResources, (_) => Random().nextDouble()),
        pBest = List<double>.generate(
            numTasks * numResources, (_) => Random().nextDouble() * 10);
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

extension DoubleListExtension on List<double> {
  String toStringAsFixed(int fractionDigits) {
    return map((e) => e.toStringAsFixed(fractionDigits)).join(', ');
  }
}

// import 'package:fl_chart/fl_chart.dart';

class FitnessChart extends StatelessWidget {
  final List<double> fitnessValues;

  FitnessChart({required this.fitnessValues});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: fitnessValues.asMap().entries.map((entry) {
                int index = entry.key;
                double value = entry.value;
                return FlSpot(index.toDouble(), value);
              }).toList(),
              isCurved: true,
              // colors: [Colors.blue],
              color: Colors.blue,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
