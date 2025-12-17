import 'dart:async';
import 'package:flutter/material.dart';

class CookingTimerScreen extends StatefulWidget {
  final int totalMinutes;
  final String recipeName;

  const CookingTimerScreen({
    super.key,
    required this.totalMinutes,
    required this.recipeName,
  });

  @override
  State<CookingTimerScreen> createState() => _CookingTimerScreenState();
}

class _CookingTimerScreenState extends State<CookingTimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _showCompletionDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.totalMinutes * 60;
      _isRunning = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Time\'s Up!'),
        content: Text('${widget.recipeName} is ready!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 - (_remainingSeconds / (widget.totalMinutes * 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Timer'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.recipeName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 15,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingSeconds < 60 ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds < 60 ? Colors.red : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _remainingSeconds < 60 ? 'Almost done!' : 'Cooking...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.grey : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}