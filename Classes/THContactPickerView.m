//
//  ContactPickerTextView.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerView.h"
#import "THContactBubble.h"

@interface THContactPickerView (){
    BOOL _shouldSelectTextView;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *bubblesMap;
@property (nonatomic, strong) NSMutableOrderedSet *contactKeys; // an ordered set of the keys placed in the contacts dictionary
@property (nonatomic, strong) NSMutableDictionary *contactsMap;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) THBubbleStyle *bubbleStyle;
@property (nonatomic, strong) THBubbleStyle *bubbleSelectedStyle;
@end

@implementation THContactPickerView

#define kViewPadding 5 // the amount of padding on top and bottom of the view
#define kHorizontalPadding 2 // the amount of padding to the left and right of each contact bubble
#define kVerticalPadding 4 // amount of padding above and below each contact bubble
#define kTextViewMinWidth 130

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (void)setup {
    self.viewPadding = kViewPadding;

    self.bubblesMap = [NSMutableDictionary dictionary];
    self.contactKeys = [NSMutableOrderedSet new];
    self.contactsMap = [NSMutableDictionary dictionary];

    // Create a contact bubble to determine the height of a line
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];

    // Add placeholder label
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.placeholderLabel];

    // Create TextView
    // It would make more sense to use a UITextField (because it doesnt wrap text), however, there is no easy way to detect the "delete" key press using a UITextField when there is no
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.textContainerInset = UIEdgeInsetsMake(2, 0, 0, 0);
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    [self.textView becomeFirstResponder];
    
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];

    _font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self applyFontSettings];
}

#pragma mark - Public functions

- (NSArray<id<THContactProtocol>> *)contacts {
    return self.contactsMap.allValues;
}

- (NSUInteger)contactCount {
    return self.contactKeys.count;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}

- (UIColor *)placeholderTextColor {
    return self.placeholderLabel.textColor;
}

- (UIColor *)textColor {
    return self.textView.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    self.textView.textColor = textColor;
}

- (void)disableDropShadow {
    CALayer *layer = [self layer];
    [layer setShadowRadius:0];
    [layer setShadowOpacity:0];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self applyFontSettings];
}

- (void)applyFontSettings {
    UIFont *currentFont = self.font;

    // Create a contact bubble to determine the height of a line
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"S"];
    [contactBubble setFont:currentFont];
    self.lineHeight = CGRectGetHeight(contactBubble.bounds) + 2 * kVerticalPadding;

    self.textView.font = currentFont;
    [self.textView sizeToFit];

    for (THContactBubble *contactBubble in self.bubblesMap.allValues) {
        [contactBubble setFont:currentFont];
    }

    self.placeholderLabel.font = currentFont;
    self.placeholderLabel.frame = CGRectMake(6, self.viewPadding, self.frame.size.width, self.lineHeight);
    [self layoutView];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.textView.tintColor = tintColor;
}

- (void)addContact:(id<THContactProtocol>)contact {
    id<NSCopying> contactKey = contact.th_contactKey;
    if ([self.contactKeys containsObject:contactKey]){
        NSLog(@"Cannot add the same object twice to ContactPickerView");
        return;
    }

    //hiding glitches on text changes
    self.textView.alpha = 0;
    [self resetText];
    __block __typeof(&*self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.textView.alpha = 1;
    }];

    THContactBubble *contactBubble =
        [[THContactBubble alloc] initWithName:contact.th_contactTitle
                                        style:self.bubbleStyle
                                selectedStyle:self.bubbleSelectedStyle];

    contactBubble.keyboardAppearance = self.keyboardAppearance;
    if (self.font != nil){
        [contactBubble setFont:self.font];
    }
    contactBubble.delegate = self;
    [self.bubblesMap setObject:contactBubble forKey:contactKey];
    [self.contactsMap setObject:contact forKey:contactKey];
    [self.contactKeys addObject:contactKey];

    // update layout
    [self layoutView];

    // scroll to bottom
    _shouldSelectTextView = YES;
    [self scrollToBottomWithAnimation:YES];
    // after scroll animation [self selectTextView] will be called
}

- (void)removeContactByKey:(id<NSCopying>)contactKey {
    if (!contactKey) {
        return;
    }

    // Remove contactBubble from view
    THContactBubble *contactBubble = [self.bubblesMap objectForKey:contactKey];
    [contactBubble removeFromSuperview];

    // Remove contact from memory
    id contact = [self.contactsMap objectForKey:contactKey];

    [self.bubblesMap removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];
    [self.contactsMap removeObjectForKey:contactKey];

    if (contact && [self.delegate respondsToSelector:@selector(contactPickerDidRemoveContact:)]) {
        [self.delegate contactPickerDidRemoveContact:contact];
    }

    __block __typeof(&*self) weakSelf = self;
    [UIView performWithoutAnimation:^{
        [weakSelf.textView becomeFirstResponder];
    }];

    self.textView.hidden = NO;
    [self resetText];

    // update layout
    [self layoutView];

    [self scrollToBottomWithAnimation:NO];
}

- (void)removeContact:(id<THContactProtocol>)contact {
    [self removeContactByKey:contact.th_contactKey];
}

- (void)removeAllContacts {
    for(id<NSCopying> contactKey in [self.bubblesMap allKeys]){
        THContactBubble *contactBubble = [self.bubblesMap objectForKey:contactKey];
        [contactBubble removeFromSuperview];
    }
    [self.bubblesMap removeAllObjects];
    [self.contactsMap removeAllObjects];
    [self.contactKeys removeAllObjects];

    // update layout
    [self layoutView];

    self.textView.hidden = NO;
    [self resetText];
}

- (BOOL)containsContact:(id<THContactProtocol>)contact {
    return [self.contactKeys containsObject:contact.th_contactKey];
}

- (void)selectTextView {
    self.textView.hidden = NO;
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    self.placeholderLabel.text = placeholderString;

    [self layoutView];
}

- (void)resignKeyboard {
    [self.textView resignFirstResponder];
}

- (void)setViewPadding:(CGFloat)viewPadding {
    _viewPadding = viewPadding;

    [self layoutView];
}

#pragma mark - Private functions

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    if (animated){
        CGSize size = self.scrollView.contentSize;
        CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);

        [self.scrollView scrollRectToVisible:frame animated:animated];
    } else {
        // this block is here because scrollRectToVisible with animated NO causes crashes on iOS 5 when the user tries to delete many contacts really quickly
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = offset;
    }
}

- (void)removeContactBubble:(THContactBubble *)contactBubble {
    __block id contactKey = nil;
    [self.bubblesMap enumerateKeysAndObjectsUsingBlock:^(id key, THContactBubble *bubble, BOOL *stop) {
        if ([bubble isEqual:contactBubble]) {
            contactKey = key;
            *stop = YES;
        }
    }];

    [self removeContactByKey:contactKey];
}

- (void)layoutView {
    CGRect frameOfLastBubble = CGRectNull;
    int lineCount = 0;

    // Loop through selectedContacts and position/add them to the view
    for (id contactKey in self.contactKeys) {
        THContactBubble *contactBubble = (THContactBubble *)[self.bubblesMap objectForKey:contactKey];
        CGRect bubbleFrame = contactBubble.frame;

        if (CGRectIsNull(frameOfLastBubble)){ // first line
            bubbleFrame.origin.x = kHorizontalPadding;
            bubbleFrame.origin.y = kVerticalPadding + self.viewPadding;
        } else {
            // Check if contact bubble will fit on the current line
            CGFloat width = bubbleFrame.size.width + 2 * kHorizontalPadding;
            if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0){ // add to the same line
                // Place contact bubble just after last bubble on the same line
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else { // No space on line, jump to next line
                lineCount++;
                bubbleFrame.origin.x = kHorizontalPadding;
                bubbleFrame.origin.y = (lineCount * self.lineHeight) + kVerticalPadding + 	self.viewPadding;
            }
        }
        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;
        // Add contact bubble if it hasn't been added
        if (contactBubble.superview == nil){
            [self.scrollView addSubview:contactBubble];
        }
    }

    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    CGFloat textViewHeight = self.lineHeight - 2 * kVerticalPadding;
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, textViewHeight);
    // Check if we can add the text field on the same line as the last contact bubble
    if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x;
    } else { // place text view on the next line
        lineCount++;
        if (self.bubblesMap.count == 0){
            lineCount = 0;
        }

        textViewFrame.origin.x = kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding;
    }
    self.textView.frame = textViewFrame;
    self.textView.center = CGPointMake(self.textView.center.x, lineCount * self.lineHeight + textViewHeight / 2 + kVerticalPadding + self.viewPadding);

    // Add text view if it hasn't been added
    if (self.textView.superview == nil){
        [self.scrollView addSubview:self.textView];
    }

    // Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
    if (self.limitToOne && self.bubblesMap.count >= 1){
        self.textView.hidden = YES;
        lineCount = 0;
    }

    // Adjust scroll view content size
    CGRect frame = self.bounds;
    CGFloat maxFrameHeight = 2 * self.lineHeight + 2 * self.viewPadding; // limit frame to two lines of content
    CGFloat newHeight = (lineCount + 1) * self.lineHeight + 2 * self.viewPadding;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, newHeight);

    // Adjust frame of view if necessary
    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
    if (self.frame.size.height != newHeight){
        // Adjust self height
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight;
        self.frame = selfFrame;

        // Adjust scroll view height
        frame.size.height = newHeight;
        self.scrollView.frame = frame;

        if ([self.delegate respondsToSelector:@selector(contactPickerDidResize:)]){
            [self.delegate contactPickerDidResize:self];
        }
    }

    // Show placeholder if no there are no contacts
    if (self.bubblesMap.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)resetText {
    self.textView.text = @"";
    [self contactPickerTextViewDidChange];
}

#pragma mark - Delagate helpers

- (void)contactPickerTextViewDidChange {
    if ([self.delegate respondsToSelector:@selector(contactPickerTextViewDidChange:)]){
        [self.delegate contactPickerTextViewDidChange:self.textView.text];
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
        // If no contacts are selected, select the last contact
        self.selectedContactBubble = [self.bubblesMap objectForKey:[self.contactKeys lastObject]];
        [self.selectedContactBubble select];
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self contactPickerTextViewDidChange];

    if ([textView.text isEqualToString:@""] && self.bubblesMap.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - THContactBubbleDelegate Functions

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        [self.selectedContactBubble unSelect];
    }
    self.selectedContactBubble = contactBubble;
    self.textView.hidden = YES;
    [self resetText];
}

- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble {
    self.textView.hidden = NO;
    [self resetText];
}

- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble {
    [self removeContactBubble:contactBubble];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.contactKeys.count == 1) {
        return;
    }
    [self scrollToBottomWithAnimation:YES];

    // Show textField
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];

    // Unselect contact bubble
    [self.selectedContactBubble unSelect];
    self.selectedContactBubble = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextView){
        _shouldSelectTextView = NO;
        [self selectTextView];
    }
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textView.keyboardAppearance = keyboardAppearance;
    for (THContactBubble *bubble in self.bubblesMap) {
        bubble.keyboardAppearance = keyboardAppearance;
    }
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.textView.keyboardAppearance;
}

@end
