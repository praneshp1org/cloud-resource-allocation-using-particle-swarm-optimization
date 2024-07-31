import 'package:flutter/material.dart';
import 'package:pso/main.dart';

class BestAllocationTable extends StatelessWidget {
  final List<double>? gBest;
  final double gBestFitness;
  final List<Task> tasks;

  BestAllocationTable(
      {this.gBest, required this.gBestFitness, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Allocation:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (gBest != null)
          Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Task ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'CPU Allocation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Memory Allocation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Bandwidth Allocation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '% Utilization',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              for (int i = 0; i < tasks.length; i++)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Task ${tasks[i].id}',
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          gBest![i * 3].toStringAsFixed(2),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          gBest![i * 3 + 1].toStringAsFixed(2),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          gBest![i * 3 + 2].toStringAsFixed(2),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ((gBest![i * 3] +
                                      gBest![i * 3 + 1] +
                                      gBest![i * 3 + 2]) /
                                  (tasks[i].cpu +
                                      tasks[i].memory +
                                      tasks[i].bandwidth) *
                                  100)
                              .toStringAsFixed(2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        SizedBox(height: 10),
        Text(
          'Best Fitness:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(gBestFitness.toStringAsFixed(2)),
      ],
    );
  }
}
