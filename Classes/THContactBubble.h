//
//  THContactBubble.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "THBubbleStyle.h"

@class THContactBubble;

@protocol THContactBubbleDelegate <NSObject>

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble;
- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble;
- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble;

@end

@interface THContactBubble : UIView <UITextViewDelegate, UITextInputTraits>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UITextView *textView; // used to capture keyboard touches when view is selected
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) id <THContactBubbleDelegate>delegate;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic, setter=setBubbleStyle:) THBubbleStyle *style UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) THBubbleStyle *selectedStyle UI_APPEARANCE_SELECTOR;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name style:(THBubbleStyle *)style selectedStyle:(THBubbleStyle *)selectedStyle;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
