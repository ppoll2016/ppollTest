//
//  RoundIndicatorView.swift
//  pPoll
//
//  Created by syle on 9/09/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

@IBDesignable
class RoundIndicatorView: UIView {

    let totalResponedLabel = UILabel()
    
    var questionNumType = 2
    var totalResponedNum: CGFloat = 0
    var curValue: [CGFloat] = [] {
        didSet {
            helperAnimate()
            //animate()
        }
    }
    let margin: CGFloat = 10
    
    let bgLayer = CAShapeLayer()
    @IBInspectable var bgColor: UIColor = UIColor.grayColor() {
        didSet {
            configure()
        }
    }
    let fgLayer = CAShapeLayer()
    @IBInspectable var fgColor: UIColor = UIColor.blackColor() {
        didSet {
            configure()
        }
    }
    
    let fgLayer1 = CAShapeLayer()
    let fgLayer2 = CAShapeLayer()
    let fgLayer3 = CAShapeLayer()
    let fgLayer4 = CAShapeLayer()
    let fgLayer5 = CAShapeLayer()
    var layers: [CAShapeLayer] {
        get{
            return [fgLayer,fgLayer1,fgLayer2,fgLayer3,fgLayer4,fgLayer5]
        }
    }
    
    let π = CGFloat(M_PI)
    
    func DegreesToRadians (value:CGFloat) -> CGFloat {
        return value * π / 180.0
    }
    
    func RadiansToDegrees (value:CGFloat) -> CGFloat {
        return value * 180.0 / π
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }
    
    func setup() {
        
        // Setup background layer
        bgLayer.lineWidth = 10.0
        bgLayer.fillColor = nil
        bgLayer.strokeEnd = 1
        layer.addSublayer(bgLayer)
        fgLayer.lineWidth = 10.0
        fgLayer.fillColor = nil
        fgLayer.strokeEnd = 0
        layer.addSublayer(fgLayer)
        initLayer(fgLayer1)
        initLayer(fgLayer2)
        initLayer(fgLayer3)
        initLayer(fgLayer4)
        initLayer(fgLayer5)
        
        // Setup percent label
        totalResponedLabel.font = UIFont.systemFontOfSize(14)
        totalResponedLabel.textColor = UIColor.blueColor()
        totalResponedLabel.text = "0"
        totalResponedLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalResponedLabel)
        
        // Setup constraints
        let percentLabelCenterX = totalResponedLabel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor)
        let percentLabelCenterY = totalResponedLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor)
//        let percentLabelCenterY = percentLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: -margin)
        NSLayoutConstraint.activateConstraints([percentLabelCenterX, percentLabelCenterY])
        
    }
    
    func initLayer(layer:CAShapeLayer) {
        layer.lineWidth = 10.0
        layer.fillColor = nil
        layer.strokeEnd = 0
        self.layer.addSublayer(layer)
    }

    
    func configure() {
        bgLayer.strokeColor = bgColor.CGColor
        fgLayer.strokeColor = fgColor.CGColor
        fgLayer1.strokeColor = UIColor.blueColor().CGColor
        fgLayer2.strokeColor = UIColor.greenColor().CGColor
        fgLayer3.strokeColor = UIColor.orangeColor().CGColor
        fgLayer4.strokeColor = UIColor.yellowColor().CGColor
        fgLayer5.strokeColor = UIColor.whiteColor().CGColor

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShapeLayer(bgLayer)
        setupShapeLayer(fgLayer)
        setupShapeLayer(fgLayer1)
        setupShapeLayer(fgLayer2)
        setupShapeLayer(fgLayer3)
        setupShapeLayer(fgLayer4)
        setupShapeLayer(fgLayer5)

    }
    
    private func setupShapeLayer(shapeLayer:CAShapeLayer) {
        totalResponedLabel.text = String(format: "%.0f", totalResponedNum)
        shapeLayer.frame = self.bounds
        let startAngle = DegreesToRadians(90.001)//135
        let endAngle = DegreesToRadians(90.0)//45
        let center = totalResponedLabel.center
        let radius = CGRectGetWidth(self.bounds) * 0.45
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.path = path.CGPath
        
    }
    
    private func helperAnimate(){
        totalResponedLabel.text = String(format: "%.0f", totalResponedNum)
        var percentValue:[CGFloat] = []
        for i in 0 ..< curValue.count {
            percentValue.append(curValue[i]/totalResponedNum)
        }
        
        var curValues:[CGFloat] = []
        var temp:CGFloat = 0
        for i in 0 ..< curValue.count {
            temp += percentValue[i]
            curValues.append(temp)
        }

        for i in 0 ... curValue.count-1 {
            if i != 0{
                layers[i].strokeEnd = curValues[i-1]
                layers[i].strokeStart = curValues[i-1]
            }
            animate(curValues[i], layer: layers[i])
        }
        
    }
    
    private func animate(curValue: CGFloat, layer: CAShapeLayer) {
        var fromValue = layer.strokeEnd
        let toValue = curValue
        if let presentationLayer = layer.presentationLayer() as? CAShapeLayer {
            fromValue = presentationLayer.strokeEnd
        }
        let percentChange = abs(fromValue - toValue)
        
        // 1
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        // 2
        animation.duration = CFTimeInterval(percentChange * 2)
        
        // 3
        layer.removeAnimationForKey("stroke")
        layer.addAnimation(animation, forKey: "stroke")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.strokeEnd = toValue
        CATransaction.commit()
    }
}
