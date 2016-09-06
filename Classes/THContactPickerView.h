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

@protocol THContactProtocol <NSObject>
@property (readonly, nonatomic) id<NSCopying> th_contactKey;
@property (readonly, nonatomic) NSString *th_contactTitle;
@end

@protocol THContactPickerDelegate <NSObject>
- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(id<THContactProtocol>)contact;
- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView;
@end


@interface THContactPickerView : UIView <UITextViewDelegate, UIScrollViewDelegate, UITextInputTraits, THContactBubbleDelegate>
@property (strong, nonatomic) THContactBubble *selectedContactBubble;
@property (readonly, nonatomic) NSArray<id<THContactProtocol>> *contacts;
@property (readonly, nonatomic) NSUInteger contactCount;
@property (weak, nonatomic) IBOutlet id <THContactPickerDelegate> delegate;
@property (assign, nonatomic) BOOL limitToOne;
@property (assign, nonatomic) CGFloat viewPadding;
@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

- (void)addContact:(id<THContactProtocol>)contact;
- (void)removeContact:(id<THContactProtocol>)contact;
- (void)removeContactByKey:(id<NSCopying>)contactKey;
- (void)removeAllContacts;
- (BOOL)containsContact:(id<THContactProtocol>)contact;
- (void)setPlaceholderString:(NSString *)placeholderString;
- (void)disableDropShadow;
- (void)resignKeyboard;
@end
