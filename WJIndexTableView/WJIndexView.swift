//
//  WJIndexView.swift
//  WJIndexTableView
//
//  Created by ulinix on 2017-12-26.
//  Copyright © 2017 wjq. All rights reserved.
//

import UIKit
import Foundation

protocol WJIndexViewDataSource: NSObjectProtocol {
    func sectionIndexTitlesForMJNIndexView(_ indexView: WJIndexView) -> [String]
    func sectionForSectionMJNIndexTitle(_ title: String, _ atIndex:NSInteger)->()
}

class WJIndexView: UIControl {

    public weak var dataSource: WJIndexViewDataSource?{
        didSet{
            self.indexItems = (self.dataSource?.sectionIndexTitlesForMJNIndexView(self))!
        }
    }
    
    // set this to NO if you want to get selected items during the pan (default is true)
    public var isGetSelectedItemsAfterPanGestureIsFinished: Bool
    
    /* set the font and size of index items (if font size you choose is too large it will be automatically adjusted to the largest possible)
     (default is HelveticaNeue 15.0 points)*/
    public var font: UIFont
    
    /* set the font of the selected index item (usually you should choose the same font with a bold style and much larger)
     (default is the same font as previous one with size 40.0 points) */
    public var selectedItemFont :UIFont
    
    // set the color for index items
    var fontColor: UIColor?{
        didSet{
            if (fontColor?.isEqual(UIColor.gray))! {
                self.fontColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            } else if (fontColor?.isEqual(UIColor.black))! {
                self.fontColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            } else if (fontColor?.isEqual(UIColor.white))! {
                self.fontColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    // set if items in index are going to darken during a pan (default is true)
    public var darkening :Bool
    
    // set if items in index are going ti fade during a pan (default is true)
    public var fading :Bool
    
    // set the color for the selected index item
    public var selectedItemFontColor :UIColor
   
    // set index items aligment (NSTextAligmentLeft, NSTextAligmentCenter or NSTextAligmentRight - default is NSTextAligmentCenter)
    public var itemsAligment :NSTextAlignment?
    
    // set the right margin of index items (default is 10.0 points)
    //设置索引项的右边界(默认值为10.0点)
    public var rightMargin: CGFloat
    
    /* set the upper margin of index items (default is 20.0 points)
     please remember that margins are set for the largest size of selected item font
     设置索引项的上边界(默认值为20.0点)
     */
    public var upperMargin: CGFloat
   
    /* set the lower margin of index items (default is 20.0 points)
     please remember that margins are set for the largest size of selected item font
     设置索引项的xia边界(默认值为20.0点)
     */
    public var lowerMargin :CGFloat
    
    // set the maximum amount for item deflection (default is 75.0 points)
    public var maxItemDeflection :CGFloat
    
    // set the number of items deflected below and above the selected one (default is 3 items)
    public var rangeOfDeflection :Int
  
    // set the curtain color if you want a curtain to appear (default is none)
    public var curtainColor :UIColor?
    
    // set the amount of fading for the curtain between 0 to 1 (default is 0.2)
    public var curtainFade: CGFloat
  
    // set if you need a curtain not to hide completely (default is false)
    public var curtainStays :Bool
    
    // set if you want a curtain to move while panning (default is false)
    public var curtainMoves :Bool
    
    // set if you need a curtain to have the same upper and lower margins (default is false)
    public var curtainMargins :Bool
    
    // set the minimum gap between item (default is 5.0 points)
    public var minimumGapBetweenItems :CGFloat
    
    // set this property to YES and it will automatically set margins so that gaps between items are set to the minimumItemGap value (default is YES)
    public var ergonomicHeight :Bool
    
    // set the maximum height for index egronomicHeight - it might be useful for iPad (default is 400.0 ponts)
    public var maxValueForErgonomicHeight :CGFloat
    
    /*
       **
     */

    
    fileprivate var indexItems: [String]?
    fileprivate var itemsAtrributes = [Any]()
    fileprivate var section: NSNumber?
    // sizes for items
    fileprivate var itemsOffset : CGFloat
    fileprivate var firstItemOrigin : CGPoint?
    fileprivate var indexSize : CGSize?
    fileprivate var maxWidth : CGFloat
    fileprivate var maxHeight : CGFloat
    fileprivate var animate : Bool
    fileprivate var actualRangeOfDeflection : Int?
    // curtain properties
    fileprivate var gradientLayer: CAGradientLayer?
    fileprivate var curtain : Bool
    fileprivate var curtainFadeFactor : CGFloat?
    // easter eggs properties
    fileprivate var dot : Bool
    fileprivate var times :Int
    
    
    /*
      **getter
     */
    public func getFontColor() -> UIColor {
        if fontColor == nil{
            self.fontColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        return fontColor!
    }
    
    public func getSelectedItemFontColor() -> UIColor {
//        if selectedItemFontColor == nil{
            self.selectedItemFontColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        }
        return selectedItemFontColor
    }
    
    /*
      *setter
     */
    public   func InitSetCurtainColor(_ curtainColor :UIColor ){
        self.curtainColor = curtainColor
    }
    
    public   func InitSetFontColor(fontColor :UIColor){
        // we need to convert grayColor, whiteColor and blackColor to RGB;
        if (fontColor.isEqual(UIColor.gray)) {
            self.fontColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        } else if (fontColor.isEqual(UIColor.black)) {
            self.fontColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else if (fontColor.isEqual(UIColor.white)) {
            self.fontColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else{
            self.fontColor = fontColor
        }
    }

    public  func InitSetCurtainFade(_ curtainFade:Float) {
        if ((self.gradientLayer) != nil) {
            self.gradientLayer?.removeFromSuperlayer()
            self.gradientLayer = nil;
        }
        self.curtainFade = CGFloat(curtainFade)
    }
    
    public func initSetDataSource(_ dataSource:WJIndexViewDataSource){
        self.dataSource = dataSource
        self.indexItems = dataSource.sectionIndexTitlesForMJNIndexView(self)
    }
    // use this method if you want to change index items or change some properties for layout
    func refreshIndexItems() {
    }
    
    override init(frame: CGRect) {
       
        darkening = true
        fading = true
        itemsAligment = .center
        upperMargin = 20.0;
        lowerMargin = 20.0;
        rightMargin = 10.0;
        maxItemDeflection = 100.0;
        rangeOfDeflection = 3;
        font = UIFont.init(name: "HelveticaNeue", size: 15.0)!
        
        selectedItemFont = UIFont.init(name: "HelveticaNeue", size: 15.0)!
        ergonomicHeight = true
        maxValueForErgonomicHeight = 400.0
        minimumGapBetweenItems = 5.0
        isGetSelectedItemsAfterPanGestureIsFinished = true
        itemsOffset = 0.0
        curtainColor = .clear
        curtainFade = 0.2
        curtainStays = false
        curtainMoves = false
        curtainMargins = false
        animate = true
        curtain = false
        dot = false
        itemsAtrributes = [NSCache<AnyObject, AnyObject>]()
        
        maxWidth  = 0.0
        maxHeight = 0.0
        times = 0
        selectedItemFontColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
         super.init(frame: frame)
         self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToSuperview() {
        getAllItemsSize()
        initialiseAllAttributes()
        resetPosition()
    }
    
    func getAllItemsSize() {
        var indexSize = CGSize.zero
        let lineHeight = self.font.lineHeight
        var maxlineHeight = self.selectedItemFont.capHeight
        let capitalLetterHeight = self.font.ascender
        let ascender = self.font.ascender
        let descender = -self.font.descender
        var entireHeight = ascender
        
        //检查大写字母和小写字母，并设置整个高度值
        if checkForLowerCase() && checkForUpperCase() {
            entireHeight = lineHeight
            maxlineHeight = self.selectedItemFont.lineHeight
        } else if checkForLowerCase() && !checkForUpperCase(){
            entireHeight = capitalLetterHeight + descender
            maxlineHeight = self.selectedItemFont.lineHeight
        }
        
        //计算所有索引项的大小
        for item: String in self.indexItems! {
            let currentItemSize : CGSize = item.size(withAttributes: [NSAttributedString.Key.font:font])
            if currentItemSize.height < 5.0 {
                return
            }
            indexSize.height += entireHeight
            if currentItemSize.width > indexSize.width {
                indexSize.width = currentItemSize.width
            }
        }
        
        //根据选择项的字体大小，计算是否使用了最长索引项的宽度。
        for item: String in indexItems! {
            let currentItemSize : CGSize = item.size(withAttributes: [NSAttributedString.Key.font:font])
            if currentItemSize.width > self.maxWidth {
                self.maxWidth = currentItemSize.width
            }
            if currentItemSize.width > self.maxItemDeflection {
                self.maxItemDeflection = currentItemSize.width
            }
            if currentItemSize.width > self.maxHeight{
                self.maxHeight = currentItemSize.width
            }
         }
        
        
        //确保最小偏移量为5.0点
         var optimalIndexHeight = indexSize.height
        if (optimalIndexHeight > self.maxValueForErgonomicHeight){
            optimalIndexHeight = self.maxValueForErgonomicHeight
        }
         let offsetRatio = self.minimumGapBetweenItems * CGFloat(self.indexItems!.count-1) + optimalIndexHeight + maxlineHeight/1.5
        if (self.ergonomicHeight && self.bounds.size.height - offsetRatio > 0) {
            self.upperMargin = (self.bounds.size.height - offsetRatio)/2
            self.lowerMargin = self.upperMargin
        }
        
        
        // checking if self.font size is not to large to draw entire index - if it's calculating the largest possible using recurency
        if indexSize.height > self.bounds.size.height - (self.upperMargin + self.lowerMargin) - (self.minimumGapBetweenItems * CGFloat((self.indexItems?.count)!)) {
            self.font = self.font.withSize(self.font.pointSize)
            self.getAllItemsSize()
        } else {
            self.itemsOffset = ((self.bounds.size.height - (self.upperMargin + self.lowerMargin + maxlineHeight / 1.5)) - indexSize.height) / CGFloat((self.indexItems?.count)!-1)
            
            
            if self.itemsAligment == .right{
                self.firstItemOrigin = CGPoint(x: self.bounds.size.width-self.rightMargin, y: self.upperMargin + maxlineHeight/2.5 + entireHeight/2)
            }else if self.itemsAligment == .center {
                 self.firstItemOrigin = CGPoint(x: self.bounds.size.width - CGFloat(self.rightMargin) - indexSize.width/2, y: CGFloat(self.upperMargin + maxlineHeight / 2.5 + entireHeight/2))
            }else{
                self.firstItemOrigin = CGPoint.init(x: self.bounds.size.width - CGFloat(self.rightMargin) - indexSize.width, y: CGFloat(self.upperMargin + maxlineHeight/2.5 + entireHeight/2))
            }
            
            self.itemsOffset += entireHeight;
            self.indexSize = indexSize;
            
        }
        
        //checking if range of items to deflect is not too big检查是否有偏离的范围不太大
        if self.indexItems?.count == 1 {
            self.actualRangeOfDeflection = 0
        } else if self.rangeOfDeflection > (self.indexItems?.count)!/2-1{
            self.actualRangeOfDeflection = (self.indexItems?.count)!/2
        }else{
            self.actualRangeOfDeflection = self.rangeOfDeflection
        }
    
    }
    
    fileprivate func initialiseAllAttributes() {
        var verticalPos  = CGFloat((self.firstItemOrigin?.y)!)
        var newItemsAttributes = [NSCache<AnyObject, AnyObject>]()
        var count: Int = 0
        for item in indexItems! {
            // calculating items origins based on items aligment and firstItemOrigin
            var point: CGPoint = CGPoint.zero
            if itemsAligment == .center {
            
                let itemSize: CGSize = item.size(withAttributes: [NSAttributedString.Key.font:font])
                point.x = (firstItemOrigin?.x)! - itemSize.width / 2
            }else if itemsAligment == .right {
                
                let itemSize: CGSize = item.size(withAttributes: [NSAttributedString.Key.font:font])
                point.x = (firstItemOrigin?.x)! - itemSize.width
            } else {
                point.x = (firstItemOrigin?.x)!
            }
            
            point.y = verticalPos
            let newValueForPoint = NSValue(cgPoint: point)
            
            if self.itemsAtrributes.count < 0 {
                let singleItemTextLayer = CATextLayer()
                let alpha = NSNumber.init(value:Float((self.fontColor?.cgColor.alpha)!))
                // setting zPosition a little above because we might need to put something below
                let zPosition = 5.0
                let itemAttributes : NSCache<AnyObject, AnyObject> = NSCache<AnyObject, AnyObject>()
                itemAttributes.setObject(item as AnyObject, forKey: "item" as AnyObject)
                itemAttributes.setObject(newValueForPoint, forKey: "origin" as AnyObject)
                itemAttributes.setObject(newValueForPoint, forKey: "position" as AnyObject)
                itemAttributes.setObject(alpha, forKey: "alpha" as AnyObject)
                itemAttributes.setObject(zPosition as AnyObject, forKey: "zPosition" as AnyObject)
                itemAttributes.setObject(singleItemTextLayer, forKey: "layer" as AnyObject)
                itemAttributes.setObject(self.fontColor!, forKey: "color" as AnyObject)
                itemAttributes.setObject(CTFontCreateWithName((font.fontName as CFString?)! , (font.pointSize), nil), forKey: "font" as AnyObject)
                itemAttributes.setObject(NSNumber.init(value:Float(font.pointSize)), forKey: "fontSize" as AnyObject)
                newItemsAttributes.append(itemAttributes);
                
            }else {
                let attCach = self.itemsAtrributes[count]
                var origin:CGPoint = (attCach as AnyObject).object(forKey: "origin" as AnyObject) as! CGPoint
                var poins:CGPoint = (attCach as AnyObject).object(forKey: "position" as AnyObject) as! CGPoint
                origin = newValueForPoint as! CGPoint
                poins = newValueForPoint as! CGPoint
            }
            verticalPos += itemsOffset
            count += 1
        }
        
        if self.curtainColor != nil {
            self.addCurtain()
        }
        if self.itemsAtrributes.count < 1 {
            self.itemsAtrributes = newItemsAttributes
        }
    }
    
    fileprivate func resetPosition() {
        for itemAttribute in self.itemsAtrributes{
            let origin:CGPoint = (itemAttribute as AnyObject).object(forKey: "origin" as AnyObject) as! CGPoint
            (itemAttribute as AnyObject).setObject(CTFontCreateWithName((font.fontName as CFString?)!, (font.pointSize), nil), forKey: "font" as AnyObject)
            (itemAttribute as AnyObject).setObject(NSValue.init(cgPoint: origin), forKey: "position" as AnyObject)
            (itemAttribute as AnyObject).setObject(NSNumber.init(value: 1.0), forKey: "alpha" as AnyObject)
            (itemAttribute as AnyObject).setObject(NSNumber.init(value: 5.0), forKey: "zPosition" as AnyObject)
            (itemAttribute as AnyObject).setObject(self.fontColor!, forKey: "color" as AnyObject)
            
        }
        
        self.drawIndex();
        self.setNeedsDisplay();
        
        self.animate = true;
    }
    
    // MARK: ---- calculating item position during the pan gesture
    fileprivate func positionForIndexItemsWhilePanLocation(location : CGPoint){
        
        var verticalPos = CGFloat(self.firstItemOrigin!.y);
        
        var section:Int = 0
        for itemAttribute in self.itemsAtrributes {
            
            var alpha:CGFloat = (itemAttribute as AnyObject).object(forKey: "alpha" as AnyObject) as! CGFloat
            var point:CGPoint = (itemAttribute as AnyObject).object(forKey: "position" as AnyObject) as! CGPoint
            let origin:CGPoint = (itemAttribute as AnyObject).object(forKey: "origin" as AnyObject) as! CGPoint
            var fontSize:CGFloat = (itemAttribute as AnyObject).object(forKey: "fontSize" as AnyObject) as! CGFloat
            var fontColor:UIColor
            
            var inRange:Bool = false
            
            // we have to map amplitude of deflection
            if let actualRangeOfDeflectionT = self.actualRangeOfDeflection{
                
                let mappedAmplitude:CGFloat = self.maxItemDeflection / self.itemsOffset / CGFloat(actualRangeOfDeflectionT)
                
                // now we are checking if touch is within the range of items we would like to deflect
                let Min:Bool = location.y > point.y - CGFloat(actualRangeOfDeflectionT) * self.itemsOffset
                let Max:Bool = location.y < point.y + CGFloat(actualRangeOfDeflectionT) * self.itemsOffset
                
                if (Min && Max) {
                    
                    // these calculations are necessary to make our deflection not linear
                    let differenceMappedToAngle:CGFloat = 90.0 / (self.itemsOffset * CGFloat(actualRangeOfDeflectionT));
                    let angle:CGFloat = (CGFloat(fabs(point.y - location.y))*differenceMappedToAngle);
                    let angleInRadians:CGFloat = angle * CGFloat(Double.pi/180);
                    let arcusTan:CGFloat = fabs(atan(angleInRadians));
                    
                    // now we have to calculate the deflected position of an item
                    point.x = origin.x - CGFloat(self.maxItemDeflection) + CGFloat(CGFloat(fabsf(Float(point.y - location.y))) * CGFloat(mappedAmplitude)) * CGFloat(arcusTan)
                    
                    point.x = min( point.x, origin.x)
                    
                    
                    // we have to map difference to range in order to determine right zPosition
                    let differenceMappedToRange:CGFloat = CGFloat(actualRangeOfDeflectionT) / (CGFloat(actualRangeOfDeflectionT) * self.itemsOffset)
                    
                    let zPosition:CGFloat = CGFloat(actualRangeOfDeflectionT) - CGFloat(fabs(point.y - location.y)) * differenceMappedToRange;
                    let cach = NSCache<AnyObject, AnyObject>.init()
                    cach.setObject(NSNumber(value: Float(5 + zPosition)), forKey: "zPosition" as AnyObject)
                    
                    // calculating a fontIncrease factor of the deflected item
                    var fontIncrease:CGFloat = (self.maxItemDeflection - CGFloat(fabs(point.y - location.y)) *
                        mappedAmplitude) / (self.maxItemDeflection / CGFloat(self.selectedItemFont.pointSize - (self.font.pointSize)))
                    
                    fontIncrease = max(fontIncrease, 0.0)
                    
                    fontSize = self.font.pointSize + fontIncrease;
                    cach.setObject(NSNumber(value:Float(fontSize)), forKey: "fontSize" as AnyObject)
                    itemsAtrributes.append(cach)
                    
                    // calculating a color darkening factor
                    let differenceMappedToColorChange:Float = Float(1.0 / (CGFloat(actualRangeOfDeflectionT) * self.itemsOffset));
                    let colorChange:Float = Float(fabs(point.y - location.y)) * differenceMappedToColorChange;
                    
                    if (self.darkening) {
                        fontColor = self.darkerColor(self.fontColor!, byvalue: colorChange)
                    } else{
                        fontColor = self.fontColor!
                    }
                    
                    // we're using the same factor for alpha (fading)
                    if (self.fading) {
                        alpha = CGFloat(colorChange)
                    } else{
                        alpha = 1.0
                    }
                    (itemAttribute as AnyObject).setObject(CTFontCreateWithName((font.fontName as CFString?)!, (font.pointSize), nil), forKey: "font" as AnyObject)
                    (itemAttribute as AnyObject).setObject(fontColor, forKey: "color" as AnyObject)
                    
                    // checking if the item is the most deflected one -> it means it is the selected one
                    let selectedInRange:Bool  = location.y > point.y - CGFloat( self.itemsOffset / 2.0) && location.y < point.y + CGFloat(self.itemsOffset / 2.0);
                    // we need also to check if the selected item is the first or the last one in the index
                    let firstItemInRange:Bool = (section == 0 && (location.y < CGFloat(self.upperMargin) + (self.selectedItemFont.pointSize) / 2.0));
                    let lastItemInRange:Bool = (section == self.itemsAtrributes.count - 1 &&
                        location.y > (self.bounds.size.height - (CGFloat(self.lowerMargin) + self.selectedItemFont.pointSize / 2.0)))
                    // if our location is pointing to the selected item we have to change this item's font, color and make it's zPosition the largest to be sure it's on the top
                    if (selectedInRange || firstItemInRange || lastItemInRange) {
                        alpha = 1.0;
                        (itemAttribute as AnyObject).setObject(CTFontCreateWithName((self.selectedItemFont.fontName as CFString?)!, (font.pointSize), nil), forKey: "font" as AnyObject)
                        (itemAttribute as AnyObject).setObject(selectedItemFontColor, forKey: "color" as AnyObject)
                        (itemAttribute as AnyObject).setObject(NSNumber.init(value: 10.0) as AnyObject, forKey: "zPosition" as AnyObject)
                        if (!self.isGetSelectedItemsAfterPanGestureIsFinished && Int(truncating: self.section!) != section) {
                            if let sectionTitle = self.indexItems?[section] {
                                dataSource?.sectionForSectionMJNIndexTitle(sectionTitle,section)
                                
                            }else{
                                print("hosten error 631 lines")
                            }
                        }
                        self.section = NSNumber.init(value: section);
                    }
                    // we're marking these items as inRange items
                    inRange = true
                    
                }
                
                // if item is not in range we have to reset it's x position, alpha value, font name, size and color, zPosition
                if (!inRange) {
                    
                    point.x = origin.x;
                    alpha = 1.0;
                    (itemAttribute as AnyObject).setObject(CTFontCreateWithName((self.selectedItemFont.fontName as CFString?)!, (font.pointSize), nil), forKey: "font" as AnyObject)
                    if let fontColorT = self.fontColor{
                        fontColor = fontColorT
                        (itemAttribute as AnyObject).setObject(fontColorT, forKey: "color" as AnyObject)
                        (itemAttribute as AnyObject).setObject(NSNumber.init(value: 5.0) as AnyObject, forKey: "zPosition" as AnyObject)
                        
                    }else{
                        print("hosten The font color is nill with fontColor--> \(String(describing: self.fontColor))")
                    }
                }
                // we have to store some values in itemAtrributes array
                point.y = CGFloat(verticalPos);
                let newValueForPoint: NSValue  = NSValue.init(cgPoint: point)
                (itemAttribute as AnyObject).setObject(newValueForPoint, forKey: "position" as AnyObject)
                (itemAttribute as AnyObject).setObject(NSNumber(value:Float(alpha)) as AnyObject, forKey: "alpha" as AnyObject)
                verticalPos += self.itemsOffset
                section += 1
            }else{
                print("hosten unwrapping actualRangeOfDeflection failse 687\(String(describing: self.actualRangeOfDeflection))")
            }
        }
        // when are calculations are over we can redraw all items
        self.drawIndex()
        // we set this to NO because we want the animation duration to be as short as possible
        self.animate = true;
    }
    fileprivate func darkerColor(_ color:UIColor, byvalue value :Float)->UIColor{
        
        var h:CGFloat = 1.0;
        var s:CGFloat = 1.0;
        var b:CGFloat = 1.0;
        var a:CGFloat = 1.0;
        
        if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a){
            return UIColor.init(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return UIColor.clear
    }
    
    //检查是否有任何有小写字母的项
    fileprivate func checkForLowerCase() -> Bool{
        let lowerCaseSet = CharacterSet.lowercaseLetters
        for item: String in indexItems! {
            if (item as NSString).rangeOfCharacter(from: lowerCaseSet).location != NSNotFound {
                return true
            }
        }
        return false
    }
    //检查是否有任何有大写字母的项目
    fileprivate func checkForUpperCase() -> Bool{
        let upperCaseSet = CharacterSet.uppercaseLetters
        for item: String in indexItems! {
            if (item as NSString).rangeOfCharacter(from: upperCaseSet).location != NSNotFound {
                return true
            }
        }
        return false
    }
    
    fileprivate func  drawIndex(){
       
        for itemAttribute in self.itemsAtrributes {
            let currentFont:CTFont
            if let currentFontT = (itemAttribute as AnyObject).object(forKey: "font" as AnyObject){
                currentFont = currentFontT as! CTFont
                
                var singleItemTextLayer:CATextLayer = CATextLayer.init()
                
                if let laye = (itemAttribute as AnyObject).object(forKey: "layer" as AnyObject) {
                    singleItemTextLayer = laye as! CATextLayer
                }else{
                    print( "hosten error 1 singleItemTextLayer is nil" )
                }
                // checking if all CATexts exists
                if let layerT = self.layer.sublayers {
                    if (self.itemsAtrributes.count != layerT.count - 1) {
                        self.layer.addSublayer(singleItemTextLayer)
                    }
                }else{
                    print( "hosten layer sublayers error 1")
                }
                
                
                // checking if font size is different if it's different we have to animate CALayer
                if (singleItemTextLayer.fontSize != CTFontGetSize(currentFont)) {
                    // we have to animate several CALayers at once
                    CATransaction.begin()
                    print( "hosten error 2")
                    // if we need to animate faster we're changing the duration to be as short as possible
                    
                    if (!self.animate) {
                        CATransaction.setAnimationDuration(0.005)
                    }
                    else {
                        CATransaction.setAnimationDuration(0.2);
                    }
                    
                    // getting other attributes and updading CALayer
                    
                    let point:CGPoint = (itemAttribute as AnyObject).object(forKey: "position" as AnyObject) as! CGPoint
                    let currentItem:String = (itemAttribute as AnyObject).object(forKey: "item" as AnyObject) as! String
                    let stringRef:CFString = currentItem as CFString
                    let attrStr:CFMutableAttributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
                    CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), stringRef);
                    //                let alignment:CTTextAlignment = .justified;
                    var  lineSpacing:CGFloat = 5
                    let settings = [CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value:&lineSpacing),CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing)]
                    
                    let paragraphStyle:CTParagraphStyle = CTParagraphStyleCreate(settings, 3);
                    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
                    CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, currentFont);
                    let framesetter:CTFramesetter = CTFramesetterCreateWithAttributedString(attrStr);
                    let size = CGSize.init(width:CGFloat( maxWidth), height: CGFloat(maxHeight*2.0))
                    let textSize:CGSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange.init(location: 0, length: currentItem.count), nil, size, nil)
                    
                    let fontColor:UIColor = (itemAttribute as AnyObject).object(forKey: "color" as AnyObject) as! UIColor
                    
                    singleItemTextLayer.zPosition = (itemAttribute as AnyObject).object(forKey: "zPosition" as AnyObject) as! CGFloat
                    singleItemTextLayer.font = currentFont;
                    singleItemTextLayer.fontSize = CTFontGetSize(currentFont);
                    singleItemTextLayer.opacity = (itemAttribute as AnyObject).object(forKey: "alpha" as AnyObject) as! Float
                    singleItemTextLayer.string = currentItem;
                    singleItemTextLayer.backgroundColor = UIColor.clear.cgColor;
                    singleItemTextLayer.foregroundColor = fontColor.cgColor;
                    singleItemTextLayer.bounds = CGRect.init(x: CGFloat(0.0), y: CGFloat(0.0), width: textSize.width, height: textSize.height)
                    
                    singleItemTextLayer.position = CGPoint.init(x:point.x + textSize.width/2.0,
                                                                y:point.y)
                    singleItemTextLayer.contentsScale = UIScreen.main.scale;
                    CATransaction.commit()
                    
                }
            }else{
                print( "hosten error =================== currentFont")
            }
            
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        var section:Int = 0;
        // checking if item any item is touched
        for itemAttribute in self.itemsAtrributes  {
            let point:CGPoint = (itemAttribute as AnyObject).object(forKey: "position" as AnyObject) as! CGPoint
            let location:CGPoint = touch.location(in: self)
            if (location.y > point.y - CGFloat(self.itemsOffset / 2.0)  &&
                location.y < point.y + CGFloat(self.itemsOffset / 2.0)) {
                self.section = NSNumber.init(value: section)
            }
            section += 1
        }
        self.dot = false;
        return true;
    }

    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let currentY:CGFloat = touch.location(in: self).y;
        let prevY:CGFloat = touch.previousLocation(in: self).y;
        let has = self.curtainColor?.hashValue
        
       
        if (self.curtainColor != nil) {
             self.showCurtain()
        }
        // if pan is longer than three pixel we need to accelerate animation by setting self.animate to NO
        if (fabs(currentY - prevY) > 3.0) {
            self.animate = false;
        }
        // drawing deflection
        self.positionForIndexItemsWhilePanLocation(location: touch.location(in: self))
        return true;
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if self.indexItems != nil && (self.indexItems?.count)! > 0 {
            // sending selected items to dataSource
            self.dataSource?.sectionForSectionMJNIndexTitle((self.indexItems?[Int(truncating: section!)])!, Int(section!))
            
            
            // some easter eggs ;)
            if let sectionT = section {
                if (Int(sectionT) == 3 * times) {
                    self.times += 1
                    if (self.times == 5) {
                        self.dot = true;
                        self.setNeedsDisplay()
                    }
                } else {
                    self.times = 0;
                }
            }
            
            // if pan stopped we can deacellerate animation, reset position and hide curtain
            self.animate = true
            self.resetPosition()
            if self.curtainColor != nil {
                self.hideCurtain()
            }
            
            
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        // if touch was canceled we reset everything
        self.animate = true
        self.resetPosition()
        if self.curtainColor != nil {
            self.hideCurtain()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // UIView will be "transparent" for touch events if we return NO
        // we are going to return YES only if items or area right to them is being touched
        let pintX = self.bounds.size.width - ((self.indexSize?.width)! + CGFloat( self.rightMargin + 10.0))
        if point.x > pintX && point.y > 0.0 && point.y < CGFloat(self.bounds.size.height){
            return true
        }
        //if (point.y > self.bounds.size.height) return NO;
        return false

    }
    
    fileprivate func addCurtain() {
        if curtainFade != 0.0 {
            if curtainFade > 1 {
                curtainFade = 1
            }
            if !(self.gradientLayer != nil) {
                self.gradientLayer = CAGradientLayer()
                layer.insertSublayer(gradientLayer!, at: 0)
            }
        // we have to read color components
            guard let colorComponents = curtainColor?.cgColor.components else {return}
            self.gradientLayer?.colors = [(UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 0.0).cgColor), self.curtainColor?.cgColor as Any]
            
        // calculating endPoint for gradient based on maxItemDeflection and maxWidth of longest selected item
            self.curtainFadeFactor = (self.bounds.size.width - self.rightMargin - self.maxItemDeflection - 0.25 * maxWidth - 15.0) / self.bounds.size.width
            self.gradientLayer?.startPoint = CGPoint(x: curtainFadeFactor! - (curtainFade * curtainFadeFactor!), y: 0.0)
            self.gradientLayer?.endPoint = CGPoint(x: max(curtainFadeFactor!, 0.02), y: 0.0)
       
        }else{
            if !(self.gradientLayer != nil) {
                self.gradientLayer = CAGradientLayer()
                layer.insertSublayer(gradientLayer!, at: 0)
            }
            self.gradientLayer?.backgroundColor = self.curtainColor?.cgColor
            
        }
        self.curtain = true
        
        if self.curtainColor != nil {
            self.hideCurtain()
        }
    }
    
    fileprivate func hideCurtain(){
            if self.curtain && self.curtainColor != nil {
            
                var curtainBoundsRect:CGRect
                var curtainVerticalCenter:CGFloat
                var curtainHorizontalCenter:CGFloat
                let multiplier:CGFloat = 2
            if (!self.curtainMargins) {
                let width =  (self.indexSize?.width)! * multiplier + self.rightMargin
                
                curtainBoundsRect = CGRect(x: 0, y: 0, width: width, height: self.bounds.size.height)
                
                curtainVerticalCenter = self.bounds.size.height / 2
            } else {
                // if we need cutain to have the same margins as index items we have to change its height and its vertical center
                let width = (self.indexSize?.width)! * multiplier + self.rightMargin
                let height = self.bounds.size.height - (self.upperMargin + self.lowerMargin)
                curtainBoundsRect = CGRect(x: 0, y: 0, width: width, height: height)
                curtainVerticalCenter = self.upperMargin + curtainBoundsRect.size.height / 2.0
            }
            
            
            if (!self.curtainStays) {
                curtainHorizontalCenter = self.bounds.size.width + self.bounds.size.width / 2.0;
                
            } else {
                // if we don't want the curtain to hide completely we have again to check if we need margins or not and change its height respectively
                if (self.curtainMargins) {
                    curtainBoundsRect = CGRect(x:CGFloat( 0.0), y: CGFloat(0.0), width:self.bounds.size.width, height:self.bounds.size.height - CGFloat(self.upperMargin + self.lowerMargin))
                }else{
                    curtainBoundsRect = self.bounds
                }
                
                
                // now we need to calculate an offset needed to position curtain not entirely outside the screen
                // to do this we must check items aligment and calculate horizontal center for its position
                 var offset: CGFloat
                if (self.itemsAligment == .right){
                    offset = self.bounds.size.width - (self.firstItemOrigin?.x)!  - (self.indexSize?.width)!/2.0
                }else if (self.itemsAligment == .center){
                    offset =  self.bounds.size.width - (self.firstItemOrigin?.x)!
                }else{
                    offset = self.bounds.size.width - ((self.firstItemOrigin?.x)! +  (self.indexSize?.width)!/2.0)
                }
                
                curtainHorizontalCenter = (self.bounds.size.width + self.bounds.size.width / 2.0) -  2 * offset
                
                // if we are using CAGradientLayer we have to change horizonl center value and recalculate the start and endpoint for gradient
                if (self.gradientLayer?.isKind(of: CAGradientLayer.self))! {
                    
                    curtainHorizontalCenter = (self.bounds.size.width + self.bounds.size.width / 2.0) -  (2.0  * offset + self.curtainFade * offset);
                    self.gradientLayer?.startPoint = CGPoint(x:0.001, y:0.0)
                    let x = max(self.curtainFade, 300.0 * self.gradientLayer!.startPoint.x) * 00.1
                    self.gradientLayer?.endPoint = CGPoint(x:x, y:0.0);
                }
            }
            
            // now we can set the courtain bounds and position andset the BOOL self.curtain to NO which meanse the curtain is hidden
                self.gradientLayer?.bounds = curtainBoundsRect
                self.gradientLayer?.position = CGPoint(x:curtainHorizontalCenter, y:curtainVerticalCenter)
                self.curtain = false
        }
    }
    
    fileprivate func showCurtain(){
        
        if (!self.curtain && (self.curtainColor != nil) && self.curtainMoves && self.actualRangeOfDeflection! > 0) {
            var curtainVerticalCenter:CGFloat
            var curtainBoundsRect:CGRect
            
            // again like in case for hideCurtain we must calculate position and size for all possible configurations
            if (!self.curtainMargins) {
                curtainBoundsRect = self.bounds
                curtainVerticalCenter = self.bounds.size.height / 2.0
            } else {
                curtainBoundsRect = CGRect(x:0.0, y:self.upperMargin, width:self.bounds.size.width, height:self.bounds.size.height - (self.upperMargin + self.lowerMargin));
                curtainVerticalCenter = self.upperMargin + curtainBoundsRect.size.height / 2.0;
            }
            
            if (self.gradientLayer?.isKind(of: CAGradientLayer.self))!{
                // we need to use CATransaction because we need the animation to bee faster
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.075)
                
                self.gradientLayer?.bounds = curtainBoundsRect
                let x = max(self.curtainFadeFactor! - (self.curtainFade * self.curtainFadeFactor!),0.001)
                self.gradientLayer?.startPoint = CGPoint(x:x, y:0.0)
                self.gradientLayer?.endPoint = CGPoint(x:max(self.curtainFadeFactor!,0.3), y:0.0)
                self.gradientLayer?.position = CGPoint(x:self.bounds.size.width / 2.0, y:curtainVerticalCenter)
                CATransaction .commit()
            } else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.075)
                
                self.gradientLayer?.bounds = curtainBoundsRect;
                self.gradientLayer?.position = CGPoint(x:(CGFloat(self.bounds.size.width - CGFloat(self.rightMargin) - CGFloat(self.maxItemDeflection) - CGFloat(0.25) * CGFloat(self.maxWidth) - CGFloat(15.0)) + self.bounds.size.width / CGFloat(2.0)),y: CGFloat(curtainVerticalCenter))
                CATransaction .commit()
            };
            
            self.curtain = true
        }
    }
    
   
    fileprivate func drawLabel(_ label:String, _ font: UIFont, _ size:CGSize,
                               _ point:CGPoint, _ alignment:NSTextAlignment, _ lineBreak:NSLineBreakMode ,_ color:UIColor){
        
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        
        // save context state first
        context.saveGState()
        
        // obtain size of drawn label
        let newSize:CGSize = label.size(withAttributes: [NSAttributedString.Key.font:font])

        // determine correct rect for this label
        let rect = CGRect.init(x:point.x , y: point.y, width: newSize.width, height: newSize.height)

        // set text color in context
        context.setFillColor(color.cgColor)

        // draw text
        label.draw(in: rect, withAttributes: [NSAttributedString.Key.font:font])

        // restore context state
        context.restoreGState();
    }
    
    fileprivate func drawTestRectangle(AtPoint p:CGPoint, withSize size:CGSize, WithRed red:Float,AndGreen green:Float,andBlue blue:Float,withalpha alpha:Float){
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setFillColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        context.beginPath()
        let rect = CGRect.init(x:p.x , y: p.y, width:  size.width, height: size.height)
        context.addRect(rect)
        context.fillPath()
        context.restoreGState()
    }
    
    override func draw(_ rect: CGRect) {
        if (self.dot) {
            self.drawTestRectangle(AtPoint: CGPoint.init(x: self.bounds.size.width / 2.0 - 100.0, y:  self.bounds.size.height / 2.0 - 100.0), withSize: CGSize.init(width: 200.0, height: 200.0), WithRed: 1.0, AndGreen: 1.0, andBlue: 1.0, withalpha: 1.0)

            self.drawLabel("Index for tableView designed by mateusz@ nuckowski.com", UIFont.init(name: "HelveticaNeue-UltraLight", size: 25.0)!, CGSize.init(width: 175.0, height: 150.0), CGPoint.init(x: self.bounds.size.width / 2.0 - 78.0, y: self.bounds.size.height / 2.0 - 80.0), .center, .byWordWrapping, UIColor.init(red: 0.0, green: 105.0/255.0, blue: 240.0/255.0, alpha: 1.0))
        }
        
    }
}



























