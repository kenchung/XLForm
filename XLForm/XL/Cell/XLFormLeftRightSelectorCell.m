//
//  XLFormLeftRightSelectorCell.m
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

#import "UIView+XLFormAdditions.h"
#import "XLFormRightImageButton.h"
#import "NSObject+XLFormAdditions.h"
#import "XLFormLeftRightSelectorCell.h"

@interface XLFormLeftRightSelectorCell() <UIActionSheetDelegate, XLFormOptionsViewControllerDelegate>

@end


@implementation XLFormLeftRightSelectorCell


@synthesize leftButton = _leftButton;
@synthesize rightLabel = _rightLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView * separatorView = [UIView autolayoutView];
        [separatorView setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
        
        [self.contentView addSubview:self.leftButton];
        [self.contentView addSubview:self.rightLabel];
        [self.contentView addSubview:separatorView];
        
        NSDictionary * views = @{@"leftButton" : self.leftButton, @"rightLabel": self.rightLabel, @"separatorView": separatorView};
        
        [self.contentView addConstraint:[self.leftButton layoutConstraintSameHeightOf:self.contentView]];
        [self.contentView addConstraint:[self.rightLabel layoutConstraintSameHeightOf:self.contentView]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[leftButton]-[separatorView(1)]-[rightLabel]-14-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[separatorView]-8-|" options:0 metrics:nil views:views]];
        
    }
    return self;
}


#pragma mark - Properties


-(UIButton *)leftButton
{
    if (_leftButton) return _leftButton;
    _leftButton = [[XLFormRightImageButton alloc] init];
    [_leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"XLForm.bundle/forwardarrow.png"]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_leftButton addSubview:imageView];
    [_leftButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image(8)]|" options:0 metrics:0 views:@{@"image": imageView}]];
    
    UIView * separatorTop = [UIView autolayoutView];
    UIView * separatorBottom = [UIView autolayoutView];
    [_leftButton addSubview:separatorTop];
    [_leftButton addSubview:separatorBottom];
    [_leftButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separatorTop(separatorBottom)][image][separatorBottom]|" options:0 metrics:0 views:@{@"image": imageView, @"separatorTop": separatorTop, @"separatorBottom": separatorBottom}]];

    _leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    
    [_leftButton setTitleColor:[UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_leftButton setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];

    return _leftButton;
}

-(UILabel *)rightLabel
{
    if (_rightLabel) return _rightLabel;
    _rightLabel = [UILabel autolayoutView];
    [_rightLabel setTextColor:[UIColor grayColor]];
    [_rightLabel setTextAlignment:NSTextAlignmentRight];
    return _rightLabel;
}


-(XLFormLeftRightSelectorOption *)leftOptionForDescription:(NSString *)description
{
    if (description){
        return [[self.rowDescriptor.selectorOptions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ([description isEqual:[((XLFormLeftRightSelectorOption *)evaluatedObject).leftValue displayText]]);
        }]] firstObject];
    }
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
}

-(XLFormLeftRightSelectorOption *)leftOptionForOption:(id)option
{
    if (option){
        return [[self.rowDescriptor.selectorOptions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            XLFormLeftRightSelectorOption * evaluatedLeftOption = (XLFormLeftRightSelectorOption *)evaluatedObject;
            return [evaluatedLeftOption.leftValue isEqual:option];
        }]] firstObject];
    }
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
}




#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
}

-(void)update
{
    [super update];
    [self.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTitle:[NSString stringWithFormat:@"%@%@", [self.rowDescriptor.leftRightSelectorLeftOptionSelected displayText], self.rowDescriptor.required ? @"*" : @""] forState:UIControlStateNormal];
    self.rightLabel.text = [self rightTextLabel];
    [self.leftButton setEnabled:(!self.rowDescriptor.disabled)];
    self.accessoryView = self.rowDescriptor.disabled ? nil : [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"XLForm.bundle/forwardarrow.png"]];
    self.selectionStyle = self.rowDescriptor.disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    UIFont * labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFontDescriptor * fontDesc = [labelFont fontDescriptor];
    
    self.leftButton.titleLabel.font = [UIFont fontWithDescriptor:fontDesc size:0];
    self.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}


-(NSString *)rightTextLabel
{
    return (self.rowDescriptor.value ? [self.rowDescriptor.value displayText] : (self.rowDescriptor.leftRightSelectorLeftOptionSelected ? [self leftOptionForOption:self.rowDescriptor.leftRightSelectorLeftOptionSelected].noValueDisplayText : @""));
}


-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if (self.rowDescriptor.leftRightSelectorLeftOptionSelected){
        XLFormLeftRightSelectorOption * option = [self leftOptionForOption:self.rowDescriptor.leftRightSelectorLeftOptionSelected];
        if (option.rightOptions){
            XLFormOptionsViewController * optionsViewController = [[XLFormOptionsViewController alloc] initWithDelegate:self multipleSelection:NO style:UITableViewStyleGrouped];
            optionsViewController.tag = self.rowDescriptor.tag;
            optionsViewController.title = option.selectorTitle;
            [controller.navigationController pushViewController:optionsViewController animated:YES];
        }
        else{
            XLFormSelectorTableViewController * selectorViewController = [[XLFormSelectorTableViewController alloc] initWithDelegate:self localDataLoader:option.rightLocalDataLoader remoteDataLoader:option.rightRemoteDataLoader];
            selectorViewController.tag = self.rowDescriptor.tag;
            selectorViewController.title = option.selectorTitle;
            selectorViewController.supportRefreshControl = option.selectorSupportRefreshControl;
            selectorViewController.loadingPagingEnabled = option.selectorLoadingPagingEnabled;
            [controller.navigationController pushViewController:selectorViewController animated:YES];
        }
    }
}


-(NSString *)formDescriptorHttpParameterName
{
    XLFormLeftRightSelectorOption * option = [self leftOptionForOption:self.rowDescriptor.leftRightSelectorLeftOptionSelected];
    return option.httpParameterKey;
}

-(NSError *)formDescriptorCellLocalValidation
{
    if (self.rowDescriptor.required && self.rowDescriptor.value == nil){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeRequired userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"%@ can't be empty", nil), [self.rowDescriptor.leftRightSelectorLeftOptionSelected displayText]]}];
        
    }
    return nil;
}


#pragma mark - Actions


-(void)leftButtonPressed:(UIButton *)leftButton
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:self.rowDescriptor.selectorTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = [self.rowDescriptor hash];
    for (XLFormLeftRightSelectorOption * leftOption in self.rowDescriptor.selectorOptions) {
        [actionSheet addButtonWithTitle:[leftOption.leftValue displayText]];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showInView:self.formViewController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet cancelButtonIndex] != buttonIndex){
        NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (![self.rowDescriptor.leftRightSelectorLeftOptionSelected isEqual:[self leftOptionForDescription:title].leftValue]){
            self.rowDescriptor.leftRightSelectorLeftOptionSelected = [self leftOptionForDescription:title].leftValue;
            [self.leftButton setTitle:[NSString stringWithFormat:@"%@%@", [self.rowDescriptor.leftRightSelectorLeftOptionSelected displayText], self.rowDescriptor.required ? @"*" : @""] forState:UIControlStateNormal];
            self.rowDescriptor.value = nil;
            self.rightLabel.text = [self rightTextLabel];
        }
    }
}


#pragma mark - XLFormOptionsViewControllerDelegate


-(BOOL)optionsViewControllerOptions:(XLFormOptionsViewController *)optionsViewController isOptionSelected:(id)option
{
    return [self.rowDescriptor.value isEqual:option];
}

- (NSArray *)optionsViewControllerOptions:(XLFormOptionsViewController *)optionsViewController
{
    return  [[self leftOptionForOption:self.rowDescriptor.leftRightSelectorLeftOptionSelected] rightOptions];
}

- (void)optionsViewController:(XLFormOptionsViewController *)optionsViewController didSelectOption:(id)selectedOption atIndex:(NSIndexPath *)indexpath
{
    self.rowDescriptor.value = selectedOption;
    [self.formViewController.navigationController popViewControllerAnimated:YES];
}

@end
