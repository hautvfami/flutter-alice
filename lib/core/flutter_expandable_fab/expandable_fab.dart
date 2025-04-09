// import 'dart:math' as math;
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'action_button_builder.dart';

// /// The type of behavior of this widget.
// enum ExpandableFabType { fan, up, side }

// /// The position options for the FAB on the screen.
// enum ExpandableFabPos { right, left, center }

// /// Animation Type
// enum ExpandableFabAnimation { none, rotate }

// /// Style configuration for the overlay displayed behind the Expandable FAB.
// @immutable
// class ExpandableFabOverlayStyle {
//   /// Creates an `ExpandableFabOverlayStyle` with the specified optional parameters.
//   ///
//   /// - [color]: The color to paint behind the FAB.
//   /// - [blur]: The strength of the blur behind the FAB.
//   ///
//   /// Only one of [color] or [blur] can be specified; both cannot be non-null at the same time.
//   const ExpandableFabOverlayStyle({
//     this.color,
//     this.blur,
//   });

//   /// The color to paint behind the Fab.
//   final Color? color;

//   /// The strength of the blur behind Fab.
//   final double? blur;
// }

// /// A FloatingActionButton that can show/hide multiple action buttons with animation.
// ///
// /// ```dart
// /// Scaffold(
// ///   floatingActionButtonLocation: ExpandableFab.location,
// ///   floatingActionButton: ExpandableFab(
// ///     children: [
// ///       FloatingActionButton.small(
// ///         heroTag: null,
// ///         child: const Icon(Icons.edit),
// ///         onPressed: () {},
// ///       ),
// ///       FloatingActionButton.small(
// ///         heroTag: null,
// ///         child: const Icon(Icons.search),
// ///         onPressed: () {},
// ///       ),
// ///     ],
// ///   ),
// /// );
// /// ```
// ///
// @immutable
// class ExpandableFab extends StatefulWidget {
//   /// The location of the ExpandableFab on the screen.
//   static final FloatingActionButtonLocation location = _ExpandableFabLocation();

//   const ExpandableFab({
//     this.distance = 100,
//     this.duration = const Duration(milliseconds: 250),
//     this.fanAngle = 90,
//     this.initialOpen = false,
//     this.type = ExpandableFabType.fan,
//     this.pos = ExpandableFabPos.right,
//     this.childrenAnimation = ExpandableFabAnimation.rotate,
//     this.closeButtonBuilder,
//     this.openButtonBuilder,
//     this.childrenOffset = Offset.zero,
//     required this.children,
//     this.onOpen,
//     this.afterOpen,
//     this.onClose,
//     this.afterClose,
//     this.overlayStyle,
//     this.openCloseStackAlignment = Alignment.center,
//     this.elevation,
//     this.margin = const EdgeInsets.all(0),
//   });
//   // Margin for the FAB
//   final EdgeInsets margin;

//   /// Distance from children.
//   final double distance;

//   /// Animation duration.
//   final Duration duration;

//   /// Angle of opening when fan type.
//   final double fanAngle;

//   /// Open at initial display.
//   final bool initialOpen;

//   /// The type of behavior of this widget.
//   final ExpandableFabType type;

//   /// The position of the ExpandableFab on the screen
//   final ExpandableFabPos pos;

//   /// A builder for the custom close button.
//   final FloatingActionButtonBuilder? closeButtonBuilder;

//   /// A builder for the custom open button.
//   final FloatingActionButtonBuilder? openButtonBuilder;

//   /// Types of animations for Children.
//   final ExpandableFabAnimation childrenAnimation;

//   /// For positioning of children widgets.
//   final Offset childrenOffset;

//   /// The widgets below this widget in the tree.
//   final List<Widget> children;

//   /// Will be called before opening the menu.
//   final VoidCallback? onOpen;

//   /// Will be called after opening the menu.
//   final VoidCallback? afterOpen;

//   /// Will be called before the menu closes.
//   final VoidCallback? onClose;

//   /// Will be called after the menu closes.
//   final VoidCallback? afterClose;

//   /// Provides the style for overlay. No overlay when null.
//   final ExpandableFabOverlayStyle? overlayStyle;

//   /// Defines how [openButtonBuilder] and [closeButtonBuilder] are aligned in a [Stack].
//   /// Useful when the buttons have different sizes and need specific alignment adjustments.
//   final Alignment openCloseStackAlignment;

//   /// This controls the size of the shadow below the floating action button
//   final double? elevation;

//   /// The state from the closest instance of this class that encloses the given context.
//   static ExpandableFabState of(BuildContext context) {
//     ExpandableFabState? state;
//     if (context is StatefulElement && context.state is ExpandableFabState) {
//       state = context.state as ExpandableFabState;
//     }
//     state = context.findRootAncestorStateOfType<ExpandableFabState>() ?? state;

//     assert(() {
//       if (state == null) {
//         throw FlutterError(
//             'ExpandableFab operation requested with a context that does not include a ExpandableFab.');
//       }
//       return true;
//     }());
//     return state!;
//   }

//   @override
//   State<ExpandableFab> createState() => ExpandableFabState();
// }

// class ExpandableFabState extends State<ExpandableFab>
//     with SingleTickerProviderStateMixin {
//   final _defaultOpenButtonBuilder = RotateFloatingActionButtonBuilder(
//     child: const Icon(Icons.menu),
//   );
//   final _defaultCloseButtonBuilder = DefaultFloatingActionButtonBuilder(
//     fabSize: ExpandableFabSize.small,
//     child: const Icon(Icons.close),
//   );

//   late final AnimationController _controller;
//   late final Animation<double> _expandAnimation;
//   late FloatingActionButtonBuilder _openButtonBuilder =
//       _defaultOpenButtonBuilder;
//   late FloatingActionButtonBuilder _closeButtonBuilder =
//       _defaultCloseButtonBuilder;
//   bool _open = false;

//   /// Returns whether the menu is open
//   bool get isOpen => _open;

//   /// Display or hide the menu.
//   void toggle() {
//     setState(() {
//       _open = !_open;
//       if (_open) {
//         widget.onOpen?.call();
//         _controller.forward().then((value) {
//           widget.afterOpen?.call();
//         });
//       } else {
//         widget.onClose?.call();
//         _controller.reverse().then((value) {
//           widget.afterClose?.call();
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _open = widget.initialOpen;
//     _controller = AnimationController(
//       value: _open ? 1.0 : 0.0,
//       duration: widget.duration,
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       curve: Curves.fastOutSlowIn,
//       reverseCurve: Curves.easeOutQuad,
//       parent: _controller,
//     );
//     if (widget.openButtonBuilder != null) {
//       _openButtonBuilder = widget.openButtonBuilder!;
//     }
//     if (widget.closeButtonBuilder != null) {
//       _closeButtonBuilder = widget.closeButtonBuilder!;
//     }
//   }

//   @override
//   void didUpdateWidget(covariant ExpandableFab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _open = widget.initialOpen;
//     _controller.duration = widget.duration;
//     _openButtonBuilder = widget.openButtonBuilder ?? _defaultOpenButtonBuilder;
//     _closeButtonBuilder =
//         widget.closeButtonBuilder ?? _defaultCloseButtonBuilder;
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final location = ExpandableFab.location as _ExpandableFabLocation;
//     Offset? offset;
//     Widget? cache;
//     final ScaffoldState? scaffold =
//         context.findAncestorStateOfType<ScaffoldState>();

//     return ValueListenableBuilder<ScaffoldPrelayoutGeometry?>(
//       valueListenable: location.scaffoldGeometry,
//       builder: ((context, geometry, child) {
//         if (geometry == null) {
//           if (scaffold == null) {
//             double dx = 0;
//             if (widget.pos == ExpandableFabPos.right) {
//               dx = 16;
//             } else if (widget.pos == ExpandableFabPos.left) {
//               dx = -16;
//             }
//             return _buildButtons(Offset(dx, 16));
//           } else {
//             return const SizedBox.shrink();
//           }
//         }
//         double x = 0;
//         if (widget.pos == ExpandableFabPos.right) {
//           x = kFloatingActionButtonMargin + geometry.minInsets.right;
//         } else if (widget.pos == ExpandableFabPos.left) {
//           x = -kFloatingActionButtonMargin - geometry.minInsets.left;
//         }
//         final bottomContentHeight =
//             geometry.scaffoldSize.height - geometry.contentBottom;
//         final y = kFloatingActionButtonMargin +
//             math.max(geometry.minViewPadding.bottom, bottomContentHeight);
//         if (offset != Offset(x, y)) {
//           offset = Offset(x, y);
//           cache = _buildButtons(offset!);
//         }
//         return _open ? FocusScope(child: cache!) : cache!;
//       }),
//     );
//   }

//   Widget _buildButtons(Offset offset) {
//     final blur = widget.overlayStyle?.blur;
//     final overlayColor = widget.overlayStyle?.color;
//     final adjustedOffset = Offset(
//       offset.dx +
//           (widget.pos == ExpandableFabPos.left
//               ? widget.margin.left
//               : widget.pos == ExpandableFabPos.center
//                   ? 0
//                   : widget.margin.right),
//       offset.dy + widget.margin.bottom,
//     );
//     final Alignment alignment;
//     switch (widget.pos) {
//       case ExpandableFabPos.left:
//         alignment = Alignment.bottomLeft;
//         break;
//       case ExpandableFabPos.center:
//         alignment = Alignment.bottomCenter;
//         break;
//       default:
//         alignment = Alignment.bottomRight;
//     }
//     return GestureDetector(
//       onTap: () => toggle(),
//       child: Stack(
//         alignment: alignment,
//         children: [
//           Container(),
//           if (overlayColor != null)
//             IgnorePointer(
//               ignoring: !_open,
//               child: FadeTransition(
//                 opacity: _expandAnimation,
//                 child: Container(
//                   color: overlayColor,
//                 ),
//               ),
//             ),
//           if (blur != null)
//             IgnorePointer(
//               ignoring: !_open,
//               child: TweenAnimationBuilder<double>(
//                 tween: Tween<double>(
//                   begin: _open ? 0.0 : blur,
//                   end: _open ? blur : 0.0,
//                 ),
//                 duration: widget.duration,
//                 curve: Curves.easeInOut,
//                 builder: (_, value, child) {
//                   if (value < 0.001) {
//                     return child!;
//                   }
//                   return ClipRect(
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
//                       child: child,
//                     ),
//                   );
//                 },
//                 child: Container(color: Colors.transparent),
//               ),
//             ),
//           ..._buildExpandingActionButtons(adjustedOffset),
//           Transform.translate(
//             offset: -adjustedOffset,
//             child: Stack(
//               alignment: widget.openCloseStackAlignment,
//               children: [
//                 FadeTransition(
//                   opacity: _expandAnimation,
//                   child: _closeButtonBuilder.builder(
//                       context, toggle, _expandAnimation),
//                 ),
//                 _buildTapToOpenFab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildExpandingActionButtons(Offset offset) {
//     final children = <Widget>[];
//     final count = widget.children.length;
//     var buttonOffset = 0.0;
//     if (_openButtonBuilder.size > _closeButtonBuilder.size) {
//       buttonOffset = (_openButtonBuilder.size - _closeButtonBuilder.size) / 2;
//     }
//     var totalOffset = offset;
//     switch (widget.pos) {
//       case ExpandableFabPos.left:
//         totalOffset += Offset(-widget.childrenOffset.dx - buttonOffset,
//             widget.childrenOffset.dy + buttonOffset);
//         break;
//       case ExpandableFabPos.center:
//         final screenSize = MediaQuery.of(context).size;
//         totalOffset = Offset(
//             screenSize.width / 2 - _closeButtonBuilder.size / 2,
//             offset.dy + buttonOffset);
//         break;
//       default:
//         totalOffset +=
//             widget.childrenOffset + Offset(buttonOffset, buttonOffset);
//     }
//     for (var i = 0; i < count; i++) {
//       final double dist;
//       double dir;
//       switch (widget.type) {
//         case ExpandableFabType.fan:
//           final half = (90 - widget.fanAngle) / 2;
//           if (count > 1) {
//             dir = widget.fanAngle / (count - 1) * i + half;
//           } else {
//             dir = widget.fanAngle + half;
//           }
//           if (widget.pos == ExpandableFabPos.center) {
//             dir += 45;
//           }
//           dist = widget.distance;
//           break;
//         case ExpandableFabType.up:
//           dir = 90;
//           dist = widget.distance * (i + 1);
//           break;
//         case ExpandableFabType.side:
//           dir = 0;
//           dist = widget.distance * (i + 1);
//           break;
//       }
//       children.add(
//         _ExpandingActionButton(
//           directionInDegrees: dir,
//           maxDistance: dist,
//           progress: _expandAnimation,
//           offset: totalOffset,
//           fabPos: widget.pos,
//           animation: widget.childrenAnimation,
//           child: widget.children[i],
//         ),
//       );
//     }
//     return children;
//   }

//   Widget _buildTapToOpenFab() {
//     final transformValues = _closeButtonBuilder.size / _openButtonBuilder.size;
//     final reverse = ReverseAnimation(_expandAnimation);

//     return IgnorePointer(
//       ignoring: _open,
//       child: ScaleTransition(
//         scale: Tween(begin: transformValues, end: 1.0).animate(reverse),
//         child: FadeTransition(
//           opacity: reverse,
//           child: _openButtonBuilder.builder(context, toggle, _expandAnimation),
//         ),
//       ),
//     );
//   }
// }

// class _ExpandableFabLocation extends StandardFabLocation {
//   final ValueNotifier<ScaffoldPrelayoutGeometry?> scaffoldGeometry =
//       ValueNotifier(null);

//   @override
//   double getOffsetX(
//       ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
//     Future.microtask(() {
//       this.scaffoldGeometry.value = scaffoldGeometry;
//     });
//     return 0;
//   }

//   @override
//   double getOffsetY(
//       ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
//     return -scaffoldGeometry.snackBarSize.height;
//   }
// }

// @immutable
// class _ExpandingActionButton extends StatelessWidget {
//   const _ExpandingActionButton({
//     required this.directionInDegrees,
//     required this.maxDistance,
//     required this.progress,
//     required this.child,
//     required this.fabPos,
//     required this.offset,
//     required this.animation,
//   });

//   final double directionInDegrees;
//   final double maxDistance;
//   final Animation<double> progress;
//   final Offset offset;
//   final ExpandableFabPos fabPos;
//   final Widget child;
//   final ExpandableFabAnimation animation;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: progress,
//       builder: (context, child) {
//         final pos = Offset.fromDirection(
//           directionInDegrees * (math.pi / 180.0),
//           progress.value * maxDistance,
//         );
//         return Positioned(
//           right: fabPos == ExpandableFabPos.left ? null : offset.dx + pos.dx,
//           left: fabPos == ExpandableFabPos.left ? -offset.dx + pos.dx : null,
//           bottom: offset.dy + pos.dy,
//           child: Transform.rotate(
//             angle: animation == ExpandableFabAnimation.rotate
//                 ? (1.0 - progress.value) * math.pi / 2
//                 : 0,
//             child: IgnorePointer(
//               ignoring: progress.value != 1,
//               child: child,
//             ),
//           ),
//         );
//       },
//       child: FadeTransition(
//         opacity: progress,
//         child: child,
//       ),
//     );
//   }
// }
