//
//  SimpleLineChartView.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit

class SimpleLineChartView: UIView {
    
    private var dataPoints: [Double] = []
    private var lineColor: UIColor = Constants.UI.Colors.primary
    private var lineLayer: CAShapeLayer?
    private var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    func setData(_ points: [Double], color: UIColor = Constants.UI.Colors.primary, animated: Bool = true) {
        guard !points.isEmpty else { return }
        
        self.dataPoints = points
        self.lineColor = color
        
        lineLayer?.removeFromSuperlayer()
        gradientLayer?.removeFromSuperlayer()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if animated {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                self.animateChart()
            } else {
                self.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !dataPoints.isEmpty else { return }
        
        let minValue = dataPoints.min() ?? 0
        let maxValue = dataPoints.max() ?? 1
        let range = maxValue - minValue
        
        guard range > 0 else { return }
        
        let width = rect.width
        let height = rect.height
        let pointSpacing = width / CGFloat(dataPoints.count - 1)
        
        let path = UIBezierPath()
        
        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * pointSpacing
            let normalizedValue = (value - minValue) / range
            let y = height - (CGFloat(normalizedValue) * height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        lineColor.setStroke()
        path.lineWidth = 2.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
        
        let gradientPath = path.copy() as! UIBezierPath
        gradientPath.addLine(to: CGPoint(x: width, y: height))
        gradientPath.addLine(to: CGPoint(x: 0, y: height))
        gradientPath.close()
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        gradientPath.addClip()
        
        let colors = [lineColor.withAlphaComponent(0.3).cgColor, lineColor.withAlphaComponent(0.0).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
        
        context.drawLinearGradient(gradient,
                                    start: CGPoint(x: 0, y: 0),
                                    end: CGPoint(x: 0, y: height),
                                    options: [])
        context.restoreGState()
    }
    
    private func animateChart() {
        guard !dataPoints.isEmpty else { return }
        
        let minValue = dataPoints.min() ?? 0
        let maxValue = dataPoints.max() ?? 1
        let range = maxValue - minValue
        guard range > 0 else { return }
        
        let width = bounds.width
        let height = bounds.height
        let pointSpacing = width / CGFloat(dataPoints.count - 1)
        
        let path = UIBezierPath()
        
        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * pointSpacing
            let normalizedValue = (value - minValue) / range
            let y = height - (CGFloat(normalizedValue) * height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        
        layer.addSublayer(shapeLayer)
        self.lineLayer = shapeLayer
        
        let gradientPath = path.copy() as! UIBezierPath
        gradientPath.addLine(to: CGPoint(x: width, y: height))
        gradientPath.addLine(to: CGPoint(x: 0, y: height))
        gradientPath.close()
        
        let gradientMask = CAShapeLayer()
        gradientMask.path = gradientPath.cgPath
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [lineColor.withAlphaComponent(0.3).cgColor, lineColor.withAlphaComponent(0.0).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.mask = gradientMask
        
        layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shapeLayer.add(animation, forKey: "lineAnimation")
        
        gradient.opacity = 0
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.6)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
        gradient.opacity = 1
        CATransaction.commit()
    }
}
