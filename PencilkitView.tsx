import {
  ViewProps,
  requireNativeComponent,
  ImageResolvedAssetSource,
} from 'react-native';

interface IProps extends ViewProps {
  imagePath?: ImageResolvedAssetSource | {uri: string};
}

const PencilKitView = requireNativeComponent<IProps>('PencilKit');

export default PencilKitView;
