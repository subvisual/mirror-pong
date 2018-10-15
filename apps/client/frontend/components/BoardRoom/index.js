import React, { Component } from 'react';
import _ from 'lodash';

import Centered from '../Centered';
import BoardCountdown from '../BoardCountdown';
import Channel from '../../lib/channel';

export default class BoardRoom extends Component {
  state = {
    game: null,
    delay: null,
    gameOver: false,
  };

  constructor(props) {
    super(props);

    this.channel = new Channel('game:metadata');

    this.joinChannel();
  }

  componentWillUnmount() {
    this.leaveChannel();
  }

  joinChannel = async () => {
    try {
      const response = await this.channel.join();

      console.log('Joined successfully'); // eslint-disable-line

      this.subscribeToMetadata();


      if (response.game) {
        this.setState({ game: response.game });
      }
    } catch (error) {
      console.log('Unable to join', resp); // eslint-disable-line
    }
  };

  subscribeToMetadata = () => {
    this.channel.on('game_starting', data => {
      this.setState({ delay: data.delay, game: data.game, gameOver: false });
    });

    this.channel.on('game_over', () => {
      this.setState({ gameOver: true });
    });

    this.channel.on('player_left', () => {
      this.setState({ delay: null, game: null });
    });
  };

  leaveChannel = async () => {
    try {
      const response = await this.channel.leave();

      console.log('Left successfully', response); // eslint-disable-line
    } catch (error) {
      console.log('Error while leaving the channel', error); // eslint-disable-line
    }
  };

  render() {
    const { game, delay, gameOver } = this.state;

    if (gameOver) {
      return (
        <Centered>
          Game Over!
        </Centered>
      );
    }

    if (_.isNil(game)) {
      return <Centered>Currently waiting for players!</Centered>;
    }

    return <BoardCountdown delay={delay} {...this.props} game={game} />;
  }
}
