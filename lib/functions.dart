import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';

import 'decorator/decorator.dart';

/// Check if the text has hashTags
bool hasHashTags(String value) {
  final decoratedTextColor = Colors.blue;
  final decorator = Decorator(
      textStyle: TextStyle(),
      decoratedStyle: TextStyle(color: decoratedTextColor));
  final result = decorator.getDecorations(value);
  final taggedDecorations = result
      .where((decoration) => decoration.style.color == decoratedTextColor)
      .toList();
  return taggedDecorations.isNotEmpty;
}

/// Extract hashTags from the text
List<String> extractHashTags(String value) {
  final decoratedTextColor = Colors.blue;
  final decorator = Decorator(
      textStyle: TextStyle(),
      decoratedStyle: TextStyle(color: decoratedTextColor));
  final decorations = decorator.getDecorations(value);
  final taggedDecorations = decorations
      .where((decoration) => decoration.style.color == decoratedTextColor)
      .toList();
  final result = taggedDecorations.map((decoration) {
    final text = decoration.range.textInside(value);
    return text.trim();
  }).toList();
  return result;
}

/// Returns textSpan with decorated tagged text
///
/// Used in [HashTagText]
TextSpan getHashTagTextSpan({
  @required TextStyle decoratedStyle,
  @required TextStyle basicStyle,
  @required String source,
  @required Function(String) onTap,
  bool decorateAtSign = false,
  List<InlineSpan> children,
}) {
  final decorations = Decorator(
          decoratedStyle: decoratedStyle,
          textStyle: basicStyle,
          decorateAtSign: decorateAtSign)
      .getDecorations(source);
  if (decorations.isEmpty) {
    List<TextSpan> span = List<TextSpan>();

    span.add(TextSpan(text: source, style: basicStyle));
    if (children != null) {
      span.add(
        TextSpan(text: ' '),
      );

      for (var child in children) {
        span.add(child);
      }
    }
    return TextSpan(children: span);
  } else {
    decorations.sort();
    final span = decorations
        .asMap()
        .map(
          (index, item) {
            final recognizer = TapGestureRecognizer()
              ..onTap = () {
                final decoration = decorations[index];
                if (decoration.style == decoratedStyle) {
                  onTap(decoration.range.textInside(source).trim());
                }
              };
            return MapEntry(
              index,
              TextSpan(
                style: item.style,
                text: item.range.textInside(source),
                recognizer: (onTap == null) ? null : recognizer,
              ),
            );
          },
        )
        .values
        .toList();

    if (children != null) {
      span.add(
        TextSpan(text: ' '),
      );
      for (var child in children) {
        span.add(child);
      }
    }
    return TextSpan(children: span);
  }
}
