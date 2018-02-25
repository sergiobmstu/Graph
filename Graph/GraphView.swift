//
//  GraphView.swift
//  Graph
//
//  Created by Sergey on 23.02.2018.
//  Copyright © 2018 Sergey Kochetov. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var rpnString : String? { didSet  { setNeedsDisplay() }}
    
    @IBInspectable
    var scale: CGFloat = 25.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    @IBInspectable
    var colorAxes: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    var originSet: CGPoint? { didSet { setNeedsDisplay() } }
    
    private  var origin: CGPoint  {
        get {
            return originSet ?? CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
        set {
            originSet = newValue
        }
    }

    private var axesDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = colorAxes
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        drawCurveInRect(bounds, origin: origin, scale: scale)
    }
    
    
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat) {
        
        var xGraph, yGraph :CGFloat
        var x, y: Double
        var isFirstPoint = true

        if rpnString != nil {
            color.set()
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            
            for i in 0...Int(bounds.size.width * contentScaleFactor){
                xGraph = CGFloat(i) / contentScaleFactor
                
                x = Double ((xGraph - origin.x) / scale)
                y = calcYForX(x: x, str: rpnString!)
                guard y.isFinite else {continue}
                
                yGraph = origin.y - CGFloat(y) * scale
                
                if isFirstPoint{
                    path.move(to: CGPoint(x: xGraph, y: yGraph))
                    isFirstPoint = false
                } else {
                    path.addLine(to: CGPoint(x: xGraph, y: yGraph))
                }
            }
            path.stroke()
        }
    }
    
    
    func calcYForX(x : Double, str : String) -> Double {
        var resultedArr = [Double]()
        let arrOfsmb = str.components(separatedBy: [" "])
        
        for each in arrOfsmb {
            let count = resultedArr.count
            switch each {
            case "+":
                let op1 = resultedArr[count - 2]
                guard let op2 = resultedArr.last else {continue}
                resultedArr[count - 2] = op1 + op2
                resultedArr.remove(at: count-1)
            case "-":
                let op1 = resultedArr[count - 2]
                guard let op2 = resultedArr.last else {continue}
                resultedArr[count - 2] = op1 - op2
                resultedArr.remove(at: count-1)
            case "*":
                let op1 = resultedArr[count - 2]
                guard let op2 = resultedArr.last else {continue}
                resultedArr[count - 2] = op1 * op2
                resultedArr.remove(at: count-1)
            default:
                if each == "x" {
                    resultedArr.append(x)
                } else {
                    guard let op = Double(each) else {continue}
                    resultedArr.append(op)
                }
            }
        }
        return resultedArr[0]
    }
    
}
