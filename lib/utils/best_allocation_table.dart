import 'package:flutter/material.dart';
import 'package:pso/algorithm/pso_algorithm.dart';
import 'package:pso/main.dart';

class BestAllocationTable extends StatelessWidget {
  final List<double> gBest;
  final double gBestFitness;
  final List<Task> tasks;

  BestAllocationTable({
    required this.gBest,
    required this.gBestFitness,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals for CPU, memory, and bandwidth
    double totalCpu = 0.0;
    double totalMemory = 0.0;
    double totalBandwidth = 0.0;

    for (int i = 0; i < tasks.length; i++) {
      totalCpu += gBest[i * 3];
      totalMemory += gBest[i * 3 + 1];
      totalBandwidth += gBest[i * 3 + 2];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FractionColumnWidth(0.3),
            1: FractionColumnWidth(0.3),
            2: FractionColumnWidth(0.3),
          },
          children: [
            TableRow(
              children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Task ID'),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('CPU'),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Memory'),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Bandwidth'),
                )),
              ],
            ),
            for (int i = 0; i < tasks.length; i++)
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Task ${tasks[i].id}'),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${gBest[i * 3].toStringAsFixed(2)}'),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${gBest[i * 3 + 1].toStringAsFixed(2)}'),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${gBest[i * 3 + 2].toStringAsFixed(2)}'),
                  )),
                ],
              ),
            TableRow(
              children: [
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Totals',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${totalCpu.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${totalMemory.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${totalBandwidth.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        // Text(
        //   'Best Fitness: ${gBestFitness.toStringAsFixed(2)}',
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
      ],
    );
  }
}
