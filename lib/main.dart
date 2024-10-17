import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<Object>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              Color? iconColor;
              switch (e) {
                case Icons.person:
                  iconColor = Colors.red;
                  break;

                case Icons.message:
                  iconColor = Colors.yellow;
                  break;

                case Icons.call:
                  iconColor = Colors.green;
                  break;

                case Icons.camera:
                  iconColor = Colors.cyan;
                  break;
                case Icons.photo:
                  iconColor = Colors.pink;
                  break;
              }
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e as IconData, color: iconColor)),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  // Initial T items to put in this Dock.
  final List<T> items;

  // Builder building the provided T item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the Dock used to manipulate the _items.
class _DockState<T extends Object> extends State<Dock<T>> {
  // [T] items being manipulated.
  late List<T> _items = widget.items.toList();

  // Keeps track of the dragged item.
  T? _draggedItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _items
                .asMap()
                .entries
                .map(
                  (entry) => _buildDraggableTarget(entry.key, entry.value),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // Builds a draggable and drag target widget for each item.
  Widget _buildDraggableTarget(int index, T item) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (data) => data != null && data != item,
      onAccept: (receivedItem) {
        setState(() {
          _items.remove(receivedItem);
          _items.insert(index, receivedItem);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<T>(
          data: item,
          feedback: Material(
            color: Colors.transparent,
            child: widget.builder(item),
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragStarted: () {
            _draggedItem = item;
          },
          onDragCompleted: () {
            _draggedItem = null;
          },
          onDraggableCanceled: (velocity, offset) {
            _draggedItem = null;
          },
          child: widget.builder(item),
        );
      },
    );
  }
}
