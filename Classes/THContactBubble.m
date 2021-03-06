//
//  THContactBubble.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactBubble.h"


#define kHorizontalPadding 10
#define kVerticalPadding 2

#define kDefaultBorderWidth 1
#define kDefaultCornerRadiusFactor 2

#define k7DefaultBorderWidth 0
#define k7DefaultCornerRadiusFactor 6

#define k7ColorText [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorGradientTop nil
#define k7ColorGradientBottom nil
#define k7ColorBorder nil

#define k7ColorSelectedText [UIColor whiteColor]
#define k7ColorSelectedGradientTop [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorSelectedGradientBottom [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define k7ColorSelectedBorder nil


@implementation THContactBubble
@synthesize style = _style;
@synthesize selectedStyle = _selectedStyle;

- (id)initWithName:(NSString *)name {
    return [self initWithName:name style:nil selectedStyle:nil];
}

- (id)initWithName:(NSString *)name style:(THBubbleStyle *)style selectedStyle:(THBubbleStyle *)selectedStyle {
    self = [super init];
    if (self){
        _name = name;
        _isSelected = NO;
        [self setupView];
    }
    return self;
}

- (THBubbleStyle *)style {
    if (_style) {
        return _style;
    }

    _style = [[THBubbleStyle alloc] initWithTextColor:k7ColorText
                                          gradientTop:k7ColorGradientTop
                                       gradientBottom:k7ColorGradientBottom
                                          borderColor:k7ColorBorder
                                           borderWith:k7DefaultBorderWidth
                                   cornerRadiusFactor:k7DefaultCornerRadiusFactor];

    return _style;
}

- (void)setBubbleStyle:(THBubbleStyle *)style {
    _style = style;
    [self applySelectionStyle];
}

- (THBubbleStyle *)selectedStyle {
    if (_selectedStyle) {
        return _selectedStyle;
    }

    _selectedStyle = [[THBubbleStyle alloc] initWithTextColor:k7ColorSelectedText
                                                  gradientTop:k7ColorSelectedGradientTop
                                               gradientBottom:k7ColorSelectedGradientBottom
                                                  borderColor:k7ColorSelectedBorder
                                                   borderWith:k7DefaultBorderWidth
                                           cornerRadiusFactor:k7DefaultCornerRadiusFactor];


    return _selectedStyle;
}

- (void)setSelectedStyle:(THBubbleStyle *)selectedStyle {
    _selectedStyle = selectedStyle;
    [self applySelectionStyle];
}

- (void)setupView {
    // Create Label
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = self.name;
    [self addSubview:self.label];
    
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.hidden = YES;
    [self addSubview:self.textView];
    
    // Create a tap gesture recognizer
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [self adjustSize];
    [self applySelectionStyle];
}

- (void)adjustSize {
    // Adjust the label frames
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = kHorizontalPadding;
    frame.origin.y = kVerticalPadding;
    self.label.frame = frame;
    
    // Adjust view frame
    self.bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding, frame.size.height + 2 * kVerticalPadding);
    
    // Create gradient layer
    if (self.gradientLayer == nil){
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = self.bounds;

    // Round the corners
    CALayer *viewLayer = [self layer];
    viewLayer.masksToBounds = YES;
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;
    [self adjustSize];
}

- (void)applyStyle:(THBubbleStyle *)style {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = style.borderColor.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[style.gradientTop CGColor], (id)[style.gradientBottom CGColor], nil];
    
    self.label.textColor = style.textColor;
    self.layer.borderWidth = style.borderWidth;
    if (style.cornerRadiusFactor > 0) {
        self.layer.cornerRadius = self.bounds.size.height / style.cornerRadiusFactor;
    }
    else {
        self.layer.cornerRadius = 0;
    }
    [self setNeedsDisplay];
}

- (void)applySelectionStyle {
    THBubbleStyle *currentStyle = self.isSelected ? self.selectedStyle : self.style;
    [self applyStyle:currentStyle];
}

- (void)select {
    if ([self.delegate respondsToSelector:@selector(contactBubbleWasSelected:)]){
        [self.delegate contactBubbleWasSelected:self];
    }
    
    self.isSelected = YES;
    [self applySelectionStyle];
    
    __block __typeof(&*self) weakSelf = self;
    [UIView performWithoutAnimation:^{
        [weakSelf.textView becomeFirstResponder];
    }];
}

- (void)unSelect {
    self.isSelected = NO;
    [self applySelectionStyle];
    
    __block __typeof(&*self) weakSelf = self;
    [UIView performWithoutAnimation:^{
        [weakSelf.textView resignFirstResponder];
    }];
}

- (void)handleTapGesture {
    if (self.isSelected){
        [self unSelect];
    } else {
        [self select];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        if ([self.delegate respondsToSelector:@selector(contactBubbleShouldBeRemoved:)]){
            [self.delegate contactBubbleShouldBeRemoved:self];
        }
    }
    
    if (self.isSelected){
        self.textView.text = @"";
        [self unSelect];
        if ([self.delegate respondsToSelector:@selector(contactBubbleWasUnSelected:)]){
            [self.delegate contactBubbleWasUnSelected:self];
        }
    }
    
    return YES;
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textView.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardAppearance) keyboardAppearance {
    return self.textView.keyboardAppearance;
}

@end
