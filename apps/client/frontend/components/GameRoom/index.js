import React, { Component } from 'react';

import Controller from '../Controller';
import Centered from '../Centered';
import Channel from '../../lib/channel';

import './index.css';

export default class GameRoom extends Component {
  state = {
    loading: true,
    status: null,
    paddle_color: null,
  };

  constructor(props) {
    super(props);

    this.channel = new Channel('game:play');

    this.joinChannel();
  }

  componentWillUnmount() {
    this.leaveChannel();
  }

  joinChannel = async () => {
    try {
      const response = await this.channel.join();

      console.log('Joined successfully', response); // eslint-disable-line

      this.setState({ loading: false, status: 'joined', ...response });
    } catch (error) {
      console.log('Unable to join', error); // eslint-disable-line

      this.setState({ loading: false, status: 'error' });
    }
  };

  leaveChannel = async () => {
    try {
      const response = await this.channel.leave();

      console.log('Left successfully', response); // eslint-disable-line
    } catch (error) {
      console.log('Error while leaving the channel', error); // eslint-disable-line
    }
  };

  renderInnerContent() {
    const { status } = this.state;

    if (status === 'joined') return <Controller channel={this.channel} />;

    return 'Could not join the game!';
  }

  render() {
    const { loading } = this.state;

    if (loading) return <div styleName="root" />;

    const { paddle_color: backgroundColor } = this.state;

    return (
      <Centered style={{ backgroundColor }}>
        {this.renderInnerContent()}
      </Centered>
    );
  }
}
