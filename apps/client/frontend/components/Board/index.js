import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { Stage, Layer } from 'react-konva';
import { Socket } from 'phoenix';

import Ball from '../Ball';
import Paddle from '../Paddle';
import RetroText from '../RetroText';

import positioning from '../../lib/positioning';

import './index.css';

export default class Board extends Component {
  /* eslint react/no-unused-state: 0 */
  state = {
    game: {
      ball: null,
      board: null,
      paddle_left: null,
      paddle_right: null,
    },
    loading: true,
  };
  /* eslint react/no-unused-state: 1 */

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

  constructor(props) {
    super(props);

    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:board');
    this.joinChannel();
  }

  componentWillUnmount() {
    this.leaveChannel();
  }

  joinChannel = () => {
    this.channel
      .join()
      .receive('ok', data => {
        console.log('Joined successfully', data); // eslint-disable-line
        this.setState({ game: { ...data }, loading: false });
        this.subscribeToData();
      })
      .receive('error', resp => {
        console.log('Unable to join', resp); // eslint-disable-line
      });
  };

  leaveChannel = () => {
    this.channel
      .leave()
      .receive('ok', resp => {
        console.log('Left successfully', resp); // eslint-disable-line
        this.socket.disconnect();
      })
      .receive('error', resp => {
        console.log('Could not leave the channel!', resp); // eslint-disable-line
        this.socket.disconnect();
      });
  };

  subscribeToData = () => {
    this.channel.on('data', data => {
      this.setState({ game: { ...data } });
    });
  };

  render() {
    const { loading } = this.state;

    if (loading) return <div styleName="root" />;

    const { game } = this.state;
    const { width, height } = this.props;

    const {
      paddle_left: paddleLeft,
      paddle_right: paddleRight,
      ball,
    } = positioning.repositionGame({
      dimensions: { width, height },
      game: game,
    });

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

          <Paddle {...paddleLeft} />

          <Paddle {...paddleRight} />

          <Ball {...ball} />
        </Layer>
      </Stage>
    );
  }
}
