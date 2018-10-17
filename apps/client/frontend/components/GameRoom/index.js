import React, { Component } from 'react';

import Controller from '../Controller';
import Centered from '../Centered';
import Channel from '../../lib/channel';

import './index.css';

export default class GameRoom extends Component {
  state = {
    loading: true,
    paddleColor: null,
    playerId: null,
    winner: false,
  };

  constructor(props) {
    super(props);

    this.playChannel = new Channel('game:play');
    this.metadataChannel = new Channel('game:metadata');

    this.joinChannel(this.playChannel).then(response => {
      this.setState({
        loading: false,
        playerId: response.player_id,
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

      this.setState({ loading: false });
    }
  };

  subscribeToGameOver = () => {
    this.metadataChannel.on('game_over', data => {
      const winner = data.score_right > data.score_left ? 'right' : 'left';
      this.setState({ winner });

      this.leaveChannel(this.playChannel);
      this.leaveChannel(this.metadataChannel);

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

  renderResult() {
    const { winner, playerId } = this.state;

    if (winner === playerId) return <Centered>You won!</Centered>;

    return <Centered>You lost!</Centered>;
  }

  renderInnerContent() {
    const { playerId } = this.state;

    if (playerId) return <Controller channel={this.playChannel} />;

    return 'Could not join the game!';
  }

  render() {
    const { loading, winner } = this.state;

    if (loading) return null;

    if (winner) return this.renderResult();

    const { paddleColor: backgroundColor } = this.state;

    return (
      <Centered style={{ backgroundColor }}>
        {this.renderInnerContent()}
      </Centered>
    );
  }
}
