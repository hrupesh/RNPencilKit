//
//  PencilKitViewManager.m
//  RNPencilKit
//
//  Created by Rupesh Chaudhari
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <PencilKit/PencilKit.h>
#import <Photos/Photos.h>

@interface PencilKitViewManager : RCTViewManager<PKToolPickerObserver, UIGestureRecognizerDelegate, PKCanvasViewDelegate>
@property PKCanvasView* canvasView;
@property PKDrawing* drawing;
@property PKToolPicker* toolPicker;
@property (nonatomic) NSObject* imagePath;
@property UIImageView* imageView;
@end

@implementation PencilKitViewManager

RCT_EXPORT_MODULE(PencilKit)

RCT_CUSTOM_VIEW_PROPERTY(imagePath, NSObject, PencilKitViewManager) {
  _imagePath = json;
  NSURL *url = [NSURL URLWithString:[_imagePath valueForKey:@"uri"]];
  NSData *data = [NSData dataWithContentsOfURL:url];
  UIImage *image = [[UIImage alloc] initWithData:data];
  _imageView = [[UIImageView alloc] initWithImage:image];
  [_canvasView insertSubview:_imageView atIndex:0];
}

- (UIView *)view
{
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
  return _canvasView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
  return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
  CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
  CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
  [_imageView setFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _canvasView.frame.size.width * scrollView.zoomScale, _canvasView.frame.size.height * scrollView.zoomScale)];
  _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

RCT_EXPORT_METHOD(setupToolPicker: (nonnull NSNumber *)viewTag)
{
  [self setupToolPicker];
}

-(void) setupToolPicker{
  dispatch_async(dispatch_get_main_queue(), ^{
    self->_toolPicker = [[PKToolPicker alloc] init];
    [self->_toolPicker setVisible:true forFirstResponder:self->_canvasView];
    [self->_toolPicker addObserver:self->_canvasView];
    [self->_toolPicker addObserver:self];
    [self->_canvasView becomeFirstResponder];
    NSLog(@"Set Toolpicker");
  });
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
}

@end
