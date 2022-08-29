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

class CharacterScene extends StatefulWidget {
  const CharacterScene({Key? key}) : super(key: key);

  @override
  State<CharacterScene> createState() => _CharacterSceneState();
}

class _CharacterSceneState extends State<CharacterScene> {
  double characterHeight = 1.0;
  ColorOption color = ColorOption.green;
  WeaponOption currentWeapon = WeaponOption.sword;
  Offset? normalizedWeaponPosition;

  static const initialCharacterFractionalHeight = 0.5;
  static const characterAspectRatio = 400 / 872;
  static const weaponPosWithinCharacter = Offset(312 / 400, 478 / 872);
  static const originWithinWeapon = Offset(462 / 774, 227 / 737);
  static const weaponFractionalHeight = 0.2;

  double get characterFractionalHeight {
    return initialCharacterFractionalHeight * characterHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    setState(() {
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
                  max: 1.5,
                  onChanged: (newValue) {
                    setState(
                      () {
                        characterHeight = newValue;
                      },
                    );
                  }),
            ),
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
                        setState(() {
                          color = newValue;
                        });
                      }
                    }))
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
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
              if (normalizedWeaponPosition == null) {
                actualWeaponPosPx = defaultWeaponPosWithinCharacter;
                normalizedWeaponPosition = actualWeaponPosPx.scale(
                    1 / constraints.maxWidth, 1 / constraints.maxHeight);
              } else {
                actualWeaponPosPx = normalizedWeaponPosition!
                    .scale(constraints.maxWidth, constraints.maxHeight);
              }
              return Stack(
                children: [
                  Center(
                    child: Image.asset("assets/forest.jpg"),
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
                        duration: Duration(milliseconds: 250),
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
