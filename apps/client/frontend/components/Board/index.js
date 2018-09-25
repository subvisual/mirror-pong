import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Stage, Layer } from 'react-konva';

import Ball from '../Ball';
import Paddle from '../Paddle';
import RetroText from '../RetroText';

import resizable from '../Resizable';

import positioning from '../../lib/positioning';
import GameAnimator from '../../lib/gameAnimator';

import './index.css';

const paddlePropTypes = PropTypes.shape({
  fill: PropTypes.string.isRequired,
  height: PropTypes.number.isRequired,
  speed: PropTypes.number.isRequired,
  width: PropTypes.number.isRequired,
  x: PropTypes.number.isRequired,
  y: PropTypes.number.isRequired,
});

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
      paddleLeft: this.paddleLeftRef,
      paddleRight: this.paddleRightRef,
      ball: this.ballRef,
    });

    const { channel, width, height } = this.props;

    channel.on('data', data => {
      const newPositions = positioning.repositionGame({
        dimensions: { width, height },
        game: data.game,
      });

      this.gameAnimator.setPositions(newPositions);
    });

    this.gameAnimator.start();
  }

  componentWillUnmount() {
    this.gameAnimator.stop();
  }

  shouldComponentUpdate = () => false;

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
          <RetroText
            text="Mirror Conf"
            x={width / 2}
            y={height / 2}
            offsetX={250}
            opacity={0.7}
          />

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
