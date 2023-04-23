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

@interface PencilKitViewManager : RCTViewManager<PKToolPickerObserver>
@property PKCanvasView* canvasView;
@property PKDrawing* drawing;
@property UIImage* drawingImage;
@property PKToolPicker* toolPicker;
@end

@implementation PencilKitViewManager

RCT_EXPORT_MODULE(PencilKit)


- (UIView *)view
{
  _canvasView = [[PKCanvasView alloc] init];
  _canvasView.drawing = _drawing;
  _canvasView.drawingPolicy = PKCanvasViewDrawingPolicyAnyInput;
  _canvasView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
  _canvasView.multipleTouchEnabled = true;
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
    self->_drawingImage = [self->_canvasView.drawing imageFromRect:self->_canvasView.bounds scale:1.0];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{[
      PHAssetChangeRequest creationRequestForAssetFromImage:self->_drawingImage];
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
