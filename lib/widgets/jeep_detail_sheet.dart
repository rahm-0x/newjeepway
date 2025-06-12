import 'package:flutter/material.dart';

class JeepDetailSheet extends StatelessWidget {
  final String driverName;
  final int seats;
  final String routeNumber;

  const JeepDetailSheet({
    super.key,
    required this.driverName,
    required this.seats,
    required this.routeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/driver_placeholder.png'),
          ),
          const SizedBox(height: 10),
          Text(
            'Driver: $driverName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/jeepney_placeholder.png',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                const Icon(Icons.event_seat, size: 28),
                const SizedBox(height: 4),
                Text('$seats Seats'),
              ]),
              Column(children: [
                const Icon(Icons.route, size: 28),
                const SizedBox(height: 4),
                Text('Route $routeNumber'),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
