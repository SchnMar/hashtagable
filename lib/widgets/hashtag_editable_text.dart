import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hashtagable/composer/composer.dart';
import 'package:hashtagable/detector/detector.dart';

/// Show decorated tagged text while user is inputting text.
///
/// [decoratedStyle] is textStyle of tagged text.
/// [basicStyle] is textStyle of others.
/// EditableText which decorates the contents start with "#"
class HashTagEditableText extends EditableText {
  HashTagEditableText({
    Key key,
    FocusNode focusNode,
    @required TextEditingController controller,
    @required TextStyle basicStyle,
    @required this.decoratedStyle,
    @required Color cursorColor,
    this.onDetectionTyped,
    this.onDetectionFinished,
    this.decorateAtSign,
    ValueChanged<String> onChanged,
    ValueChanged<String> onSubmitted,
    int maxLines,
    int minLines,
    TextInputType keyboardType,
    bool autofocus,
    bool obscureText = false,
    bool readOnly = false,
    bool forceLine = true,
    ToolbarOptions toolbarOptions = const ToolbarOptions(
      copy: true,
      cut: true,
      paste: true,
      selectAll: true,
    ),
    bool autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    StrutStyle strutStyle,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Locale locale,
    double textScaleFactor,
    bool expands = false,
    Color selectionColor,
    TextSelectionControls selectionControls,
    TextInputAction textInputAction,
    VoidCallback onEditingComplete,
    SelectionChangedCallback onSelectionChanged,
    VoidCallback onSelectionHandleTapped,
    List<TextInputFormatter> inputFormatters,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    bool cursorOpacityAnimates = false,
    Offset cursorOffset,
    bool paintCursorAboveText = false,
    BoxHeightStyle selectionHeightStyle = BoxHeightStyle.tight,
    BoxWidthStyle selectionWidthStyle = BoxWidthStyle.tight,
    Brightness keyboardAppearance = Brightness.light,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController scrollController,
    ScrollPhysics scrollPhysics,
    bool showCursor,
    bool showSelectionHandles = false,
    bool rendererIgnoresPointer = true,
    Color backgroundCursorColor = CupertinoColors.inactiveGray,
    bool enableInteractiveSelection = true,
  }) : super(
          key: key,
          focusNode: (focusNode) ?? FocusNode(),
          controller: controller,
          cursorColor: cursorColor,
          style: basicStyle,
          keyboardType: (keyboardType) ?? TextInputType.text,
          autofocus: (autofocus) ?? false,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          backgroundCursorColor: backgroundCursorColor,
          maxLines: maxLines,
          minLines: minLines,
          obscureText: obscureText,
          readOnly: readOnly,
          forceLine: forceLine,
          toolbarOptions: toolbarOptions,
          autocorrect: autocorrect ?? false,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          enableSuggestions: enableSuggestions ?? false,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          textCapitalization: textCapitalization,
          locale: locale,
          textScaleFactor: textScaleFactor,
          expands: expands,
          selectionColor: selectionColor,
          selectionControls: selectionControls,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          onSelectionChanged: onSelectionChanged,
          onSelectionHandleTapped: onSelectionHandleTapped,
          inputFormatters: inputFormatters,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorOpacityAnimates: cursorOpacityAnimates,
          cursorOffset: cursorOffset,
          paintCursorAboveText: paintCursorAboveText,
          selectionHeightStyle: selectionHeightStyle,
          selectionWidthStyle: selectionWidthStyle,
          keyboardAppearance: keyboardAppearance,
          scrollPadding: scrollPadding,
          dragStartBehavior: dragStartBehavior,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
          showCursor: showCursor,
          showSelectionHandles: showSelectionHandles,
          rendererIgnoresPointer: rendererIgnoresPointer,
          enableInteractiveSelection: enableInteractiveSelection,
        );

  final ValueChanged<String> onDetectionTyped;

  final VoidCallback onDetectionFinished;

  final TextStyle decoratedStyle;

  final decorateAtSign;

  @override
  HashTagEditableTextState createState() => HashTagEditableTextState();
}

/// State of [HashTagEditableText]
///
/// Return decorated tagged text by using functions in [Detector]
class HashTagEditableTextState extends EditableTextState {
  @override
  HashTagEditableText get widget => super.widget;

  Detector detector;

  Detection prevTypingDetection;

  @override
  void initState() {
    super.initState();
    detector = Detector(
        textStyle: widget.style,
        decoratedStyle: widget.decoratedStyle,
        decorateAtSign: widget.decorateAtSign);
  }

  @override
  TextSpan buildTextSpan() {
    final detections = detector.getDetections(textEditingValue.text);
    final composer = Composer(
      selection: textEditingValue?.selection?.start ?? -1,
      onDetectionTyped: widget.onDetectionTyped,
      sourceText: textEditingValue.text,
      decoratedStyle: widget.decoratedStyle,
      detections: detections,
      composing: textEditingValue.composing,
    );

    final typingDetection = composer.typingDetection();
    if (prevTypingDetection != null && typingDetection == null) {
      widget.onDetectionFinished?.call();
    }

    prevTypingDetection = typingDetection;
    if (detections.isEmpty) {
      /// use same method as default textField to show composing underline
      return widget.controller.buildTextSpan(
        style: widget.style,
        withComposing: !widget.readOnly,
      );
    } else {
      /// use [Composer] to show composing underline
      detections.sort();
      if (widget.onDetectionTyped != null) {
        composer.callOnDetectionTyped();
      }
      return composer.getComposedTextSpan();
    }
  }
}
