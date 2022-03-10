//
//  SCTitleLabel.swift
//  Prototype
//
//  Created by Onurcan Sever on 2022-03-09.
//

import UIKit

class SCTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(fontSize: CGFloat, textColor: UIColor) {
        super.init(frame: .zero)
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        self.textColor = textColor
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }

}
