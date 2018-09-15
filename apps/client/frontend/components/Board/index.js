import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { Stage, Layer } from 'react-konva';
import { Socket } from 'phoenix';

import Paddle from '../Paddle';
import RetroText from '../RetroText';

import './index.css';

export default class Board extends Component {
  /* eslint react/no-unused-state: 0 */
  state = {
    ball: null,
    board: null,
    paddle_left: null,
    paddle_right: null,
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
        this.setState(data);
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
      this.setState(data);
      console.log(data);
    });
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
