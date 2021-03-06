//
//  DUXBetaAirSenseDialogViewController.h
//  DJIUXSDKWidgets
//
//  MIT License
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

@class DUXDialogCustomizations;

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaAirSenseDialogViewController : UIViewController

/**
 *   The dialog title text ("Another aircraft is nearby...").
*/
@property (strong, nonatomic) NSString *dialogTitle;

/**
 *   The dialog title color.
*/
@property (strong, nonatomic) UIColor *dialogTitleTextColor;

/**
 *   The dialog clickable message text ("Please make sure you have read...").
*/
@property (strong, nonatomic) NSString *dialogMessage;

/**
 *  The image for the checkbox to the left of the "Don't show again" label when checked.
*/
@property (strong, nonatomic) UIImage *checkedCheckboxImage;

/**
 *  The image for the checkbox to the left of the "Don't show again" label when empty.
*/
@property (nonatomic, strong) UIImage *uncheckedCheckboxImage;

/**
 *  The warning dialog checkbox label("Don't show again") text color.
*/
@property (nonatomic, strong) UIColor *checkboxLabelTextColor;

/**
 *  The warning dialog checkbox label("Don't show again") text font.
*/
@property (nonatomic, strong) UIFont *checkboxLabelTextFont;

/**
 *  The warning dialog message(clickable message: "make sure you have read and understood...") text color.
*/
@property (nonatomic, strong) UIColor *warningMessageTextColor;

/**
 *  The warning dialog message(clickable message: "make sure you have read and understood...") text font.
*/
@property (nonatomic, strong) UIFont *warningMessageTextFont;

/**
 *  Construct with title and message.
*/
- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
