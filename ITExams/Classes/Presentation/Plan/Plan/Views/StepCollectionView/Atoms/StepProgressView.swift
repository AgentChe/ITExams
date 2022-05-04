//
//  StepProgressView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.05.2022.
//

import UIKit

final class StepProgressView: UIView {
    private lazy var circleLayer = CAShapeLayer()
    private lazy var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createCircularPath()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: API
extension StepProgressView {
    func setup(progress: Int) {
        trackLayer.strokeEnd = CGFloat(progress) / 100
    }
}

// MARK: Private
private extension StepProgressView {
    func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 68.scale, y: 68.scale),
                                        radius: 62.scale,
                                        startAngle: -.pi / 2,
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 12.scale
        circleLayer.strokeColor = Appearance.fourthColor.withAlphaComponent(0.5).cgColor
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.lineWidth = 12.scale
        trackLayer.strokeColor = Appearance.mainColor.cgColor
        trackLayer.strokeStart = 0
        
        layer.addSublayer(circleLayer)
        layer.addSublayer(trackLayer)
    }
}
