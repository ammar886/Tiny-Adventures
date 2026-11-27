import 'package:flutter/material.dart';
import 'package:tiny_adventures/domain/models/animal_item.dart';

/// Offline catalog of the six toddler-friendly animal friends.
class AnimalCatalog {
  AnimalCatalog._();

  static const List<AnimalItem> all = <AnimalItem>[
    AnimalItem(
      id: AnimalId.dog,
      name: 'Dog',
      soundText: 'Woof!',
      audioAsset: 'audio/dog.wav',
      cardColor: Color(0xFFFFE5CC),
      accentColor: Color(0xFFD98448),
    ),
    AnimalItem(
      id: AnimalId.cat,
      name: 'Cat',
      soundText: 'Meow!',
      audioAsset: 'audio/cat.wav',
      cardColor: Color(0xFFFCE2EE),
      accentColor: Color(0xFFD16D9B),
    ),
    AnimalItem(
      id: AnimalId.cow,
      name: 'Cow',
      soundText: 'Moo!',
      audioAsset: 'audio/cow.wav',
      cardColor: Color(0xFFE3F2D3),
      accentColor: Color(0xFF6A9F52),
    ),
    AnimalItem(
      id: AnimalId.duck,
      name: 'Duck',
      soundText: 'Quack!',
      audioAsset: 'audio/duck.wav',
      cardColor: Color(0xFFFFF0B8),
      accentColor: Color(0xFFD49E2A),
    ),
    AnimalItem(
      id: AnimalId.lion,
      name: 'Lion',
      soundText: 'Roar!',
      audioAsset: 'audio/lion.wav',
      cardColor: Color(0xFFFFDFB8),
      accentColor: Color(0xFFC97B2E),
    ),
    AnimalItem(
      id: AnimalId.elephant,
      name: 'Elephant',
      soundText: 'Pawoo!',
      audioAsset: 'audio/elephant.wav',
      cardColor: Color(0xFFD7ECFF),
      accentColor: Color(0xFF5492C7),
    ),
  ];
}
