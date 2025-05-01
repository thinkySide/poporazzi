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
                Image(.appIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 4)
            } compactTrailing: {
                Text("\(context.state.totalCount)장")
                    .padding(.trailing, 4)
            } minimal: {
                Image(.appIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 4)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(.brandPrimary)
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
        .padding(20)
        .activityBackgroundTint(.white)
        .activitySystemActionForegroundColor(Color.black)
    }
}
