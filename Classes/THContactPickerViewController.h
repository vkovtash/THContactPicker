//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"

extern NSString *const THContactPickerContactCellReuseID;

@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readonly) THContactPickerView *contactPickerView;
@property (strong, nonatomic) NSString *placeholderString;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray<id<THContactProtocol>> *contacts;
@property (nonatomic, readonly) NSArray<id<THContactProtocol>> *selectedContacts;
@property (nonatomic, readonly) NSArray<id<THContactProtocol>> *filteredContacts;
@property (nonatomic) NSInteger selectedCount;

- (void)clearSelectedContacts:(id)sender;

#pragma mark - Methods to override
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSPredicate *)newFilteringPredicateWithText:(NSString *)text;
- (void)didChangeSelectedItems;
@end
