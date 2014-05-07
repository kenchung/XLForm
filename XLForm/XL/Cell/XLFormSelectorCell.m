//
//  XLFormSelectorCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Created by Martin Barreto on 31/3/14.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLForm.h"
#import "NSObject+XLFormAdditions.h"
#import "XLFormRowDescriptor.h"
#import "XLFormSelectorCell.h"

@interface XLFormSelectorCell() <XLFormOptionsViewControllerDelegate, UIActionSheetDelegate>

@end


@implementation XLFormSelectorCell


-(NSString *)valueDisplayText
{
    return (self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : self.rowDescriptor.noValueDisplayText);
}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
}

-(void)update
{
    [super update];
    
    self.accessoryType = self.rowDescriptor.disabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    [self.textLabel setText:self.rowDescriptor.title];
    self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.selectionStyle = self.rowDescriptor.disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required ? @"*" : @""];
    self.detailTextLabel.text = [self valueDisplayText];
    UIFont * labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFontDescriptor * fontDesc = [labelFont fontDescriptor];
    self.textLabel.font = [UIFont fontWithDescriptor:fontDesc size:0];
    self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeSelectorPush]){
        if (self.rowDescriptor.selectorOptions){
            XLFormOptionsViewController * optionsViewController = [[XLFormOptionsViewController alloc] initWithDelegate:self multipleSelection:NO style:UITableViewStyleGrouped titleHeaderSection:nil titleFooterSection:nil];
            optionsViewController.tag = self.rowDescriptor.tag;
            optionsViewController.title = self.rowDescriptor.selectorTitle;
            [controller.navigationController pushViewController:optionsViewController animated:YES];
        }
        else{
            XLFormSelectorTableViewController * selectorViewController = [[XLFormSelectorTableViewController alloc] initWithDelegate:self localDataLoader:self.rowDescriptor.selectorLocalDataLoader remoteDataLoader:self.rowDescriptor.selectorRemoteDataLoader];
            selectorViewController.tag = self.rowDescriptor.tag;
            selectorViewController.title = self.rowDescriptor.selectorTitle;
            selectorViewController.supportRefreshControl = self.rowDescriptor.selectorSupportRefreshControl;
            selectorViewController.loadingPagingEnabled = self.rowDescriptor.selectorLoadingPagingEnabled;
            [controller.navigationController pushViewController:selectorViewController animated:YES];
        }
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeSelectorActionSheet]){
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:self.rowDescriptor.selectorTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.tag = [self.rowDescriptor hash];
        for (id option in self.rowDescriptor.selectorOptions) {
            [actionSheet addButtonWithTitle:[option displayText]];
        }
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [actionSheet showInView:controller.view];
        [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeSelectorAlertView]){
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:self.rowDescriptor.selectorTitle message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        alertView.tag = [self.rowDescriptor hash];
        for (id option in self.rowDescriptor.selectorOptions) {
            [alertView addButtonWithTitle:[option displayText]];
        }
        alertView.cancelButtonIndex = [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alertView show];
        [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
    }

}


-(NSError *)formDescriptorCellLocalValidation
{
    if (self.rowDescriptor.required && self.rowDescriptor.value == nil){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeRequired userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"%@ can't be empty", nil), self.rowDescriptor.title] }];
        
    }
    return nil;
}

#pragma mark - XLFormOptionsViewControllerDelegate

-(NSArray *)optionsViewControllerOptions:(XLFormOptionsViewController *)optionsViewController
{
    return self.rowDescriptor.selectorOptions;
}


-(BOOL)optionsViewControllerOptions:(id<XLSelectorTableViewControllerProtocol>)optionsViewController isOptionSelected:(id)option
{
    return [self.rowDescriptor.value isEqual:option];
}

- (void)optionsViewController:(XLFormOptionsViewController *)optionsViewController didSelectOption:(id)selectedValue atIndex:(NSIndexPath *)indexPath
{
    self.rowDescriptor.value = selectedValue;
    [self.formViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeSelectorActionSheet]){
        if ([actionSheet cancelButtonIndex] != buttonIndex){
            NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
            for (id option in self.rowDescriptor.selectorOptions){
                if ([[option displayText] isEqualToString:title]){
                    [self.rowDescriptor setValue:option];
                    [self.formViewController.tableView reloadData];
                    break;
                }
            }
        }
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeSelectorAlertView]){
        if ([alertView cancelButtonIndex] != buttonIndex){
            NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
            for (id option in self.rowDescriptor.selectorOptions){
                if ([[option displayText] isEqualToString:title]){
                    [self.rowDescriptor setValue:option];
                    [self.formViewController.tableView reloadData];
                    break;
                }
            }
        }
    }
}

@end
