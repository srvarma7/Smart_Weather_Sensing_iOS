//
//  GuageView.swift
//  UIGauge
//
//  Created by Ganesh Kanchibhotla on 2/10/19.
//  Copyright © 2019 monash. All rights reserved.
//

//REFERENCE FROM https://www.hackingwithswift.com/articles/150/how-to-create-a-custom-gauge-control-using-uikit for GuageView

import UIKit

class GaugeView: UIView {
    
    let valueLabel = UILabel()
    var valueFont = UIFont.systemFont(ofSize: 12)
    var valueColor = UIColor.gray
    
    var segmentWidth: CGFloat = 20
    var segmentColors = [
        UIColor(red: 0, green: 1, blue: 0, alpha: 1),
        UIColor(red: 173/255, green: 255/255, blue: 47/255, alpha: 1),
        UIColor(red: 204/255, green: 204/255, blue: 0, alpha: 1),
        UIColor(red: 0.8, green: 0.2, blue: 0, alpha: 0.7),
        UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)]
    
    var totalAngle: CGFloat = 270
    var rotation: CGFloat = -135
    
    var outerCenterDiscColor =  UIColor(red: 197/255, green: 26/255, blue: 74/255, alpha:0.3)
    var outerCenterDiscWidth: CGFloat = 35
    var innerCenterDiscColor =  UIColor(red: 197/255, green: 26/255, blue: 74/255, alpha: 0.8)
    var innerCenterDiscWidth: CGFloat = 25
    
    var majorTickColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    var majorTickWidth: CGFloat = 1.5
    var majorTickLength: CGFloat = 20
    
    var minorTickColor = UIColor.black.withAlphaComponent(0.1)
    var minorTickWidth: CGFloat = 0.7
    var minorTickLength: CGFloat = 20
    var minorTickCount = 3
    
    var needleColor =  UIColor(red: 197/255, green: 26/255, blue: 74/255, alpha: 1)
    var needleWidth: CGFloat = 2
    let needle = UIView()
    
    var outerBezelColor =  UIColor(red: 150/255, green: 20/255, blue: 50/255, alpha: 1)
    var outerBezelWidth: CGFloat = 5
    var innerBezelColor = UIColor.white
    var innerBezelWidth: CGFloat = 5
    
    var insideColor = UIColor.white
    
    //dynamically animate the needle when values are changed
    var value: Int = 0 {
        didSet {
            let needlePosition = CGFloat(value) / 100
            let movefrom = rotation
            let moveTo = rotation + totalAngle
            let needleRotation = movefrom + (moveTo - movefrom) * needlePosition
            needle.transform = CGAffineTransform(rotationAngle: deg2rad(needleRotation))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    
    //main function that draws the background and guages
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawBackground(in: rect, context: context)
        drawTicks(in: rect, context: context)
        drawCenterDisc(in: rect, context: context)
    }
    
    //draw the background
    func drawBackground(in rect: CGRect, context: CGContext) {

        outerBezelColor.set()
        context.fillEllipse(in: rect)
        
        let innerBezelRect = rect.insetBy(dx: outerBezelWidth, dy: outerBezelWidth)
        innerBezelColor.set()
        context.fillEllipse(in: innerBezelRect)
        
        let insideRect = innerBezelRect.insetBy(dx: innerBezelWidth, dy: innerBezelWidth)
        insideColor.set()
        context.fillEllipse(in: insideRect)
        
        drawSegments(in: rect, context: context)
    }
    
    
    //draw the needle discs
    func drawCenterDisc(in rect: CGRect, context: CGContext) {
        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        
        let outerCenterRect = CGRect(x: -outerCenterDiscWidth / 2, y: -outerCenterDiscWidth / 2, width: outerCenterDiscWidth, height: outerCenterDiscWidth)
        outerCenterDiscColor.set()
        context.fillEllipse(in: outerCenterRect)
        
        let innerCenterRect = CGRect(x: -innerCenterDiscWidth / 2, y: -innerCenterDiscWidth / 2, width: innerCenterDiscWidth, height: innerCenterDiscWidth)
        innerCenterDiscColor.set()
        context.fillEllipse(in: innerCenterRect)
        context.restoreGState()
    }
    
    //draw the segments for a guage view
    //default are 5
    func drawSegments(in rect: CGRect, context: CGContext) {

        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: deg2rad(rotation) - (.pi / 2))
        context.setLineWidth(segmentWidth)
        
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        let segmentRadius = (((rect.width - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        for (index, segment) in segmentColors.enumerated() {
           
            let start = CGFloat(index) * segmentAngle
            segment.set()
            context.addArc(center: .zero, radius: segmentRadius, startAngle: start, endAngle: start + segmentAngle, clockwise: false)
            context.drawPath(using: .stroke)
        }
        
        context.restoreGState()
    }
    
    //the separators in a segments
    func drawTicks(in rect: CGRect, context: CGContext) {

        context.saveGState()
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: deg2rad(rotation) - (.pi / 2))
        
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        let segmentRadius = (((rect.width - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        context.saveGState()
        
        context.setLineWidth(majorTickWidth)
        majorTickColor.set()
        let majorEnd = segmentRadius + (segmentWidth / 2)
        let majorStart = majorEnd - majorTickLength
        for _ in 0 ... segmentColors.count {
            context.move(to: CGPoint(x: majorStart, y: 0))
            context.addLine(to: CGPoint(x: majorEnd, y: 0))
            context.drawPath(using: .stroke)
            context.rotate(by: segmentAngle)
        }
        context.restoreGState()
        
        context.saveGState()
        
        context.setLineWidth(minorTickWidth)
        minorTickColor.set()
        let minorEnd = segmentRadius + (segmentWidth / 2)
        let minorStart = minorEnd - minorTickLength
        let minorTickSize = segmentAngle / CGFloat(minorTickCount + 1)
        for _ in 0 ..< segmentColors.count {
            
            context.rotate(by: minorTickSize)
            
            for _ in 0 ..< minorTickCount {
                context.move(to: CGPoint(x: minorStart, y: 0))
                context.addLine(to: CGPoint(x: minorEnd, y: 0))
                context.drawPath(using: .stroke)
                context.rotate(by: minorTickSize)
            }
        }
        context.restoreGState()
        context.restoreGState()
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    //draws the needle and sets the lables
    func setUp() {
        
        valueLabel.font = valueFont
        valueLabel.text = "100"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        
        needle.backgroundColor = needleColor
        needle.translatesAutoresizingMaskIntoConstraints = false
        needle.bounds = CGRect(x: 0, y: 0, width: needleWidth, height: bounds.height / 3)
        needle.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        needle.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(needle)
    }
}
