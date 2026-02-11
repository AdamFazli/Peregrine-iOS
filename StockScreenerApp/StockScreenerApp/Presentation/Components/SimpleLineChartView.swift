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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func setData(_ points: [Double], color: UIColor = Constants.UI.Colors.primary) {
        self.dataPoints = points
        self.lineColor = color
        setNeedsDisplay()
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
}
