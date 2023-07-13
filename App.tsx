import React, {useCallback, useEffect, useRef} from 'react';
import {
  Dimensions,
  findNodeHandle,
  Image,
  Platform,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  UIManager,
} from 'react-native';
import {Clear, Save, CanvasBackgroundImage} from './assets/icons';
import PencilKitView from './PencilkitView';

const App: React.FC = () => {
  const drawingRef = useRef(null);

  useEffect(() => {
    setTimeout(() => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(drawingRef?.current),
        UIManager.getViewManagerConfig('PencilKit').Commands.setupToolPicker,
        undefined,
      );
    }, 200);
  }, []);

  const handleClearDrawing = useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(drawingRef?.current),
      UIManager.getViewManagerConfig('PencilKit').Commands.clearDrawing,
      undefined,
    );
  }, [drawingRef?.current]);

  const handleCaptureDrawing = useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(drawingRef?.current),
      UIManager.getViewManagerConfig('PencilKit').Commands.captureDrawing,
      undefined,
    );
  }, [drawingRef?.current]);

  if (Platform.OS !== 'ios') {
    return (
      <SafeAreaView
        style={[
          styles.container,
          {
            justifyContent: 'center',
            alignItems: 'center',
          },
        ]}>
        <Text style={styles.text}>{'We only support iOS For Now 😔'}</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <PencilKitView
        ref={drawingRef}
        style={styles.container}
        imagePath={
          Image.resolveAssetSource(CanvasBackgroundImage) || {
            uri: 'https://picsum.photos/720/1080',
          }
        }
      />
      <Pressable onPress={handleClearDrawing} style={styles.clearBtn}>
        <Image source={Clear} resizeMode={'contain'} style={styles.icon} />
      </Pressable>
      <Pressable onPress={handleCaptureDrawing} style={styles.saveBtn}>
        <Image source={Save} resizeMode={'contain'} style={styles.icon} />
      </Pressable>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff0',
  },
  icon: {
    height: 50,
    width: 50,
  },
  clearBtn: {
    position: 'absolute',
    top: 100,
    right: 24,
  },
  saveBtn: {
    position: 'absolute',
    top: 200,
    right: 24,
  },
  text: {
    fontSize: 24,
    fontWeight: '600',
    color: '#222',
  },
});

export default App;
