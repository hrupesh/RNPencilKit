import {ViewProps, requireNativeComponent} from 'react-native';

interface IProps extends ViewProps {
  // Other Props here
}

const PencilKitView = requireNativeComponent<IProps>('PencilKit');

export default PencilKitView;
