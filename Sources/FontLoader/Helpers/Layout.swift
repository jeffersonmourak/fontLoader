//
//  Layout.swift
//  
//
//  Created by Jefferson Oliveira on 5/13/24.
//

import Foundation


fileprivate func calculateBaselineFromHhea(_ horizontalMetrics: HheaTable, _ fontInfo: HeadTable) -> CGFloat {
    let ascent = CGFloat(horizontalMetrics.ascent)
    let descent = CGFloat(horizontalMetrics.descent)
    let lineGap = CGFloat(horizontalMetrics.lineGap)
    
    return (ascent + descent + lineGap)
}

public struct FontLayout {
    public let baseline: CGFloat
    public let height: CGFloat
    public let width: CGFloat
    public let unitsPerEm: CGFloat
    public let horizontalMetrics: HheaTable
    public let fontInfo: HeadTable
    
    init(usingHeader horizontalMetrics: HheaTable, usingInfo fontInfo: HeadTable) {
        self.horizontalMetrics = horizontalMetrics
        self.fontInfo = fontInfo
        self.baseline = calculateBaselineFromHhea(horizontalMetrics, fontInfo)
        
        self.width = CGFloat(fontInfo.xMax)
        self.height = CGFloat(horizontalMetrics.ascent) - CGFloat(horizontalMetrics.lineGap)
        self.unitsPerEm = CGFloat(fontInfo.unitsPerEm)
    }
}
