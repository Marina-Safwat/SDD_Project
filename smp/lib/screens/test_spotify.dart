import 'package:flutter/material.dart';
import 'package:smp/services/apiService.dart';

void testFetch() {
  // Only works on Flutter Web
// put at the top of your file
}

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  String status = 'Not tested';
  bool isLoading = false;

  Future<void> testApi() async {
    setState(() {
      isLoading = true;
      status = 'Testing...';
    });

    try {
      // Test connection
      final isConnected = await ApiService.testConnection();

      if (!isConnected) {
        setState(() {
          status = '❌ Connection failed';
          isLoading = false;
        });
        return;
      }

      // Fetch songs dynamically
      final songs = await ApiService.fetchPlaylist(mood: 'happy', limit: 5);

      if (songs.data == null || songs.data!.isEmpty) {
        setState(() {
          status = '⚠️ API reachable but returned no songs';
          isLoading = false;
        });
        return;
      }

      // Build output string
      final buffer = StringBuffer(
          '✅ SUCCESS!\n\nFetched ${songs.data!.length} songs:\n\n');
      for (var song in songs.data!) {
        buffer.writeln('• ${song.name}');
        buffer.writeln('  by ${song.artists.join(', ')}');
        buffer.writeln('  Audio URL: ${song.audioUrl ?? "N/A"}\n');
      }

      setState(() {
        status = buffer.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = '❌ ERROR:\n\n$e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Call testFetch() only for debug purposes in Web
    testFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testApi,
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test API Connection',
                      style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    status,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
