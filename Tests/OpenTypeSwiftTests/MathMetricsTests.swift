import XCTest
@testable import OpenTypeSwift

final class MathMetricsTests: XCTestCase {
    func testNoMathMetrics() {
        let helv = CTFontCreateWithName("Helvetica" as CFString, 12.0, nil)
    
        XCTAssertNil(helv.mathMetrics)
    }

    // Check _every_ metric on Latin Modern Math 12. Most of these look
    // reasonable by eye, comparing with the spec's descriptions and
    // suggested values, but this test mostly just proves that the offsets
    // aren't out of whack.
    func testLatinModern() {
        let lmm12 = CTFontCreateWithName("Latin Modern Math" as CFString, 12.0, nil)

        let metrics = lmm12.mathMetrics!

        XCTAssertEqual(metrics.majorVersion, 1)
        XCTAssertEqual(metrics.minorVersion, 0)

        // MathConstants:

        let ruleThickness: CGFloat = 0.48
        let commonGap: CGFloat = 1.44

        XCTAssertEqual(metrics.scriptRatioScaleDown, 0.7)
        XCTAssertEqual(metrics.scriptScriptRatioScaleDown, 0.5)

        XCTAssertEqual(metrics.delimitedSubFormulaMinHeight, 15.6)
        XCTAssertEqual(metrics.displayOperatorMinHeight, 15.6)
        XCTAssertEqual(metrics.mathLeading, 1.848)
        XCTAssertEqual(metrics.axisHeight, 3.0)
        XCTAssertEqual(metrics.accentBaseHeight, 5.4)
        XCTAssertEqual(metrics.flattenedAccentBaseHeight, 7.968)

        XCTAssertEqual(metrics.subscriptShiftDown, 2.964)
        XCTAssertEqual(metrics.subscriptTopMax, 4.128)
        XCTAssertEqual(metrics.subscriptBaselineDropMin, 2.4)
        XCTAssertEqual(metrics.superscriptShiftUp, 4.356)
        XCTAssertEqual(metrics.superscriptShiftUpCramped, 3.468)
        XCTAssertEqual(metrics.superscriptBottomMin, 1.296)
        XCTAssertEqual(metrics.superscriptBaselineDropMax, 3.0)
        XCTAssertEqual(metrics.subSuperscriptGapMin, 1.92)
        XCTAssertEqual(metrics.superscriptBottomMaxWithSubscript, 4.128)
        XCTAssertEqual(metrics.spaceAfterScript, 0.672)

        XCTAssertEqual(metrics.upperLimitGapMin, 2.4)
        XCTAssertEqual(metrics.upperLimitBaselineRiseMin, 1.332)
        XCTAssertEqual(metrics.lowerLimitGapMin, 2.004)
        XCTAssertEqual(metrics.lowerLimitBaselineDropMin, 7.2)

        XCTAssertEqual(metrics.stackTopShiftUp, 5.328)
        XCTAssertEqual(metrics.stackTopDisplayStyleShiftUp, 8.124)
        XCTAssertEqual(metrics.stackBottomShiftDown, 4.14)
        XCTAssertEqual(metrics.stackBottomDisplayStyleShiftDown, 8.232)
        XCTAssertEqual(metrics.stackGapMin, 1.44)
        XCTAssertEqual(metrics.stackDisplayStyleGapMin, 3.36)

        XCTAssertEqual(metrics.stretchStackTopShiftUp, 1.332)
        XCTAssertEqual(metrics.stretchStackBottomShiftDown, 7.2)
        XCTAssertEqual(metrics.stretchStackGapAboveMin, 2.4)
        XCTAssertEqual(metrics.stretchStackGapBelowMin, 2.004)

        XCTAssertEqual(metrics.fractionNumeratorShiftUp, 4.728)
        XCTAssertEqual(metrics.fractionNumeratorDisplayStyleShiftUp, 8.124)
        XCTAssertEqual(metrics.fractionDenominatorShiftDown, 4.14)
        XCTAssertEqual(metrics.fractionDenominatorDisplayStyleShiftDown, 8.232)
        XCTAssertEqual(metrics.fractionNumeratorGapMin, ruleThickness)
        XCTAssertEqual(metrics.fractionNumDisplayStyleGapMin, commonGap)
        XCTAssertEqual(metrics.fractionRuleThickness, ruleThickness)
        XCTAssertEqual(metrics.fractionDenominatorGapMin, ruleThickness)
        XCTAssertEqual(metrics.fractionDenomDisplayStyleGapMin, commonGap)

        XCTAssertEqual(metrics.skewedFractionHorizontalGap, 4.2)
        XCTAssertEqual(metrics.skewedFractionVerticalGap, 1.152)

        XCTAssertEqual(metrics.overbarVerticalGap, commonGap)
        XCTAssertEqual(metrics.overbarRuleThickness, ruleThickness)
        XCTAssertEqual(metrics.overbarExtraAscender, ruleThickness)

        XCTAssertEqual(metrics.underbarVerticalGap, commonGap)
        XCTAssertEqual(metrics.underbarRuleThickness, ruleThickness)
        XCTAssertEqual(metrics.underbarExtraDescender, ruleThickness)

        XCTAssertEqual(metrics.radicalVerticalGap, 0.6)
        XCTAssertEqual(metrics.radicalDisplayStyleVerticalGap, 1.776)
        XCTAssertEqual(metrics.radicalRuleThickness, ruleThickness)
        XCTAssertEqual(metrics.radicalExtraAscender, ruleThickness)
        XCTAssertEqual(metrics.radicalKernBeforeDegree, 3.336)
        XCTAssertEqual(metrics.radicalKernAfterDegree, -6.672)
        XCTAssertEqual(metrics.radicalDegreeBottomRaiseRatio, 0.7)
    }

    static var allTests = [
        ("testNoMathMetrics", testNoMathMetrics),
        ("testLatinModern", testLatinModern),
    ]
}
