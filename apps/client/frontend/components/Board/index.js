import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Stage, Layer } from 'react-konva';

import Ball from '../Ball';
import Paddle from '../Paddle';

import resizable from '../../containers/Resizable';

import positioning from '../../lib/positioning';
import GameAnimator from '../../lib/gameAnimator';

import './index.css';
import withBackground from '../../containers/WithBackground';

const paddlePropTypes = PropTypes.shape({
  fill: PropTypes.string.isRequired,
  height: PropTypes.number.isRequired,
  speed: PropTypes.number.isRequired,
  width: PropTypes.number.isRequired,
  x: PropTypes.number.isRequired,
  y: PropTypes.number.isRequired,
});

@withBackground
@resizable
export default class Board extends Component {
  static propTypes = {
    channel: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }).isRequired,
    width: PropTypes.number.isRequired,
    height: PropTypes.number.isRequired,
    paddleMargin: PropTypes.number,
    game: PropTypes.shape({
      ball: PropTypes.shape({
        radius: PropTypes.number.isRequired,
        speed: PropTypes.number.isRequired,
        vector_x: PropTypes.number.isRequired,
        vector_y: PropTypes.number.isRequired,
        x: PropTypes.number.isRequired,
        y: PropTypes.number.isRequired,
      }),
      board: PropTypes.shape({
        width: PropTypes.number.isRequired,
        height: PropTypes.number.isRequired,
      }),
      paddle_left: paddlePropTypes,
      paddle_right: paddlePropTypes,
    }).isRequired,
  };

  static defaultProps = {
    paddleMargin: 50,
  };

  componentDidMount() {
    this.gameAnimator = new GameAnimator({
      layer: this.layerRef,
      stage: this.stageRef,
      paddleLeft: this.paddleLeftRef,
      paddleRight: this.paddleRightRef,
      ball: this.ballRef,
    });

    const { channel } = this.props;

    channel.on('data', data => {
      const { width, height } = this.props;

      const newPositions = positioning.repositionGame({
        dimensions: { width, height },
        game: data.game,
      });

      this.gameAnimator.setPositions(newPositions);
    });

    this.gameAnimator.start();
  }

  // Only update when screen width:height changes
  shouldComponentUpdate(nextProps) {
    const { width, height } = this.props;
    const { width: nextWidth, height: nextHeight } = nextProps;

    return width !== nextWidth || height !== nextHeight;
  }

  componentWillUnmount() {
    this.gameAnimator.stop();
  }

  render() {
    const { game, width, height } = this.props;

    const { paddleLeft, paddleRight, ball } = positioning.repositionGame({
      dimensions: { width, height },
      game,
    });

    return (
      <Stage width={width} height={height} styleName="root">
        <Layer
          ref={ref => {
            this.layerRef = ref;
          }}
        >
          <Paddle
            ref={ref => {
              this.paddleLeftRef = ref && ref.paddleRef;
            }}
            {...paddleLeft}
          />

          <Paddle
            ref={ref => {
              this.paddleRightRef = ref && ref.paddleRef;
            }}
            {...paddleRight}
          />

          <Ball
            ref={ref => {
              this.ballRef = ref && ref.ballRef;
            }}
            {...ball}
          />
        </Layer>
      </Stage>
    );
  }
}
