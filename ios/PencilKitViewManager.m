//
//  PencilKitViewManager.m
//  RNPencilKit
//
//  Created by Rupesh Chaudhari
//

#import "PencilKitViewManager.h"
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <PencilKit/PencilKit.h>
#import <Photos/Photos.h>

#import "RNPencilKit.h"

@implementation PencilKitViewManager

RCT_EXPORT_MODULE(PencilKit)

RCT_CUSTOM_VIEW_PROPERTY(imagePath, NSObject, PencilKitViewManager) {
  @try {
    _imagePath = json;
    NSURL *url = [NSURL URLWithString:[_imagePath valueForKey:@"uri"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    _imageView = [[UIImageView alloc] initWithImage:image];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    [tempView setBackgroundColor:UIColor.whiteColor];
    [tempView addSubview:_imageView];
    UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, self->_canvasView.opaque, 0.0f);
    [tempView drawViewHierarchyInRect:tempView.bounds afterScreenUpdates:YES];
    UIImage *snapshotImageFromView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _imageView = [[UIImageView alloc] initWithImage:snapshotImageFromView];
    [_canvasView insertSubview:_imageView atIndex:0];
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

- (UIView *)view
{
  @try {
    _canvasView = [[PKCanvasView alloc] init];
    _canvasView.drawing = _drawing;
    _canvasView.drawingPolicy = PKCanvasViewDrawingPolicyAnyInput;
    _canvasView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    _canvasView.multipleTouchEnabled = true;
    _canvasView.opaque = true;
    _canvasView.backgroundColor = UIColor.clearColor;
    _canvasView.delegate = self;
    _canvasView.scrollEnabled = YES;
    _canvasView.userInteractionEnabled = YES;
    _canvasView.minimumZoomScale = 1.0;
    _canvasView.maximumZoomScale = 4.0;
    [_canvasView setBounces:NO];
    [_canvasView setBouncesZoom:NO];
    
    [[RNPencilKit sharedInstance] loadData];
    
    if ([RNPencilKit sharedInstance].drawingData) {
      _canvasView.drawing = [[PKDrawing alloc] initWithData:[RNPencilKit sharedInstance].drawingData error:nil];
    }
    
    return _canvasView;
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
  return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
  @try {
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _canvasView.frame.size.width * scrollView.zoomScale, _canvasView.frame.size.height * scrollView.zoomScale)];
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

RCT_EXPORT_METHOD(setupToolPicker: (nonnull NSNumber *)viewTag)
{
  @try {
    [self setupToolPicker];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_imageView setFrame:CGRectMake(self->_imageView.frame.origin.x, self->_imageView.frame.origin.y, self->_canvasView.frame.size.width, self->_canvasView.frame.size.height)];
      self->_imageView.center = CGPointMake(UIScreen.mainScreen.bounds.size.width * 0.5, self->_canvasView.bounds.size.height * 0.5);
    });
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

-(void) setupToolPicker{
  @try {
    dispatch_async(dispatch_get_main_queue(), ^{
      self->_toolPicker = [[PKToolPicker alloc] init];
      [self->_toolPicker setVisible:true forFirstResponder:self->_canvasView];
      [self->_toolPicker addObserver:self->_canvasView];
      [self->_toolPicker addObserver:self];
      [self->_canvasView becomeFirstResponder];
      self->_undoManager = [[self->_canvasView undoManager] init];
      NSLog(@"Set Toolpicker");
    });
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

RCT_EXPORT_METHOD(clearDrawing: (nonnull NSNumber *)viewTag)
{
  NSLog(@"Clearing Drawing");
  [self clearDrawing];
}

-(void) clearDrawing{
  _canvasView.drawing = [[PKDrawing alloc] init];
}

RCT_EXPORT_METHOD(captureDrawing: (nonnull NSNumber *)viewTag)
{
  NSLog(@"Capturing Drawn Image");
  [self captureDrawing];
}

-(void) captureDrawing{
  @try {
    dispatch_async(dispatch_get_main_queue(), ^{
      UIGraphicsBeginImageContextWithOptions(self->_canvasView.bounds.size, self->_canvasView.opaque, 0.0f);
      [self->_canvasView drawViewHierarchyInRect:self->_canvasView.bounds afterScreenUpdates:NO];
      UIImage *snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{[
        PHAssetChangeRequest creationRequestForAssetFromImage:snapshotImageFromMyView];
      } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
          NSString *path = [NSString stringWithFormat:@"photos-redirect://"];
          NSURL *imagePathUrl = [NSURL URLWithString:path];
          [[UIApplication sharedApplication] openURL:imagePathUrl options:@{} completionHandler:nil];
          [self clearDrawing];
        } else {
          NSLog(@"Error creating asset: %@", error);
        }
      }];
    });
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

RCT_EXPORT_METHOD(undo: (nonnull NSNumber *)viewTag)
{
  NSLog(@"Undo Called");
  [self undoDrawing];
}

-(void) undoDrawing{
  @try {
    [_undoManager undo];
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

RCT_EXPORT_METHOD(redo: (nonnull NSNumber *)viewTag)
{
  NSLog(@"Redo Called");
  [self redoDrawing];
}

-(void) redoDrawing{
  @try {
    [_undoManager redo];
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

- (void)canvasViewDrawingDidChange:(PKCanvasView *)canvasView{
  @try {
    [RNPencilKit sharedInstance].drawingData = canvasView.drawing.dataRepresentation;
    [[RNPencilKit sharedInstance] saveData];
  } @catch (NSException *exception) {
    NSLog(@"Error %@", exception.reason);
  }
}

@end
