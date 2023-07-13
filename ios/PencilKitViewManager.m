//
//  PencilKitViewManager.m
//  RNPencilKit
//
//  Created by rupesh on 22/04/23.
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <PencilKit/PencilKit.h>
#import <Photos/Photos.h>

@interface PencilKitViewManager : RCTViewManager<PKToolPickerObserver, UIGestureRecognizerDelegate>
@property PKCanvasView* canvasView;
@property PKDrawing* drawing;
@property UIImage* drawingImage;
@property PKToolPicker* toolPicker;
@property (nonatomic) NSObject* imagePath;
@property UIImageView* imageView;
@property CGFloat imageScale;
@property UIView* contentView;
@end

@implementation PencilKitViewManager

RCT_EXPORT_MODULE(PencilKit)

RCT_CUSTOM_VIEW_PROPERTY(imagePath, NSObject, PencilKitViewManager) {
  _imagePath = json;
  NSURL *url = [NSURL URLWithString:[_imagePath valueForKey:@"uri"]];
  NSData *data = [NSData dataWithContentsOfURL:url];
  UIImage *image = [[UIImage alloc] initWithData:data];
  _imageView = [[UIImageView alloc] initWithImage:image];
  _imageView.contentMode = UIViewContentModeCenter;
  _imageView.clipsToBounds = true;
  UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc]
      initWithTarget:self action:@selector(handlePinchGesture:)];
  pgr.delegate = self;
  [_canvasView addGestureRecognizer:pgr];
  [_imageView setContentScaleFactor:_imageScale];
  [_canvasView insertSubview:_imageView atIndex:0];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
     if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
     _imageScale = [gestureRecognizer scale];
     }

     if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
     [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        const CGFloat kMaxScale = 4.0;
        const CGFloat kMinScale = 1.0;
        CGFloat newScale = 1 -  (_imageScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        _imageScale = [gestureRecognizer scale];
      }
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
  return _canvasView;
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
