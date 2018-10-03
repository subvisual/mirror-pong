import React, { Component } from 'react';
import { Socket } from 'phoenix';
import _ from 'lodash';

import Board from '../Board';
import Centered from '../Centered';

export default class BoardRoom extends Component {
  /* eslint react/no-unused-state: 0 */
  state = {
    game: {
      ball: null,
      board: null,
      paddle_left: null,
      paddle_right: null,
    },
    players: {
      left: null,
      right: null,
    },
    loading: true,
  };
  /* eslint react/no-unused-state: 1 */

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
        this.setState({
          game: { ...data.game },
          players: { ...data.players },
          loading: false,
        });
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
      this.setState({ game: { ...data.game }, players: { ...data.players } });
    });
  };

  render() {
    const {
      loading,
      players: { left, right },
    } = this.state;

    if (loading) return null;

    const playersNotAvailable = _.isNil(left) || _.isNil(right);

    if (playersNotAvailable) {
      return <Centered>Currently waiting for players!</Centered>;
    }

    return <Board {...this.state} />;
  }
}
