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
  TouchableOpacity,
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

  const handleUndo = useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(drawingRef?.current),
      UIManager.getViewManagerConfig('PencilKit').Commands.undo,
      undefined,
    );
  }, [drawingRef?.current]);

  const handleRedo = useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(drawingRef?.current),
      UIManager.getViewManagerConfig('PencilKit').Commands.redo,
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
      <TouchableOpacity onPress={handleUndo} style={styles.undo}>
        <Text style={styles.undoRedoText}>{'Undo'}</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={handleRedo} style={styles.redo}>
        <Text style={styles.undoRedoText}>{'Redo'}</Text>
      </TouchableOpacity>
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
  undoRedoText: {
    fontSize: 20,
    fontWeight: '700',
    lineHeight: 32,
    color: '#fff',
    letterSpacing: 1.6,
  },
  undo: {
    position: 'absolute',
    backgroundColor: '#0004',
    top: 100,
    left: 14,
    borderRadius: 12,
    paddingVertical: 6,
    paddingHorizontal: 16,
  },
  redo: {
    position: 'absolute',
    backgroundColor: '#0004',
    top: 100,
    left: 120,
    borderRadius: 12,
    paddingVertical: 6,
    paddingHorizontal: 16,
  },
});

export default App;
