//
//  DUXBetaFlyZoneAnnotationView.m
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

#import "DUXBetaFlyZoneAnnotationView.h"

@implementation DUXBetaFlyZoneAnnotationView

- (void)setNoFlyZoneAnnotationImage:(UIImage *)noFlyZoneAnnotationImage {
    _noFlyZoneAnnotationImage = noFlyZoneAnnotationImage;
    [self removeAllSubviews];
    UIImageView *homeAnnotationImageView = [[UIImageView alloc] initWithImage:noFlyZoneAnnotationImage];
    homeAnnotationImageView.frame = CGRectMake(0,0,noFlyZoneAnnotationImage.size.width,noFlyZoneAnnotationImage.size.height);
    [self addSubview:homeAnnotationImageView];
    self.image = noFlyZoneAnnotationImage;
}

- (void)removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

@end