import React from 'react';
import PropTypes from 'prop-types';
import { View, requireNativeComponent, DeviceEventEmitter } from 'react-native';
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource'

class ImageSequence extends React.Component {
  componentWillMount() {
    DeviceEventEmitter.addListener('onLoadStart', (event: Event) => {
      if (this.props.onLoadStart) {
        this.props.onLoadStart(event)
      }
    })
    DeviceEventEmitter.addListener('onLoadComplete', (event: Event) => {
      if (this.props.onLoadComplete) {
        this.props.onLoadComplete(event)
      }
    })
    DeviceEventEmitter.addListener('onError', (event: Event) => {
      if (this.props.onError) {
        this.props.onError(event)
      }
    })
  }
  render() {
    let normalized = this.props.images.map(resolveAssetSource)

    // reorder elements if start-index is different from 0 (beginning)
    if (this.props.startFrameIndex !== 0) {
      normalized = [...normalized.slice(this.props.startFrameIndex), ...normalized.slice(0, this.props.startFrameIndex)]
    }

    let props = this.props
    if (props.size.width) {
      props.size.width = Math.round(props.size.width)
    }
    if (props.size.height) {
      props.size.height = Math.round(props.size.height)
    }

    return (
      <RCTImageSequence
        {...this.props}
        images={normalized} />
    )
  }
}

ImageSequence.propTypes = {
  startFrameIndex: PropTypes.number,
  images: PropTypes.array.isRequired,
  sampleSize: PropTypes.number,
  framesPerSecond: PropTypes.number,
  size: PropTypes.shape({
    width: PropTypes.number,
    height: PropTypes.number
  }),
  autoStart: PropTypes.bool,
  oneShot: PropTypes.bool,
}

ImageSequence.defaultProps = {
  startFrameIndex: 0,
  sampleSize: 1,
  framesPerSecond: 24,
  autoStart: true,
  oneShot: false
}

const RCTImageSequence = requireNativeComponent('RCTImageSequence', {
  propTypes: {
    ...View.propTypes,
    images: PropTypes.arrayOf(PropTypes.shape({
      uri: PropTypes.string.isRequired
    })).isRequired,
    sampleSize: PropTypes.number,
    framesPerSecond: PropTypes.number,
    size: PropTypes.shape({
      width: PropTypes.number,
      height: PropTypes.number
    }),
    autoStart: PropTypes.bool,
    oneShot: PropTypes.bool,
    onLoadStart: PropTypes.func,
    onLoadComplete: PropTypes.func,
    onError: PropTypes.func
  },
})

export default ImageSequence
