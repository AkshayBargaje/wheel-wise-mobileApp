import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Simulate fetching notifications from an API
  Future<List<String>> fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return []; // Empty list to simulate no notifications
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchNotifications(), // Call the function to fetch notifications
        builder: (context, snapshot) {
          // If the request is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If there's an error in fetching data
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching notifications'),
            );
          }

          // If no notifications found
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          // If there are notifications, display them in a ListView
          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notifications[index]),
              );
            },
          );
        },
      ),
    );
  }
}
