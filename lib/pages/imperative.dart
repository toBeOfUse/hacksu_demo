import 'dart:math';

import 'package:flutter/material.dart';

enum WeaponOption { sword, boomerang, bow }

enum ColorOption { green, blue, purple, red }

class CharacterControl extends StatelessWidget {
  final String name;
  final Widget controller;
  const CharacterControl(
      {required this.name, required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text(name), controller],
      ),
    );
  }
}

class Explosion extends StatefulWidget {
  const Explosion({Key? key}) : super(key: key);

  @override
  State<Explosion> createState() => _ExplosionState();
}

/// Needed to force the GIF to start over by evicting it from the cache after use
/// https://github.com/flutter/flutter/issues/51775#issuecomment-680997795
class _ExplosionState extends State<Explosion> {
  AssetImage? explosion;
  static const gifPath = "assets/explosion.gif";

  @override
  void initState() {
    super.initState();
    explosion = AssetImage(gifPath);
  }

  @override
  void dispose() {
    explosion?.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: explosion ?? AssetImage(gifPath),
      filterQuality: FilterQuality.none,
      fit: BoxFit.contain,
    );
  }
}

class CharacterScene extends StatefulWidget {
  final bool simulatingImperative;
  const CharacterScene({required this.simulatingImperative, Key? key})
      : super(key: key);

  @override
  State<CharacterScene> createState() => _CharacterSceneState();
}

class _CharacterSceneState extends State<CharacterScene> {
  double characterHeight = 1.0;
  ColorOption color = ColorOption.green;
  WeaponOption currentWeapon = WeaponOption.sword;
  Offset? normalizedWeaponPosition;
  bool ears = false;
  bool exploding = false;

  static const initialCharacterFractionalHeight = 0.5;
  static const characterAspectRatio = 400 / 890;
  static const weaponPosWithinCharacter = Offset(312 / 400, 496 / 890);
  static const originWithinWeapon = Offset(462 / 774, 227 / 737);
  static const weaponFractionalHeight = 0.2;
  static const explosionLengthMs = 1800;

  double get characterFractionalHeight {
    return initialCharacterFractionalHeight * characterHeight;
  }

  void causeExplosion([void Function()? stateMutation]) async {
    if (widget.simulatingImperative || exploding) {
      if (stateMutation != null) {
        setState(stateMutation);
      }
      return;
    }
    setState(() {
      exploding = true;
    });
    await Future.delayed(
        Duration(milliseconds: (explosionLengthMs / 2).round()));
    if (stateMutation != null) {
      setState(stateMutation);
    }
    await Future.delayed(
        Duration(milliseconds: (explosionLengthMs / 2).round()));
    setState(() {
      exploding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isScreenWide = MediaQuery.of(context).size.width >= 800;
    return Column(
      children: [
        Flex(
          direction: isScreenWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              CharacterControl(
                name: "Weapon",
                controller: DropdownButton(
                  value: currentWeapon,
                  items: [
                    for (final weapon in WeaponOption.values)
                      DropdownMenuItem(value: weapon, child: Text(weapon.name))
                  ],
                  onChanged: (WeaponOption? newWeapon) {
                    if (newWeapon != null) {
                      causeExplosion(() {
                        currentWeapon = newWeapon;
                        normalizedWeaponPosition = null;
                      });
                    }
                  },
                ),
              ),
              CharacterControl(
                name: "Height",
                controller: Slider(
                  value: characterHeight,
                  min: 0.5,
                  max: 1.75,
                  onChanged: (newValue) {
                    setState(
                      () {
                        characterHeight = newValue;
                      },
                    );
                    causeExplosion();
                  },
                ),
              ),
            ]),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CharacterControl(
                  name: "Color",
                  controller: DropdownButton(
                      value: color,
                      items: [
                        for (final colorOption in ColorOption.values)
                          DropdownMenuItem(
                            value: colorOption,
                            child: Text(colorOption.name),
                          )
                      ],
                      onChanged: (ColorOption? newValue) {
                        if (newValue != null) {
                          causeExplosion(() {
                            color = newValue;
                          });
                        }
                      }),
                ),
                CharacterControl(
                  name: "The Cat Ears",
                  controller: Checkbox(
                      value: ears,
                      onChanged: (newValue) {
                        causeExplosion(() {
                          if (newValue != null) {
                            ears = newValue;
                          }
                        });
                      }),
                )
              ],
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // this is messy - if i was trying to develop a real positioning
              // system I'd create like a `Sprite` class to store/calculate
              // sizes and positions for all these different images
              final characterHeightPx =
                  characterFractionalHeight * constraints.maxHeight;
              final characterWidthPx = characterHeightPx * characterAspectRatio;
              final characterLeftEdge =
                  constraints.maxWidth / 2 - characterWidthPx / 2;
              final characterTopEdge =
                  constraints.maxHeight - characterHeightPx;
              final defaultWeaponOriginWithinCharacter = Offset(
                  characterLeftEdge +
                      characterWidthPx * weaponPosWithinCharacter.dx,
                  characterTopEdge +
                      characterHeightPx * weaponPosWithinCharacter.dy);
              final weaponSizePx =
                  weaponFractionalHeight * constraints.maxHeight;
              final defaultWeaponPosWithinCharacter = Offset(
                defaultWeaponOriginWithinCharacter.dx -
                    weaponSizePx * originWithinWeapon.dx,
                defaultWeaponOriginWithinCharacter.dy -
                    weaponSizePx * originWithinWeapon.dy,
              );
              late final Offset actualWeaponPosPx;
              if (normalizedWeaponPosition == null ||
                  !widget.simulatingImperative) {
                actualWeaponPosPx = defaultWeaponPosWithinCharacter;
                normalizedWeaponPosition = actualWeaponPosPx.scale(
                    1 / constraints.maxWidth, 1 / constraints.maxHeight);
              } else {
                actualWeaponPosPx = normalizedWeaponPosition!
                    .scale(constraints.maxWidth, constraints.maxHeight);
              }
              final explosionHeight = constraints.maxHeight * 0.9;
              final explosionTop = constraints.maxHeight * 0.1;
              final explosionWidth = explosionHeight * (224 / 254);
              final explosionLeft =
                  constraints.maxWidth / 2 - explosionWidth / 2;
              return Stack(
                children: [
                  Center(
                    child: Image.asset("assets/forest.jpg"),
                  ),
                  if (ears)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: characterFractionalHeight,
                        child: Image.asset(
                          color == ColorOption.blue
                              ? "assets/blueears.png"
                              : "assets/ears.png",
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: characterFractionalHeight,
                      child: Image.asset(
                        "assets/${color.name}link.png",
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  Positioned(
                    left: actualWeaponPosPx.dx,
                    top: actualWeaponPosPx.dy,
                    height: weaponSizePx,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        if (!widget.simulatingImperative) return;
                        setState(() {
                          normalizedWeaponPosition = normalizedWeaponPosition! +
                              Offset(details.delta.dx / constraints.maxWidth,
                                  details.delta.dy / constraints.maxHeight);
                          normalizedWeaponPosition = Offset(
                              normalizedWeaponPosition!.dx.clamp(0, 1),
                              normalizedWeaponPosition!.dy.clamp(0, 1));
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: widget.simulatingImperative ? 250 : 0,
                        ),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin:
                                Offset(Random().nextBool() ? -1.0 : 1.0, 0.0),
                            end: Offset(0.0, 0.0),
                          ).animate(
                            animation,
                          );
                          return ClipRect(
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          "assets/aligned${currentWeapon.name}.png",
                          key: ValueKey(currentWeapon.name),
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  ),
                  if (exploding)
                    Positioned(
                      top: explosionTop,
                      height: explosionHeight,
                      width: explosionWidth,
                      left: explosionLeft,
                      child: Explosion(),
                    )
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
