import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (item, isHovered) {
              return AnimatedScale(
                scale: isHovered ? 1.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors
                        .primaries[item.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(item, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock with draggable and animated items.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item with hover state.
  final Widget Function(T, bool isHovered) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// The currently hovered item.
  T? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items
            .map((item) => DragTarget<T>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    setState(() {
                      final oldIndex = _items.indexOf(data);
                      final newIndex = _items.indexOf(item);
                      _items.removeAt(oldIndex);
                      _items.insert(newIndex, data);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Draggable<T>(
                      data: item,
                      feedback: Opacity(
                        opacity: 0.7,
                        child: widget.builder(item, true),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      onDragStarted: () {
                        setState(() {
                          _hoveredItem = null;
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) => setState(() {
                          _hoveredItem = item;
                        }),
                        onExit: (_) => setState(() {
                          _hoveredItem = null;
                        }),
                        child: widget.builder(item, _hoveredItem == item),
                      ),
                    );
                  },
                ))
            .toList(),
      ),
    );
  }
}
