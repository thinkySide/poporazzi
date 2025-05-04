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
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 0) {
                        Image(.appIcon)
                            .resizable()
                            .frame(width: 52, height: 52)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(context.state.albumTitle)
                                .font(.doveMayo(size: 20))
                            
                            Text(context.state.startDate.startDateFormat)
                                .font(.doveMayo(size: 14))
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        Text("\(context.state.totalCount)장")
                            .font(.doveMayo(size: 28))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(.appIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 4)
            } compactTrailing: {
                Text("\(context.state.totalCount)장")
                    .font(.doveMayo(size: 14))
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
                    .foregroundStyle(.white)
                
                Text(context.state.startDate.startDateFormat)
                    .font(.doveMayo(size: 14))
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Text("\(context.state.totalCount)장")
                .font(.doveMayo(size: 28))
                .foregroundStyle(.white)
        }
        .padding(20)
        .activityBackgroundTint(Color("WidgetBackground"))
    }
}
