import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { Stage, Layer } from 'react-konva';

import Paddle from '../Paddle';
import RetroText from '../RetroText';

import './index.css';

export default class Board extends Component {
  static propTypes = {
    width: PropTypes.number,
    height: PropTypes.number,
    paddleMargin: PropTypes.number,
  };

  static defaultProps = {
    width: window.innerWidth,
    height: window.innerHeight,
    paddleMargin: 50,
  };

  render() {
    const { width, height, paddleMargin } = this.props;
    return (
      <Stage width={width} height={height} styleName="root">
        <Layer>
          <RetroText
            text="Mirror Conf"
            x={width / 2}
            y={height / 2}
            offsetX={250}
            opacity={0.7}
          />

          <Paddle x={paddleMargin} y={height / 2} />

          <Paddle
            x={paddle => width - paddleMargin - paddle.width}
            y={height / 2}
          />
        </Layer>
      </Stage>
    );
  }
}
