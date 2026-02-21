import ClockKit
import SwiftUI

// MARK: - Complication Provider

class ChrisComplicationProvider: NSObject, CLKComplicationDataSource {

    // MARK: - Complication descriptors

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "ChrisStatus",
                displayName: "Chris",
                supportedFamilies: [
                    .modularSmall,
                    .utilitarianSmall,
                    .utilitarianSmallFlat,
                    .circularSmall,
                    .graphicCorner,
                    .graphicCircular,
                    .graphicBezel,
                    .graphicRectangular
                ]
            )
        ]
        handler(descriptors)
    }

    // MARK: - Timeline entries

    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let enabledCount = UserDefaults.standard.integer(forKey: "chrisEnabledCount")
        let entry = makeEntry(for: complication, count: enabledCount)
        handler(entry)
    }

    func getTimelineEntries(
        for complication: CLKComplication,
        after date: Date,
        limit: Int,
        withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void
    ) {
        handler(nil) // No future entries
    }

    // MARK: - Entry builder

    private func makeEntry(
        for complication: CLKComplication,
        count: Int
    ) -> CLKComplicationTimelineEntry? {
        let date = Date()
        let template = makeTemplate(for: complication, count: count)
        guard let t = template else { return nil }
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: t)
    }

    private func makeTemplate(
        for complication: CLKComplication,
        count: Int
    ) -> CLKComplicationTemplate? {

        let label = count > 0 ? "\(count) on" : "Chris"
        let shortText = CLKSimpleTextProvider(text: label)
        let longText  = CLKSimpleTextProvider(text: count > 0 ? "\(count) tweaks on" : "Chris")

        switch complication.family {

        case .modularSmall:
            let t = CLKComplicationTemplateModularSmallStackText()
            t.line1TextProvider = CLKSimpleTextProvider(text: "C")
            t.line2TextProvider = shortText
            return t

        case .utilitarianSmall:
            let t = CLKComplicationTemplateUtilitarianSmallFlat()
            t.textProvider = shortText
            return t

        case .utilitarianSmallFlat:
            let t = CLKComplicationTemplateUtilitarianSmallFlat()
            t.textProvider = shortText
            return t

        case .circularSmall:
            let t = CLKComplicationTemplateCircularSmallStackText()
            t.line1TextProvider = CLKSimpleTextProvider(text: "C")
            t.line2TextProvider = shortText
            return t

        case .graphicCorner:
            let t = CLKComplicationTemplateGraphicCornerStackText()
            t.outerTextProvider = CLKSimpleTextProvider(text: "Chris")
            t.innerTextProvider = shortText
            return t

        case .graphicCircular:
            let t = CLKComplicationTemplateGraphicCircularView(
                ChrisComplicationCircularView(count: count)
            )
            return t

        case .graphicBezel:
            let circTemplate = CLKComplicationTemplateGraphicCircularView(
                ChrisComplicationCircularView(count: count)
            )
            let t = CLKComplicationTemplateGraphicBezelCircularText()
            t.circularTemplate = circTemplate
            t.textProvider = longText
            return t

        case .graphicRectangular:
            let t = CLKComplicationTemplateGraphicRectangularStandardBody()
            t.headerTextProvider = CLKSimpleTextProvider(text: "Chris")
            t.body1TextProvider = longText
            t.body2TextProvider = CLKSimpleTextProvider(text: "Tap to manage")
            return t

        default:
            return nil
        }
    }

    func getLocalizableSampleTemplate(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTemplate?) -> Void
    ) {
        handler(makeTemplate(for: complication, count: 7))
    }
}

// MARK: - Circular complication SwiftUI view

struct ChrisComplicationCircularView: View {
    let count: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "5E5CE6").opacity(0.85))
            VStack(spacing: 0) {
                Text("C")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}
