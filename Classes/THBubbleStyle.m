//
//  THBubbleColor.m
//  ContactPicker
//
//  Created by Dmitry Vorobjov on 12/6/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THBubbleStyle.h"

@implementation THBubbleStyle

- (instancetype)initWithTextColor:(UIColor *)textColor
                      gradientTop:(UIColor *)gradientTop
                   gradientBottom:(UIColor *)gradientBottom
                      borderColor:(UIColor *)borderColor
                       borderWith:(CGFloat)borderWidth
               cornerRadiusFactor:(CGFloat)cornerRadiusFactor {
    self = [super init];
    
    if (self) {
        self.textColor = textColor;
        self.gradientTop = gradientTop;
        self.gradientBottom = gradientBottom;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.cornerRadiusFactor = cornerRadiusFactor;
    }
    return self;
}

@end
