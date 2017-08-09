#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (TTCategory)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;
@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;
@property(nonatomic,readonly) CGRect screenFrame;
@property(nonatomic,readonly) CGPoint screenViewCenter;
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;

@property(nonatomic,readonly) CGPoint centerPoint;

@property(nonatomic,readonly) CGFloat orientationWidth;
@property(nonatomic,readonly) CGFloat orientationHeight;

/**
 * Finds the lowest y-coordinate of all subviews or self.bounds.origin.y
 */
- (CGFloat)bottomOfAllSubviews;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

/**
 * Calculates the offset of this view from another view in screen coordinates.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;

/**
 * Shows the view in a window at the bottom of the screen.
 *
 * This will send a notification pretending that a keyboard is about to appear so that
 * observers who adjust their layout for the keyboard will also adjust for this view.
 */
- (void)presentAsKeyboardInView:(UIView*)containingView;

/**
 * Hides a view that was showing in a window at the bottom of the screen (via presentAsKeyboard).
 *
 * This will send a notification pretending that a keyboard is about to disappear so that
 * observers who adjust their layout for the keyboard will also adjust for this view.
 */
- (void)dismissAsKeyboard:(BOOL)animated;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;

/**
 * Center align child views with a distance between them
 */
-(void) alignChildViews:(UIView*)view1 view2:(UIView*)view2 distance:(float)distance;

/**
 * Center align child views with a distance between them with offset on both view
 */
-(void) alignChildViews:(UIView*)view1 view2:(UIView*)view2 distance:(float)distance offset:(float)offset;

/**
 Set anchor point of a view without displacing it visually
 */

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;
@end
