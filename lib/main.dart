import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pso/algorithm/pso_algorithm.dart';
import 'package:pso/utils/best_allocation_table.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pso/utils/resource_analysis.dart';

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
  static const int swarmSize = 50;
  static const int maxIterations = 200;
  final double w = 0.7;
  final double c1 = 2.0;
  final double c2 = 2.0;
  bool refresh = false;
  List<Resource>? resources;
  List<Task>? tasks;
  PSO? pso;
  bool isRunning = false;
  List<double> fitnessProgress = [];
  double mse = 0.0;
  double mae = 0.0;

  @override
  void initState() {
    super.initState();
    generateRandomData();
  }

  void generateRandomData() {
    final random = Random();
    final double maxResourceCapacity = 100.0;
    final int numTasks = 5;
    final double spikeChance = 0.5; // Increase the chance for a spike to 50%
    final double exceedLimitChance =
        0.2; // Chance to exceed the total capacity limits
    final double resourceSpikeChance = 0.2; // Chance for resources to spike

    double resourceMultiplier = 1.0;

    // Random chance to increase resource capacities by 50%
    if (random.nextDouble() < resourceSpikeChance) {
      resourceMultiplier = 1.5;
    }

    // Initialize resources with possibly increased capacities
    resources = [
      Resource(name: 'CPU', capacity: maxResourceCapacity * resourceMultiplier),
      Resource(
          name: 'Memory', capacity: maxResourceCapacity * resourceMultiplier),
      Resource(
          name: 'Bandwidth',
          capacity: maxResourceCapacity * resourceMultiplier),
    ];

    double totalCpu = 0.0;
    double totalMemory = 0.0;
    double totalBandwidth = 0.0;

    List<Task> generatedTasks = [];
    for (int i = 0; i < numTasks; i++) {
      double cpu = random.nextDouble() * 10 + 10;
      double memory = random.nextDouble() * 10 + 10;
      double bandwidth = random.nextDouble() * 10 + 10;

      totalCpu += cpu;
      totalMemory += memory;
      totalBandwidth += bandwidth;

      generatedTasks.add(Task(
        id: i + 1,
        cpu: cpu,
        memory: memory,
        bandwidth: bandwidth,
      ));
    }

    double totalAvailableCpu = resources![0].capacity;
    double totalAvailableMemory = resources![1].capacity;
    double totalAvailableBandwidth = resources![2].capacity;

    // Scaling factor to ensure total requirements do not exceed total resources
    double scalingFactorCpu = totalAvailableCpu / totalCpu;
    double scalingFactorMemory = totalAvailableMemory / totalMemory;
    double scalingFactorBandwidth = totalAvailableBandwidth / totalBandwidth;

    // Use the smallest scaling factor to ensure all requirements fit within available resources
    double scalingFactor =
        min(scalingFactorCpu, min(scalingFactorMemory, scalingFactorBandwidth));

    // Apply the scaling factor to all tasks
    generatedTasks = generatedTasks.map((task) {
      return Task(
        id: task.id,
        cpu: task.cpu * scalingFactor,
        memory: task.memory * scalingFactor,
        bandwidth: task.bandwidth * scalingFactor,
      );
    }).toList();

    tasks = generatedTasks;

    setState(() {
      initializePSO();
    });
  }

  // void generateRandomData() {
  //   final random = Random();
  //   final double maxResourceCapacity = 100.0;
  //   final int numTasks = 5;
  //   final double spikeChance = 0.1;

  //   resources = [
  //     Resource(name: 'CPU', capacity: maxResourceCapacity),
  //     Resource(name: 'Memory', capacity: maxResourceCapacity),
  //     Resource(name: 'Bandwidth', capacity: maxResourceCapacity),
  //   ];

  //   double totalTaskCpu = 0;
  //   double totalTaskMemory = 0;
  //   double totalTaskBandwidth = 0;

  //   List<Task> generatedTasks = [];
  //   for (int i = 0; i < numTasks; i++) {
  //     double cpu = random.nextDouble() * 10 + 10;
  //     double memory = random.nextDouble() * 10 + 10;
  //     double bandwidth = random.nextDouble() * 10 + 10;

  //     totalTaskCpu += cpu;
  //     totalTaskMemory += memory;
  //     totalTaskBandwidth += bandwidth;

  //     generatedTasks.add(Task(
  //       id: i + 1,
  //       cpu: cpu,
  //       memory: memory,
  //       bandwidth: bandwidth,
  //     ));
  //   }

  //   final double totalResourceCapacity =
  //       resources!.fold(0, (sum, resource) => sum + resource.capacity);

  //   if (random.nextDouble() < spikeChance) {
  //     double capacityFactor = totalResourceCapacity /
  //         max(totalTaskCpu, max(totalTaskMemory, totalTaskBandwidth));
  //     if (capacityFactor < 1.0) {
  //       generatedTasks = generatedTasks.map((task) {
  //         return Task(
  //           id: task.id,
  //           cpu: task.cpu * 1.5,
  //           memory: task.memory * 1.5,
  //           bandwidth: task.bandwidth * 1.5,
  //         );
  //       }).toList();
  //     }
  //   }

  //   generatedTasks = generatedTasks.map((task) {
  //     return Task(
  //       id: task.id,
  //       cpu: min(task.cpu, maxResourceCapacity),
  //       memory: min(task.memory, maxResourceCapacity),
  //       bandwidth: min(task.bandwidth, maxResourceCapacity),
  //     );
  //   }).toList();

  //   tasks = generatedTasks;

  //   setState(() {
  //     initializePSO();
  //   });
  // }

  void initializePSO() {
    if (tasks == null || resources == null) {
      print('Tasks or resources are null');
      return;
    }
    pso = PSO(
      swarmSize: swarmSize,
      maxIterations: maxIterations,
      w: w,
      c1: c1,
      c2: c2,
    );
    pso!.initialize(tasks!, resources!);
  }

  void runPSO() async {
    setState(() {
      isRunning = true;
      fitnessProgress.clear();
    });

    if (pso == null || tasks == null) {
      print('PSO or tasks not initialized');
      return;
    }

    final stopwatch = Stopwatch()..start();

    await pso!.run(tasks!, (metrics) {
      setState(() {
        fitnessProgress.add(metrics['mse']!);
        mse = metrics['mse']!;
        mae = metrics['mae']!;
      });
      print(
          'Current metrics: MSE = ${metrics['mse']}, MAE = ${metrics['mae']}');
    });

    stopwatch.stop();
    print('PSO completed in ${stopwatch.elapsedMilliseconds} ms');

    setState(() {
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double totalCpu = tasks?.fold(0, (sum, task) => sum! + task.cpu) ?? 0;
    double totalMemory = tasks?.fold(0, (sum, task) => sum! + task.memory) ?? 0;
    double totalBandwidth =
        tasks?.fold(0, (sum, task) => sum! + task.bandwidth) ?? 0;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                generateRandomData();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
        title: Text('PSO Cloud Resource Allocation'),
      ),
      body: resources == null || tasks == null
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Task ID')),
                              DataColumn(label: Text('CPU')),
                              DataColumn(label: Text('Memory')),
                              DataColumn(label: Text('Bandwidth')),
                            ],
                            rows: [
                              ...tasks!.map((task) {
                                return DataRow(cells: [
                                  DataCell(Text(task.id.toString())),
                                  DataCell(Text(task.cpu.toStringAsFixed(2))),
                                  DataCell(
                                      Text(task.memory.toStringAsFixed(2))),
                                  DataCell(
                                      Text(task.bandwidth.toStringAsFixed(2))),
                                ]);
                              }).toList(),
                              DataRow(
                                  cells: [
                                    DataCell(Text('Total')),
                                    DataCell(Text(totalCpu.toStringAsFixed(2))),
                                    DataCell(
                                        Text(totalMemory.toStringAsFixed(2))),
                                    DataCell(Text(
                                        totalBandwidth.toStringAsFixed(2))),
                                  ],
                                  color: MaterialStateProperty.all(
                                      Colors.grey[200])),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (pso != null && pso!.gBest.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Allocation:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(pso!.gBest.toStringAsFixed(2)),
                              SizedBox(height: 20),
                              BestAllocationTable(
                                gBest: pso!.gBest,
                                gBestFitness: pso!.gBestFitness,
                                tasks: tasks!,
                              ),
                              SizedBox(height: 20),
                              ResourceAnalysis(
                                resources: resources!,
                                tasks: tasks!,
                                gBest: pso!.gBest,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Fitness Progress:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FitnessChart(fitnessValues: fitnessProgress),
                              SizedBox(height: 20),
                              Text(
                                'Performance Metrics:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('MSE: ${mse.toStringAsFixed(10)}'),
                              Text('MAE: ${mae.toStringAsFixed(10)}'),
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

extension DoubleListExtension on List<double> {
  String toStringAsFixed(int fractionDigits) {
    return map((e) => e.toStringAsFixed(fractionDigits)).join(', ');
  }
}

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
              spots: fitnessValues
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              // colors: [Colors.blue],
              color: Colors.black,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
