import 'package:flutter/material.dart';
import 'package:pso/algorithm/pso_algorithm.dart';
import 'package:pso/main.dart';

class ResourceAnalysis extends StatelessWidget {
  final List<Resource> resources;
  final List<Task> tasks;
  final List<double> gBest;

  ResourceAnalysis({
    required this.resources,
    required this.tasks,
    required this.gBest,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total utilization
    double totalCpu = 0.0;
    double totalMemory = 0.0;
    double totalBandwidth = 0.0;

    for (int i = 0; i < tasks.length; i++) {
      totalCpu += gBest[i * 3];
      totalMemory += gBest[i * 3 + 1];
      totalBandwidth += gBest[i * 3 + 2];
    }

    // Calculate percentage utilization
    double cpuUtilization = totalCpu / resources[0].capacity * 100;
    double memoryUtilization = totalMemory / resources[1].capacity * 100;
    double bandwidthUtilization = totalBandwidth / resources[2].capacity * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Utilization Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
                'CPU Utilization: ${totalCpu.toStringAsFixed(2)} / ${resources[0].capacity.toStringAsFixed(2)} (${cpuUtilization.toStringAsFixed(2)}%)'),
            Text(
                'Memory Utilization: ${totalMemory.toStringAsFixed(2)} / ${resources[1].capacity.toStringAsFixed(2)} (${memoryUtilization.toStringAsFixed(2)}%)'),
            Text(
                'Bandwidth Utilization: ${totalBandwidth.toStringAsFixed(2)} / ${resources[2].capacity.toStringAsFixed(2)} (${bandwidthUtilization.toStringAsFixed(2)}%)'),
          ],
        ),
      ),
    );
  }
}
