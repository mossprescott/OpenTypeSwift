import CoreText

struct FontMetrics {
    var font: CTFont
    
    init(name: String, size: CGFloat) {
        font = CTFontCreateWithName(name as! CFString,
                                    size,
                                    nil)
    }
    
    init(font: CTFont) {
        self.font = font
    }
    
    func mathMetrics() -> MathMetrics? {
        if let data = CTFontCopyTable(font, CTFontTableTag(kCTFontTableMATH), CTFontTableOptions(rawValue: 0)) {
            return MathMetrics(font: font, data: data)
        }
        else {
            return nil
        }
    }
}

/// Font data from the OpenType `MATH` table, which is useful for laying out math expressions.
/// Unless otherwise specified, all measurements are in points, scaled to the font's size.
///
/// Retains a copy of the table and a reference to the font.
///
/// TODO: the docs say the data reference must be released. What does that mean, exactly?
///
/// See https://docs.microsoft.com/en-us/typography/opentype/spec/math
class MathMetrics {
    let font: CTFont
    let data: CFData
    
    init(font: CTFont, data: CFData) {
        self.font = font
        self.data = data
    }


// MARK: - MATH header

    /// Major version of the MATH table, = 1.
    var majorVersion: UInt16 {
        read16(offset: 0)
    }

    /// Minor version of the MATH table, = 0.
    var minorVersion: UInt16 {
        read16(offset: 2)
    }


// MARK: - MathConstants table
// constants required to properly position elements of mathematical formulas.
// See https://docs.microsoft.com/en-us/typography/opentype/spec/math#mathconstants-table

    /// Ratio of scaling down for level 1 superscripts and subscripts. Suggested value: 0.8.
    var scriptRatioScaleDown: CGFloat {
        CGFloat(readConstants16(offset: 0))/100
    }

    /// Ratio of scaling down for level 2 (scriptScript) superscripts and subscripts. Suggested value: 0.6.
    var scriptScriptRatioScaleDown: CGFloat {
        CGFloat(readConstants16(offset: 2))/100
    }

    /// Minimum height required for a delimited expression (contained within parentheses, etc.) to be
    /// treated as a sub-formula. Suggested value: normal line height × 1.5.
    var delimitedSubFormulaMinHeight: CGFloat {
        designUnitsToPoints(readConstants16(offset: 4))
    }

    /// Minimum height of n-ary operators (such as integral and summation) for formulas in display mode
    /// (that is, appearing as standalone page elements, not embedded inline within text).
    var displayOperatorMinHeight: CGFloat {
        designUnitsToPoints(readConstants16(offset: 6))
    }
    
    /// White space to be left between math formulas to ensure proper line spacing. For example, for applications
    /// that treat line gap as a part of line ascender, formulas with ink going above
    /// `(os2.sTypoAscender + os2.sTypoLineGap - MathLeading)` or with ink going below
    /// `os2.sTypoDescender` will result in increasing line height.
    var mathLeading: CGFloat {
        readConstantsMathValueRecord(offset: 8)
    }

    /// Axis height of the font.
    ///
    /// In math typesetting, the term axis refers to a horizontal reference line used for positioning elements in a formula.
    /// The math axis is similar to but distinct from the baseline for regular text layout. For example, in a simple equation,
    /// a minus symbol or fraction rule would be on the axis, but a string for a variable name would be set on a baseline
    /// that is offset from the axis. The axisHeight value determines the amount of that offset.
    var axisHeight: CGFloat {
        readConstantsMathValueRecord(offset: 12)
    }

    /// Maximum (ink) height of accent base that does not require raising the accents. Suggested: x‑height of the font
    /// (`os2.sxHeight`) plus any possible overshots.
    var accentBaseHeight: CGFloat {
        readConstantsMathValueRecord(offset: 16)
    }
    
    /// Maximum (ink) height of accent base that does not require flattening the accents. Suggested: cap height of the font
    /// (`os2.sCapHeight`).
    var flattenedAccentBaseHeight: CGFloat {
        readConstantsMathValueRecord(offset: 20)
    }
    
    /// The standard shift down applied to subscript elements. Positive for moving in the downward direction. Suggested:
    /// `os2.ySubscriptYOffset`.
    var subscriptShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 24)
    }
    
    /// Maximum allowed height of the (ink) top of subscripts that does not require moving subscripts further down.
    /// Suggested: `4/5 x-height`.
    var subscriptTopMax: CGFloat {
        readConstantsMathValueRecord(offset: 28)
    }
    
    /// Minimum allowed drop of the baseline of subscripts relative to the (ink) bottom of the base. Checked for bases
    /// that are treated as a box or extended shape. Positive for subscript baseline dropped below the base bottom.
    var subscriptBaselineDropMin: CGFloat {
        readConstantsMathValueRecord(offset: 32)
    }
    
    /// Standard shift up applied to superscript elements. Suggested: `os2.ySuperscriptYOffset`.
    var superscriptShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 36)
    }
    
    /// Standard shift of superscripts relative to the base, in cramped style.
    var superscriptShiftUpCramped: CGFloat {
        readConstantsMathValueRecord(offset: 40)
    }
    
    /// Minimum allowed height of the (ink) bottom of superscripts that does not require moving subscripts further up.
    /// Suggested: ¼ `x-height`.
    var superscriptBottomMin: CGFloat {
        readConstantsMathValueRecord(offset: 44)
    }
    
    /// Maximum allowed drop of the baseline of superscripts relative to the (ink) top of the base. Checked for bases
    /// that are treated as a box or extended shape. Positive for superscript baseline below the base top.
    var superscriptBaselineDropMax: CGFloat {
        readConstantsMathValueRecord(offset: 48)
    }
    
    /// Minimum gap between the superscript and subscript ink. Suggested: 4 × default rule thickness.
    var subSuperscriptGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 52)
    }
    
    /// The maximum level to which the (ink) bottom of superscript can be pushed to increase the gap
    /// between superscript and subscript, before subscript starts being moved down. Suggested: 4/5 `x-height`.
    var superscriptBottomMaxWithSubscript: CGFloat {
        readConstantsMathValueRecord(offset: 56)
    }
    
    /// Extra white space to be added after each subscript and superscript. Suggested: 0.5 pt for a 12 pt font.
    /// (Note that, in some math layout implementations, a constant value, such as 0.5 pt, may be used for all
    /// text sizes. Some implementations may use a constant ratio of text size, such as 1/24 of em.)
    var spaceAfterScript: CGFloat {
        readConstantsMathValueRecord(offset: 60)
    }
    
    /// Minimum gap between the (ink) bottom of the upper limit, and the (ink) top of the base operator.
    var upperLimitGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 64)
    }
    
    /// Minimum distance between baseline of upper limit and (ink) top of the base operator.
    var upperLimitBaselineRiseMin: CGFloat {
        readConstantsMathValueRecord(offset: 68)
    }
    
    /// Minimum gap between (ink) top of the lower limit, and (ink) bottom of the base operator.
    var lowerLimitGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 72)
    }
    
    /// Minimum distance between baseline of the lower limit and (ink) bottom of the base operator.
    var lowerLimitBaselineDropMin: CGFloat {
        readConstantsMathValueRecord(offset: 76)
    }
    
    /// Standard shift up applied to the top element of a stack.
    var stackTopShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 80)
    }
    
    /// Standard shift up applied to the top element of a stack in display style.
    var stackTopDisplayStyleShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 84)
    }
    
    /// Standard shift down applied to the bottom element of a stack. Positive for moving in the downward direction.
    var stackBottomShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 88)
    }
    
    /// Standard shift down applied to the bottom element of a stack in display style. Positive for moving in the downward direction.
    var stackBottomDisplayStyleShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 92)
    }
    
    /// Minimum gap between (ink) bottom of the top element of a stack, and the (ink) top of the bottom element. Suggested:
    /// 3 × default rule thickness.
    var stackGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 96)
    }
    
    /// Minimum gap between (ink) bottom of the top element of a stack, and the (ink) top of the bottom element in display style.
    /// Suggested: 7 × default rule thickness.
    var stackDisplayStyleGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 100)
    }
    
    /// Standard shift up applied to the top element of the stretch stack.
    var stretchStackTopShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 104)
    }
    
    /// Standard shift down applied to the bottom element of the stretch stack. Positive for moving in the downward direction.
    var stretchStackBottomShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 108)
    }
    
    /// Minimum gap between the ink of the stretched element, and the (ink) bottom of the element above. Suggested: same value
    /// as `upperLimitGapMin`.
    var stretchStackGapAboveMin: CGFloat {
        readConstantsMathValueRecord(offset: 112)
    }
    
    /// Minimum gap between the ink of the stretched element, and the (ink) top of the element below. Suggested: same value
    /// as `lowerLimitGapMin`.
    var stretchStackGapBelowMin: CGFloat {
        readConstantsMathValueRecord(offset: 116)
    }
    
    /// Standard shift up applied to the numerator.
    var fractionNumeratorShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 120)
    }
    
    /// Standard shift up applied to the numerator in display style. Suggested: same value as `stackTopDisplayStyleShiftUp`.
    var fractionNumeratorDisplayStyleShiftUp: CGFloat {
        readConstantsMathValueRecord(offset: 124)
    }
    
    /// Standard shift down applied to the denominator. Positive for moving in the downward direction.
    var fractionDenominatorShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 128)
    }
    
    /// Standard shift down applied to the denominator in display style. Positive for moving in the downward direction.
    /// Suggested: same value as `stackBottomDisplayStyleShiftDown`.
    var fractionDenominatorDisplayStyleShiftDown: CGFloat {
        readConstantsMathValueRecord(offset: 132)
    }
    
    /// Minimum tolerated gap between the (ink) bottom of the numerator and the ink of the fraction bar. Suggested:
    /// default rule thickness.
    var fractionNumeratorGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 136)
    }
    
    /// Minimum tolerated gap between the (ink) bottom of the numerator and the ink of the fraction bar in display style.
    /// Suggested: 3 × default rule thickness.
    var fractionNumDisplayStyleGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 140)
    }
    
    /// Thickness of the fraction bar. Suggested: default rule thickness.
    var fractionRuleThickness: CGFloat {
        readConstantsMathValueRecord(offset: 144)
    }
    
    /// Minimum tolerated gap between the (ink) top of the denominator and the ink of the fraction bar. Suggested:
    /// default rule thickness.
    var fractionDenominatorGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 148)
    }
    
    /// Minimum tolerated gap between the (ink) top of the denominator and the ink of the fraction bar in display style.
    /// Suggested: 3 × default rule thickness.
    var fractionDenomDisplayStyleGapMin: CGFloat {
        readConstantsMathValueRecord(offset: 152)
    }
    
    /// Horizontal distance between the top and bottom elements of a skewed fraction.
    var skewedFractionHorizontalGap: CGFloat {
        readConstantsMathValueRecord(offset: 156)
    }
    
    /// Vertical distance between the ink of the top and bottom elements of a skewed fraction.
    var skewedFractionVerticalGap: CGFloat {
        readConstantsMathValueRecord(offset: 160)
    }
    
    /// Distance between the overbar and the (ink) top of the base. Suggested: 3 × default rule thickness.
    var overbarVerticalGap: CGFloat {
        readConstantsMathValueRecord(offset: 164)
    }
    
    /// Thickness of overbar. Suggested: default rule thickness.
    var overbarRuleThickness: CGFloat {
        readConstantsMathValueRecord(offset: 168)
    }
    
    /// Extra white space reserved above the overbar. Suggested: default rule thickness.
    var overbarExtraAscender: CGFloat {
        readConstantsMathValueRecord(offset: 172)
    }
    
    /// Distance between underbar and (ink) bottom of the base. Suggested: 3 × default rule thickness.
    var underbarVerticalGap: CGFloat {
        readConstantsMathValueRecord(offset: 176)
    }
    
    /// Thickness of underbar. Suggested: default rule thickness.
    var underbarRuleThickness: CGFloat {
        readConstantsMathValueRecord(offset: 180)
    }
    
    /// Extra white space reserved below the underbar. Always positive. Suggested: default rule thickness.
    var underbarExtraDescender: CGFloat {
        readConstantsMathValueRecord(offset: 184)
    }
    
    /// Space between the (ink) top of the expression and the bar over it. Suggested: 1¼ default rule thickness.
    var radicalVerticalGap: CGFloat {
        readConstantsMathValueRecord(offset: 188)
    }
    
    /// Space between the (ink) top of the expression and the bar over it. Suggested: default rule thickness + ¼ x-height.
    var radicalDisplayStyleVerticalGap: CGFloat {
        readConstantsMathValueRecord(offset: 192)
    }
    
    /// Thickness of the radical rule. This is the thickness of the rule in designed or constructed radical signs.
    /// Suggested: default rule thickness.
    var radicalRuleThickness: CGFloat {
        readConstantsMathValueRecord(offset: 196)
    }
    
    /// Extra white space reserved above the radical. Suggested: same value as `radicalRuleThickness`.
    var radicalExtraAscender: CGFloat {
        readConstantsMathValueRecord(offset: 200)
    }
    
    /// Extra horizontal kern before the degree of a radical, if such is present. Suggested: 5/18 of em.
    var radicalKernBeforeDegree: CGFloat {
        readConstantsMathValueRecord(offset: 204)
    }
    
    /// Negative kern after the degree of a radical, if such is present. Suggested: −10/18 of em.
    var radicalKernAfterDegree: CGFloat {
        readConstantsMathValueRecord(offset: 208)
    }
    
    /// Height of the bottom of the radical degree, if such is present, in proportion to the ascender of the radical sign. Suggested: 0.6.
    var radicalDegreeBottomRaiseRatio: CGFloat {
        CGFloat(readConstants16(offset: 0))/100
    }
    
    
// MARK: - MathGlyphInfo table
// Per-glyph positioning information, including italic corections and kerning.
// See https://docs.microsoft.com/en-us/typography/opentype/spec/math#mathglyphinfo-table

// Not implemented yet.

    
// MARK: - MathVariants table
// For identifying the glyphs that make up large parentheses, radicals, etc.
// See https://docs.microsoft.com/en-us/typography/opentype/spec/math#mathvariants-table
    
// Not implemented yet.

        
// MARK: - Helpers

    /// Convert a measurement from size-independent design units to points. Note: CGFloat is at least 32 bits,
    /// but typically 64, so there's no danger of loss of precision.
    private func designUnitsToPoints<T: BinaryInteger>(_ du: T) -> CGFloat {
        return CGFloat(du) * CTFontGetSize(font)/CGFloat(CTFontGetUnitsPerEm(font))
    }
    
    /// Read 16 bits, in big-endian order, at the given (byte) offset.
    private func read16(offset: CFIndex) -> UInt16 {
        let ptr = CFDataGetBytePtr(data)!
        return (ptr+offset).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee.byteSwapped
        }
    }
    
    /// Read 16 signed bits, in big-endian order, at the given (byte) offset.
    private func readSigned16(offset: CFIndex) -> Int16 {
        let ptr = CFDataGetBytePtr(data)!
        return (ptr+offset).withMemoryRebound(to: Int16.self, capacity: 1) {
            $0.pointee.byteSwapped
        }
    }
    
    /// Read 16 bits from the MathConstants table.
    private func readConstants16(offset: CFIndex) -> UInt16 {
        let constantsOffset = Int(read16(offset: 4))
        return read16(offset: constantsOffset + offset)
    }
    
    private func readConstantsMathValueRecord(offset: CFIndex) -> CGFloat {
        let constantsOffset = Int(read16(offset: 4))
        let value = readSigned16(offset: constantsOffset + offset)
        let adjustment = deviceDelta(parentTable: constantsOffset, offset: offset+2)
        return designUnitsToPoints(value + adjustment)
    }
    
    /// See https://docs.microsoft.com/en-us/typography/opentype/spec/chapter2#device-and-variationindex-tables
    /// TODO: any of these actually present?
    /// Would need pixel-per-em for the display device to actually apply these adjustments. And anyway, this is probably not relevant
    /// at high resolution (the doc's example adjusts 11 to 15 ppem,  which is something like 5pt at most.)
    private func deviceDelta(parentTable: CFIndex, offset: CFIndex) -> Int16 {
        let deviceOffset = read16(offset: parentTable + offset)
        if deviceOffset != 0 {
            print("device table present at offset \(offset): \(deviceOffset); \(font)")
            let deviceTable = parentTable + Int(deviceOffset)
            let startSize = read16(offset: deviceTable)
            let endSize = read16(offset: deviceTable + 2)
            let deltaFormat = read16(offset: deviceTable + 4)  // 0x0001 is expected (2-bit deltas)
            let first16 = read16(offset: deviceTable + 6)
            print("  sizes: \(startSize) to \(endSize); format: \(deltaFormat); first word: \(first16)")
        }
        return 0
    }
}
