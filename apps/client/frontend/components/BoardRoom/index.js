import React, { Component } from 'react';
import { Socket } from 'phoenix';
import _ from 'lodash';

import Centered from '../Centered';
import BoardCountdown from '../BoardCountdown';

export default class BoardRoom extends Component {
  /* eslint react/no-unused-state: 0 */
  state = {
    game: null,
    delay: null,
  };
  /* eslint react/no-unused-state: 1 */

  constructor(props) {
    super(props);

    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:metadata');
    this.joinChannel();
  }

  componentWillUnmount() {
    this.leaveChannel();
  }

  joinChannel = () => {
    this.channel
      .join()
      .receive('ok', data => {
        console.log('Joined successfully'); // eslint-disable-line
        this.subscribeToMetadata();

        if (data.game) {
          this.setState({ game: data.game });
        }
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

  subscribeToMetadata = () => {
    this.channel.on('game_starting', data => {
      this.setState({ delay: data.delay, game: data.game });
    });

    this.channel.on('player_left', () => {
      this.setState({ delay: null, game: null });
    });
  };

  render() {
    const { game, delay } = this.state;

    if (_.isNil(game)) {
      return <Centered>Currently waiting for players!</Centered>;
    }

    return <BoardCountdown delay={delay} {...this.props} game={game} />;
  }
}
