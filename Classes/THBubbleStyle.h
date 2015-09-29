//
//  THBubbleColor.h
//  ContactPicker
//
//  Created by Dmitry Vorobjov on 12/6/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THBubbleStyle : NSObject

@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *gradientTop;
@property (strong, nonatomic) UIColor *gradientBottom;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat cornerRadiusFactor;

- (instancetype)initWithTextColor:(UIColor *)textColor
                      gradientTop:(UIColor *)gradientTop
                   gradientBottom:(UIColor *)gradientBottom
                      borderColor:(UIColor *)borderColor
                       borderWith:(CGFloat)borderWidth
               cornerRadiusFactor:(CGFloat)cornerRadiusFactor;
@end
