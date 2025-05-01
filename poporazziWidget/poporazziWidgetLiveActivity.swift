//
//  poporazziWidgetLiveActivity.swift
//  poporazziWidget
//
//  Created by 김민준 on 5/1/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PoporazziWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var albumTitle: String
        var startDate: Date
        var totalCount: Int
    }
}

// MARK: - Live Activity UI

struct PoporazziWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PoporazziWidgetAttributes.self) { context in
            LockScreen(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("m")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

// MARK: - LockScreen

private struct LockScreen: View {
    
    let context: ActivityViewContext<PoporazziWidgetAttributes>
    
    var body: some View {
        HStack(spacing: 12) {
            Image(.appIcon)
                .resizable()
                .frame(width: 52, height: 52)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.albumTitle)
                    .font(.doveMayo(size: 20))
                    .foregroundStyle(.mainLabel)
                
                Text(context.state.startDate.startDateFormat)
                    .font(.doveMayo(size: 14))
                    .foregroundStyle(.subLabel)
            }
            
            Spacer()
            
            Text("\(context.state.totalCount)장")
                .font(.doveMayo(size: 28))
                .foregroundStyle(.brandPrimary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .activityBackgroundTint(.white)
        .activitySystemActionForegroundColor(Color.black)
    }
}

extension Font {
    
    static func doveMayo(size: CGFloat) -> Font {
        .custom("Dovemayo_gothic", size: size)
    }
}
