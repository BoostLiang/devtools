// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'dart_ui.dart';

/// Whether to slant the glyphs in the font
enum FontStyle {
  /// Use the upright glyphs
  normal,

  /// Use glyphs designed for slanting
  italic,
}

/// The thickness of the glyphs used to draw the text
class FontWeight {
  const FontWeight._(this.index);

  /// The encoded integer value of this font weight.
  final int index;

  /// Thin, the least thick
  static const FontWeight w100 = FontWeight._(0);

  /// Extra-light
  static const FontWeight w200 = FontWeight._(1);

  /// Light
  static const FontWeight w300 = FontWeight._(2);

  /// Normal / regular / plain
  static const FontWeight w400 = FontWeight._(3);

  /// Medium
  static const FontWeight w500 = FontWeight._(4);

  /// Semi-bold
  static const FontWeight w600 = FontWeight._(5);

  /// Bold
  static const FontWeight w700 = FontWeight._(6);

  /// Extra-bold
  static const FontWeight w800 = FontWeight._(7);

  /// Black, the most thick
  static const FontWeight w900 = FontWeight._(8);

  /// The default font weight.
  static const FontWeight normal = w400;

  /// A commonly used font weight that is heavier than normal.
  static const FontWeight bold = w700;

  /// A list of all the font weights.
  static const List<FontWeight> values = <FontWeight>[
    w100,
    w200,
    w300,
    w400,
    w500,
    w600,
    w700,
    w800,
    w900
  ];

  /// Linearly interpolates between two font weights.
  ///
  /// Rather than using fractional weights, the interpolation rounds to the
  /// nearest weight.
  ///
  /// Any null values for `a` or `b` are interpreted as equivalent to [normal]
  /// (also known as [w400]).
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]). The result
  /// is clamped to the range [w100]–[w900].
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static FontWeight lerp(FontWeight a, FontWeight b, double t) {
    assert(t != null);
    return values[
        lerpDouble(a?.index ?? normal.index, b?.index ?? normal.index, t)
            .round()
            .clamp(0, 8)];
  }

  @override
  String toString() {
    return const <int, String>{
      0: 'FontWeight.w100',
      1: 'FontWeight.w200',
      2: 'FontWeight.w300',
      3: 'FontWeight.w400',
      4: 'FontWeight.w500',
      5: 'FontWeight.w600',
      6: 'FontWeight.w700',
      7: 'FontWeight.w800',
      8: 'FontWeight.w900',
    }[index];
  }
}

/// Whether and how to align text horizontally.
// The order of this enum must match the order of the values in RenderStyleConstants.h's ETextAlign.
enum TextAlign {
  /// Align the text on the left edge of the container.
  left,

  /// Align the text on the right edge of the container.
  right,

  /// Align the text in the center of the container.
  center,

  /// Stretch lines of text that end with a soft line break to fill the width of
  /// the container.
  ///
  /// Lines that end with hard line breaks are aligned towards the [start] edge.
  justify,

  /// Align the text on the leading edge of the container.
  ///
  /// For left-to-right text ([TextDirection.ltr]), this is the left edge.
  ///
  /// For right-to-left text ([TextDirection.rtl]), this is the right edge.
  start,

  /// Align the text on the trailing edge of the container.
  ///
  /// For left-to-right text ([TextDirection.ltr]), this is the right edge.
  ///
  /// For right-to-left text ([TextDirection.rtl]), this is the left edge.
  end,
}

/// A horizontal line used for aligning text.
enum TextBaseline {
  /// The horizontal line used to align the bottom of glyphs for alphabetic characters.
  alphabetic,

  /// The horizontal line used to align ideographic characters.
  ideographic,
}

/// A linear decoration to draw near the text.
class TextDecoration {
  const TextDecoration._(this._mask);

  /// Creates a decoration that paints the union of all the given decorations.
  factory TextDecoration.combine(List<TextDecoration> decorations) {
    int mask = 0;
    for (TextDecoration decoration in decorations) mask |= decoration._mask;
    return new TextDecoration._(mask);
  }

  final int _mask;

  /// Whether this decoration will paint at least as much decoration as the given decoration.
  bool contains(TextDecoration other) {
    return (_mask | other._mask) == _mask;
  }

  /// Do not draw a decoration
  static const TextDecoration none = TextDecoration._(0x0);

  /// Draw a line underneath each line of text
  static const TextDecoration underline = TextDecoration._(0x1);

  /// Draw a line above each line of text
  static const TextDecoration overline = TextDecoration._(0x2);

  /// Draw a line through each line of text
  static const TextDecoration lineThrough = TextDecoration._(0x4);

  @override
  bool operator ==(dynamic other) {
    if (other is! TextDecoration) return false;
    final TextDecoration typedOther = other;
    return _mask == typedOther._mask;
  }

  @override
  int get hashCode => _mask.hashCode;

  @override
  String toString() {
    if (_mask == 0) return 'TextDecoration.none';
    final List<String> values = <String>[];
    if (_mask & underline._mask != 0) values.add('underline');
    if (_mask & overline._mask != 0) values.add('overline');
    if (_mask & lineThrough._mask != 0) values.add('lineThrough');
    if (values.length == 1) return 'TextDecoration.${values[0]}';
    return 'TextDecoration.combine([${values.join(", ")}])';
  }
}

/// The style in which to draw a text decoration
enum TextDecorationStyle {
  /// Draw a solid line
  solid,

  /// Draw two lines
  double,

  /// Draw a dotted line
  dotted,

  /// Draw a dashed line
  dashed,

  /// Draw a sinusoidal line
  wavy
}

/// An opaque object that determines the size, position, and rendering of text.
class TextStyle {
  /// Creates a new TextStyle object.
  ///
  /// * `color`: The color to use when painting the text. If this is specified, `foreground` must be null.
  /// * `decoration`: The decorations to paint near the text (e.g., an underline).
  /// * `decorationColor`: The color in which to paint the text decorations.
  /// * `decorationStyle`: The style in which to paint the text decorations (e.g., dashed).
  /// * `fontWeight`: The typeface thickness to use when painting the text (e.g., bold).
  /// * `fontStyle`: The typeface variant to use when drawing the letters (e.g., italics).
  /// * `fontFamily`: The name of the font to use when painting the text (e.g., Roboto).
  /// * `fontSize`: The size of glyphs (in logical pixels) to use when painting the text.
  /// * `letterSpacing`: The amount of space (in logical pixels) to add between each letter.
  /// * `wordSpacing`: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between each word).
  /// * `textBaseline`: The common baseline that should be aligned between this text span and its parent text span, or, for the root text spans, with the line box.
  /// * `height`: The height of this text span, as a multiple of the font size.
  /// * `locale`: The locale used to select region-specific glyphs.
  TextStyle({
    Color color,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    FontWeight fontWeight,
    FontStyle fontStyle,
    TextBaseline textBaseline,
    String fontFamily,
    double fontSize,
    double letterSpacing,
    double wordSpacing,
    double height,
  })  : _fontFamily = fontFamily ?? '',
        _fontSize = fontSize,
        _letterSpacing = letterSpacing,
        _wordSpacing = wordSpacing,
        _height = height,
        _encoded = _encodeTextStyle(
          color,
          decoration,
          decorationColor,
          decorationStyle,
          fontWeight,
          fontStyle,
          textBaseline,
          fontFamily,
          fontSize,
          letterSpacing,
          wordSpacing,
          height,
        );

  final Int32List _encoded;
  final String _fontFamily;
  final double _fontSize;
  final double _letterSpacing;
  final double _wordSpacing;
  final double _height;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! TextStyle) return false;
    final TextStyle typedOther = other;
    if (_fontFamily != typedOther._fontFamily ||
        _fontSize != typedOther._fontSize ||
        _letterSpacing != typedOther._letterSpacing ||
        _wordSpacing != typedOther._wordSpacing ||
        _height != typedOther._height) return false;
    for (int index = 0; index < _encoded.length; index += 1) {
      if (_encoded[index] != typedOther._encoded[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => hashValues(hashList(_encoded), _fontFamily, _fontSize,
      _letterSpacing, _wordSpacing, _height);

  @override
  String toString() {
    return 'UITextStyle('
        'color: ${_encoded[0] & 0x00002 == 0x00002 ? new Color(_encoded[1]) : "unspecified"}, '
        'decoration: ${_encoded[0] & 0x00004 == 0x00004 ? new TextDecoration._(_encoded[2]) : "unspecified"}, '
        'decorationColor: ${_encoded[0] & 0x00008 == 0x00008 ? new Color(_encoded[3]) : "unspecified"}, '
        'decorationStyle: ${_encoded[0] & 0x00010 == 0x00010 ? TextDecorationStyle.values[_encoded[4]] : "unspecified"}, '
        'fontWeight: ${_encoded[0] & 0x00020 == 0x00020 ? FontWeight.values[_encoded[5]] : "unspecified"}, '
        'fontStyle: ${_encoded[0] & 0x00040 == 0x00040 ? FontStyle.values[_encoded[6]] : "unspecified"}, '
        'textBaseline: ${_encoded[0] & 0x00080 == 0x00080 ? TextBaseline.values[_encoded[7]] : "unspecified"}, '
        'fontFamily: ${_encoded[0] & 0x00100 == 0x00100 ? _fontFamily : "unspecified"}, '
        'fontSize: ${_encoded[0] & 0x00200 == 0x00200 ? _fontSize : "unspecified"}, '
        'letterSpacing: ${_encoded[0] & 0x00400 == 0x00400 ? "${_letterSpacing}x" : "unspecified"}, '
        'wordSpacing: ${_encoded[0] & 0x00800 == 0x00800 ? "${_wordSpacing}x" : "unspecified"}, '
        'height: ${_encoded[0] & 0x01000 == 0x01000 ? "${_height}x" : "unspecified"}, '
        ')';
  }
}

// This encoding must match the C++ version ParagraphBuilder::build.
//
// The encoded array buffer has 5 elements.
//
//  - Element 0: A bit mask indicating which fields are non-null.
//    Bit 0 is unused. Bits 1-n are set if the corresponding index in the
//    encoded array is non-null.  The remaining bits represent fields that
//    are passed separately from the array.
//
//  - Element 1: The enum index of the |textAlign|.
//
//  - Element 2: The index of the |fontWeight|.
//
//  - Element 3: The enum index of the |fontStyle|.
//
//  - Element 4: The value of |maxLines|.
//
Int32List _encodeParagraphStyle(
  TextAlign textAlign,
  TextDirection textDirection,
  FontWeight fontWeight,
  FontStyle fontStyle,
  int maxLines,
  String fontFamily,
  double fontSize,
  double lineHeight,
  String ellipsis,
) {
  final Int32List result = new Int32List(6); // also update paragraph_builder.cc
  if (textAlign != null) {
    result[0] |= 1 << 1;
    result[1] = textAlign.index;
  }
  if (textDirection != null) {
    result[0] |= 1 << 2;
    result[2] = textDirection.index;
  }
  if (fontWeight != null) {
    result[0] |= 1 << 3;
    result[3] = fontWeight.index;
  }
  if (fontStyle != null) {
    result[0] |= 1 << 4;
    result[4] = fontStyle.index;
  }
  if (maxLines != null) {
    result[0] |= 1 << 5;
    result[5] = maxLines;
  }
  if (fontFamily != null) {
    result[0] |= 1 << 6;
    // Passed separately to native.
  }
  if (fontSize != null) {
    result[0] |= 1 << 7;
    // Passed separately to native.
  }
  if (lineHeight != null) {
    result[0] |= 1 << 8;
    // Passed separately to native.
  }
  if (ellipsis != null) {
    result[0] |= 1 << 9;
    // Passed separately to native.
  }
  return result;
}

/// An opaque object that determines the configuration used by
/// [ParagraphBuilder] to position lines within a [Paragraph] of text.
class ParagraphStyle {
  /// Creates a new ParagraphStyle object.
  ///
  /// * `textAlign`: The alignment of the text within the lines of the
  ///   paragraph. If the last line is ellipsized (see `ellipsis` below), the
  ///   alignment is applied to that line after it has been truncated but before
  ///   the ellipsis has been added.
  //   See: https://github.com/flutter/flutter/issues/9819
  ///
  /// * `textDirection`: The directionality of the text, left-to-right (e.g.
  ///   Norwegian) or right-to-left (e.g. Hebrew). This controls the overall
  ///   directionality of the paragraph, as well as the meaning of
  ///   [TextAlign.start] and [TextAlign.end] in the `textAlign` field.
  ///
  /// * `fontWeight`: The typeface thickness to use when painting the text
  ///   (e.g., bold).
  ///
  /// * `fontStyle`: The typeface variant to use when drawing the letters (e.g.,
  ///   italics).
  ///
  /// * `maxLines`: The maximum number of lines painted. Lines beyond this
  ///   number are silently dropped. For example, if `maxLines` is 1, then only
  ///   one line is rendered. If `maxLines` is null, but `ellipsis` is not null,
  ///   then lines after the first one that overflows the width constraints are
  ///   dropped. The width constraints are those set in the
  ///   [ParagraphConstraints] object passed to the [Paragraph.layout] method.
  ///
  /// * `fontFamily`: The name of the font to use when painting the text (e.g.,
  ///   Roboto).
  ///
  /// * `fontSize`: The size of glyphs (in logical pixels) to use when painting
  ///   the text.
  ///
  /// * `lineHeight`: The minimum height of the line boxes, as a multiple of the
  ///   font size.
  ///
  /// * `ellipsis`: String used to ellipsize overflowing text. If `maxLines` is
  ///   not null, then the `ellipsis`, if any, is applied to the last rendered
  ///   line, if that line overflows the width constraints. If `maxLines` is
  ///   null, then the `ellipsis` is applied to the first line that overflows
  ///   the width constraints, and subsequent lines are dropped. The width
  ///   constraints are those set in the [ParagraphConstraints] object passed to
  ///   the [Paragraph.layout] method. The empty string and the null value are
  ///   considered equivalent and turn off this behavior.
  ///
  /// * `locale`: The locale used to select region-specific glyphs.
  ParagraphStyle({
    TextAlign textAlign,
    TextDirection textDirection,
    FontWeight fontWeight,
    FontStyle fontStyle,
    int maxLines,
    String fontFamily,
    double fontSize,
    double lineHeight,
    String ellipsis,
  })  : _encoded = _encodeParagraphStyle(
          textAlign,
          textDirection,
          fontWeight,
          fontStyle,
          maxLines,
          fontFamily,
          fontSize,
          lineHeight,
          ellipsis,
        ),
        _fontFamily = fontFamily,
        _fontSize = fontSize,
        _lineHeight = lineHeight,
        _ellipsis = ellipsis;

  final Int32List _encoded;
  final String _fontFamily;
  final double _fontSize;
  final double _lineHeight;
  final String _ellipsis;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ParagraphStyle typedOther = other;
    if (_fontFamily != typedOther._fontFamily ||
        _fontSize != typedOther._fontSize ||
        _lineHeight != typedOther._lineHeight ||
        _ellipsis != typedOther._ellipsis) return false;
    for (int index = 0; index < _encoded.length; index += 1) {
      if (_encoded[index] != typedOther._encoded[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => hashValues(
      hashList(_encoded), _fontFamily, _fontSize, _lineHeight, _ellipsis);

  @override
  String toString() {
    return '$runtimeType('
        'textAlign: ${_encoded[0] & 0x002 == 0x002 ? TextAlign.values[_encoded[1]] : "unspecified"}, '
        'textDirection: ${_encoded[0] & 0x004 == 0x004 ? TextDirection.values[_encoded[2]] : "unspecified"}, '
        'fontWeight: ${_encoded[0] & 0x008 == 0x008 ? FontWeight.values[_encoded[3]] : "unspecified"}, '
        'fontStyle: ${_encoded[0] & 0x010 == 0x010 ? FontStyle.values[_encoded[4]] : "unspecified"}, '
        'maxLines: ${_encoded[0] & 0x020 == 0x020 ? _encoded[5] : "unspecified"}, '
        'fontFamily: ${_encoded[0] & 0x040 == 0x040 ? _fontFamily : "unspecified"}, '
        'fontSize: ${_encoded[0] & 0x080 == 0x080 ? _fontSize : "unspecified"}, '
        'lineHeight: ${_encoded[0] & 0x100 == 0x100 ? "${_lineHeight}x" : "unspecified"}, '
        'ellipsis: ${_encoded[0] & 0x200 == 0x200 ? "\"$_ellipsis\"" : "unspecified"}, '
        ')';
  }
}

/// A direction in which text flows.
///
/// Some languages are written from the left to the right (for example, English,
/// Tamil, or Chinese), while others are written from the right to the left (for
/// example Aramaic, Hebrew, or Urdu). Some are also written in a mixture, for
/// example Arabic is mostly written right-to-left, with numerals written
/// left-to-right.
///
/// The text direction must be provided to APIs that render text or lay out
/// boxes horizontally, so that they can determine which direction to start in:
/// either right-to-left, [TextDirection.rtl]; or left-to-right,
/// [TextDirection.ltr].
///
/// ## Design discussion
///
/// Flutter is designed to address the needs of applications written in any of
/// the world's currently-used languages, whether they use a right-to-left or
/// left-to-right writing direction. Flutter does not support other writing
/// modes, such as vertical text or boustrophedon text, as these are rarely used
/// in computer programs.
///
/// It is common when developing user interface frameworks to pick a default
/// text direction — typically left-to-right, the direction most familiar to the
/// engineers working on the framework — because this simplifies the development
/// of applications on the platform. Unfortunately, this frequently results in
/// the platform having unexpected left-to-right biases or assumptions, as
/// engineers will typically miss places where they need to support
/// right-to-left text. This then results in bugs that only manifest in
/// right-to-left environments.
///
/// In an effort to minimize the extent to which Flutter experiences this
/// category of issues, the lowest levels of the Flutter framework do not have a
/// default text reading direction. Any time a reading direction is necessary,
/// for example when text is to be displayed, or when a
/// writing-direction-dependent value is to be interpreted, the reading
/// direction must be explicitly specified. Where possible, such as in `switch`
/// statements, the right-to-left case is listed first, to avoid the impression
/// that it is an afterthought.
///
/// At the higher levels (specifically starting at the widgets library), an
/// ambient [Directionality] is introduced, which provides a default. Thus, for
/// instance, a [Text] widget in the scope of a [MaterialApp] widget does not
/// need to be given an explicit writing direction. The [Directionality.of]
/// static method can be used to obtain the ambient text direction for a
/// particular [BuildContext].
///
/// ### Known left-to-right biases in Flutter
///
/// Despite the design intent described above, certain left-to-right biases have
/// nonetheless crept into Flutter's design. These include:
///
///  * The [Canvas] origin is at the top left, and the x-axis increases in a
///    left-to-right direction.
///
///  * The default localization in the widgets and material libraries is
///    American English, which is left-to-right.
///
/// ### Visual properties vs directional properties
///
/// Many classes in the Flutter framework are offered in two versions, a
/// visually-oriented variant, and a text-direction-dependent variant. For
/// example, [EdgeInsets] is described in terms of top, left, right, and bottom,
/// while [EdgeInsetsDirectional] is described in terms of top, start, end, and
/// bottom, where start and end correspond to right and left in right-to-left
/// text and left and right in left-to-right text.
///
/// There are distinct use cases for each of these variants.
///
/// Text-direction-dependent variants are useful when developing user interfaces
/// that should "flip" with the text direction. For example, a paragraph of text
/// in English will typically be left-aligned and a quote will be indented from
/// the left, while in Arabic it will be right-aligned and indented from the
/// right. Both of these cases are described by the direction-dependent
/// [TextAlign.start] and [EdgeInsetsDirectional.start].
///
/// In contrast, the visual variants are useful when the text direction is known
/// and not affected by the reading direction. For example, an application
/// giving driving directions might show a "turn left" arrow on the left and a
/// "turn right" arrow on the right — and would do so whether the application
/// was localized to French (left-to-right) or Hebrew (right-to-left).
///
/// In practice, it is also expected that many developers will only be
/// targeting one language, and in that case it may be simpler to think in
/// visual terms.
// The order of this enum must match the order of the values in TextDirection.h's TextDirection.
enum TextDirection {
  /// The text flows from right to left (e.g. Arabic, Hebrew).
  rtl,

  /// The text flows from left to right (e.g., English, French).
  ltr,
}

/// Whether a [TextPosition] is visually upstream or downstream of its offset.
///
/// For example, when a text position exists at a line break, a single offset has
/// two visual positions, one prior to the line break (at the end of the first
/// line) and one after the line break (at the start of the second line). A text
/// affinity disambiguates between those cases. (Something similar happens with
/// between runs of bidirectional text.)
enum TextAffinity {
  /// The position has affinity for the upstream side of the text position.
  ///
  /// For example, if the offset of the text position is a line break, the
  /// position represents the end of the first line.
  upstream,

  /// The position has affinity for the downstream side of the text position.
  ///
  /// For example, if the offset of the text position is a line break, the
  /// position represents the start of the second line.
  downstream,
}

/// A visual position in a string of text.
class TextPosition {
  /// Creates an object representing a particular position in a string.
  ///
  /// The arguments must not be null (so the [offset] argument is required).
  const TextPosition({
    @required this.offset,
    this.affinity = TextAffinity.downstream,
  })  : assert(offset != null),
        assert(affinity != null);

  /// The index of the character that immediately follows the position.
  ///
  /// For example, given the string `'Hello'`, offset 0 represents the cursor
  /// being before the `H`, while offset 5 represents the cursor being just
  /// after the `o`.
  final int offset;

  /// If the offset has more than one visual location (e.g., occurs at a line
  /// break), which of the two locations is represented by this position.
  ///
  /// For example, if the text `'AB'` had a forced line break between the `A`
  /// and the `B`, then the downstream affinity at offset 1 represents the
  /// cursor being just after the `A` on the first line, while the upstream
  /// affinity at offset 1 represents the cursor being just before the `B` on
  /// the first line.
  final TextAffinity affinity;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final TextPosition typedOther = other;
    return typedOther.offset == offset && typedOther.affinity == affinity;
  }

  @override
  int get hashCode => hashValues(offset, affinity);

  @override
  String toString() {
    return '$runtimeType(offset: $offset, affinity: $affinity)';
  }
}

/// Layout constraints for [Paragraph] objects.
///
/// Instances of this class are typically used with [Paragraph.layout].
///
/// The only constraint that can be specified is the [width]. See the discussion
/// at [width] for more details.
class ParagraphConstraints {
  /// Creates constraints for laying out a pargraph.
  ///
  /// The [width] argument must not be null.
  ParagraphConstraints({
    @required this.width,
  }) : assert(width != null);

  /// The width the paragraph should use whey computing the positions of glyphs.
  ///
  /// If possible, the paragraph will select a soft line break prior to reaching
  /// this width. If no soft line break is available, the paragraph will select
  /// a hard line break prior to reaching this width. If that would force a line
  /// break without any characters having been placed (i.e. if the next
  /// character to be laid out does not fit within the given width constraint)
  /// then the next character is allowed to overflow the width constraint and a
  /// forced line break is placed after it (even if an explicit line break
  /// follows).
  ///
  /// The width influences how ellipses are applied. See the discussion at [new
  /// ParagraphStyle] for more details.
  ///
  /// This width is also used to position glyphs according to the [TextAlign]
  /// alignment described in the [ParagraphStyle] used when building the
  /// [Paragraph] with a [ParagraphBuilder].
  final double width;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ParagraphConstraints typedOther = other;
    return typedOther.width == width;
  }

  @override
  int get hashCode => width.hashCode;

  @override
  String toString() => '$runtimeType(width: $width)';
}

/// Defines various ways to vertically bound the boxes returned by
/// [Paragraph.getBoxesForRange].
enum BoxHeightStyle {
  /// Provide tight bounding boxes that fit heights per run. This style may result
  /// in uneven bounding boxes that do not nicely connect with adjacent boxes.
  tight,

  /// The height of the boxes will be the maximum height of all runs in the
  /// line. All boxes in the same line will be the same height. This does not
  /// guarantee that the boxes will cover the entire vertical height of the line
  /// when there is additional line spacing.
  ///
  /// See [RectHeightStyle.includeLineSpacingTop], [RectHeightStyle.includeLineSpacingMiddle],
  /// and [RectHeightStyle.includeLineSpacingBottom] for styles that will cover
  /// the entire line.
  max,

  /// Extends the top and bottom edge of the bounds to fully cover any line
  /// spacing.
  ///
  /// The top and bottom of each box will cover half of the
  /// space above and half of the space below the line.
  ///
  /// {@template flutter.dart:ui.boxHeightStyle.includeLineSpacing}
  /// The top edge of each line should be the same as the bottom edge
  /// of the line above. There should be no gaps in vertical coverage given any
  /// amount of line spacing. Line spacing is not included above the first line
  /// and below the last line due to no additional space present there.
  /// {@endtemplate}
  includeLineSpacingMiddle,

  /// Extends the top edge of the bounds to fully cover any line spacing.
  ///
  /// The line spacing will be added to the top of the box.
  ///
  /// {@macro flutter.dart:ui.rectHeightStyle.includeLineSpacing}
  includeLineSpacingTop,

  /// Extends the bottom edge of the bounds to fully cover any line spacing.
  ///
  /// The line spacing will be added to the bottom of the box.
  ///
  /// {@macro flutter.dart:ui.boxHeightStyle.includeLineSpacing}
  includeLineSpacingBottom,
}

/// Defines various ways to horizontally bound the boxes returned by
/// [Paragraph.getBoxesForRange].
enum BoxWidthStyle {
  // Provide tight bounding boxes that fit widths to the runs of each line
  // independently.
  tight,

  /// Adds up to two additional boxes as needed at the beginning and/or end
  /// of each line so that the widths of the boxes in line are the same width
  /// as the widest line in the paragraph. The additional boxes on each line
  /// are only added when the relevant box at the relevant edge of that line
  /// does not span the maximum width of the paragraph.
  max,
}

// This encoding must match the C++ version of ParagraphBuilder::pushStyle.
//
// The encoded array buffer has 8 elements.
//
//  - Element 0: A bit field where the ith bit indicates wheter the ith element
//    has a non-null value. Bits 8 to 12 indicate whether |fontFamily|,
//    |fontSize|, |letterSpacing|, |wordSpacing|, and |height| are non-null,
//    respectively. Bit 0 is unused.
//
//  - Element 1: The |color| in ARGB with 8 bits per channel.
//
//  - Element 2: A bit field indicating which text decorations are present in
//    the |textDecoration| list. The ith bit is set if there's a TextDecoration
//    with enum index i in the list.
//
//  - Element 3: The |decorationColor| in ARGB with 8 bits per channel.
//
//  - Element 4: The bit field of the |decorationStyle|.
//
//  - Element 5: The index of the |fontWeight|.
//
//  - Element 6: The enum index of the |fontStyle|.
//
//  - Element 7: The enum index of the |textBaseline|.
//
Int32List _encodeTextStyle(
  Color color,
  TextDecoration decoration,
  Color decorationColor,
  TextDecorationStyle decorationStyle,
  FontWeight fontWeight,
  FontStyle fontStyle,
  TextBaseline textBaseline,
  String fontFamily,
  double fontSize,
  double letterSpacing,
  double wordSpacing,
  double height,
) {
  final Int32List result = new Int32List(8);
  if (color != null) {
    result[0] |= 1 << 1;
    result[1] = color.value;
  }
  if (decoration != null) {
    result[0] |= 1 << 2;
    result[2] = decoration._mask;
  }
  if (decorationColor != null) {
    result[0] |= 1 << 3;
    result[3] = decorationColor.value;
  }
  if (decorationStyle != null) {
    result[0] |= 1 << 4;
    result[4] = decorationStyle.index;
  }
  if (fontWeight != null) {
    result[0] |= 1 << 5;
    result[5] = fontWeight.index;
  }
  if (fontStyle != null) {
    result[0] |= 1 << 6;
    result[6] = fontStyle.index;
  }
  if (textBaseline != null) {
    result[0] |= 1 << 7;
    result[7] = textBaseline.index;
  }
  if (fontFamily != null) {
    result[0] |= 1 << 8;
    // Passed separately to native.
  }
  if (fontSize != null) {
    result[0] |= 1 << 9;
    // Passed separately to native.
  }
  if (letterSpacing != null) {
    result[0] |= 1 << 10;
    // Passed separately to native.
  }
  if (wordSpacing != null) {
    result[0] |= 1 << 11;
    // Passed separately to native.
  }
  if (height != null) {
    result[0] |= 1 << 12;
    // Passed separately to native.
  }
  return result;
}
