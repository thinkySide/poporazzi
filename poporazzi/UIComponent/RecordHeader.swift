//
//  RecordHeader.swift
//  poporazzi
//
//  Created by 김민준 on 5/10/25.
//

import UIKit
import PinLayout
import FlexLayout

final class RecordHeader: UICollectionReusableView {
    
    static let identifier = "RecordHeader"
    
    var containerView = UIView()

    /// 날짜 카운트 라벨
    private let dayCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainLabel
        label.font = .setDovemayo(18)
        return label
    }()
    
    /// 날짜 라벨
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .subLabel
        label.font = .setDovemayo(14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        configLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension RecordHeader {
    
    enum Action {
        case updateDayCountLabel(String)
        case updateDateLabel(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateDayCountLabel(let string):
            dayCountLabel.text = string
            
        case .updateDateLabel(let string):
            dateLabel.text = string
        }
    }
}

// MARK: - Layout

extension RecordHeader {
    
    func configLayout() {
        containerView.flex.direction(.row).paddingLeft(20).define { flex in
            flex.addItem(dayCountLabel)
            flex.addItem(dateLabel).marginLeft(8)
        }
    }
}
