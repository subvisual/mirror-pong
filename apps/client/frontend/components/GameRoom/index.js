import React, { Component } from 'react';

import Controller from '../Controller';
import Centered from '../Centered';
import Channel from '../../lib/channel';

import './index.css';

export default class GameRoom extends Component {
  state = {
    loading: true,
    status: null,
    paddleColor: null,
    gameOver: false,
  };

  constructor(props) {
    super(props);

    this.playChannel = new Channel('game:play');
    this.metadataChannel = new Channel('game:metadata');

    this.joinChannel(this.playChannel).then(response => {
      this.setState({
        loading: false,
        status: 'joined',
        paddleColor: response.paddle_color,
      });
    });
    this.joinChannel(this.metadataChannel);

    this.subscribeToGameOver();
  }

  componentWillUnmount() {
    this.leaveChannel(this.playChannel);
    this.leaveChannel(this.metadataChannel);
  }

  joinChannel = async channel => {
    try {
      const response = await channel.join();

      console.log('Joined successfully', response); // eslint-disable-line

      return response;
    } catch (error) {
      console.log('Unable to join', error); // eslint-disable-line

      this.setState({ loading: false, status: 'error' });
    }
  };

  subscribeToGameOver = () => {
    this.metadataChannel.on('game_over', () => {
      this.setState({ gameOver: true });

      setTimeout(() => {
        window.location.href = '/';
      }, 3000);
    });
  };

  leaveChannel = async channel => {
    try {
      const response = await channel.leave();

      console.log('Left successfully', response); // eslint-disable-line
    } catch (error) {
      console.log('Error while leaving the channel', error); // eslint-disable-line
    }
  };

  renderInnerContent() {
    const { status } = this.state;

    if (status === 'joined') return <Controller channel={this.playChannel} />;

    return 'Could not join the game!';
  }

  render() {
    const { loading, gameOver } = this.state;

    if (loading) return null;

    if (gameOver) return <Centered>Game Over!</Centered>;

    const { paddleColor: backgroundColor } = this.state;

    return (
      <Centered style={{ backgroundColor }}>
        {this.renderInnerContent()}
      </Centered>
    );
  }
}
