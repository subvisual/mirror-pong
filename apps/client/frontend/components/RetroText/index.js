import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { Text } from 'react-konva';

export default class RetroText extends Component {
  static propTypes = {
    text: PropTypes.string.isRequired,
    x: PropTypes.number.isRequired,
    y: PropTypes.number.isRequired,
    fontSize: PropTypes.number,
    offsetX: PropTypes.number,
    opacity: PropTypes.number,
  };

  static defaultProps = {
    fontSize: 112,
    offsetX: 0,
    opacity: 1,
  };

  render() {
    const { text, x, y, fontSize, offsetX, opacity } = this.props;

    return (
      <Text
        text={text}
        x={x}
        y={y - fontSize / 2}
        fill="#EFEFEF"
        fontSize={fontSize}
        fontFamily="VT323"
        offsetX={offsetX}
        opacity={opacity}
      />
    );
  }
}
