//
//  ContactPickerTextView.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactBubble.h"

@class THContactPickerView;

@protocol THContactPickerDelegate <NSObject>

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(id)contact;
- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView;

@end

@interface THContactPickerView : UIView <UITextViewDelegate, THContactBubbleDelegate, UIScrollViewDelegate, UITextInputTraits>

@property (strong, nonatomic) THContactBubble *selectedContactBubble;
@property (assign, nonatomic) IBOutlet id <THContactPickerDelegate> delegate;
@property (assign, nonatomic) BOOL limitToOne;
@property (assign, nonatomic) CGFloat viewPadding;
@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (void)setPlaceholderString:(NSString *)placeholderString;
- (void)disableDropShadow;
- (void)resignKeyboard;
@end
