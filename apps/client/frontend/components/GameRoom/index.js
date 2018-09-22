import React, { Component } from 'react';

import { Socket } from 'phoenix';

import './index.css';
import Controller from '../Controller';

export default class GameRoom extends Component {
  state = {
    loading: true,
    status: null,
    paddle_color: null,
  };

  constructor(props) {
    super(props);

    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:play');
  }

  componentDidMount() {
    this.joinChannel();
  }

  componentWillUnmount() {
    this.leaveChannel();
  }

  joinChannel = () => {
    this.channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp); // eslint-disable-line
        this.setState({ loading: false, status: 'joined', ...resp });
      })
      .receive('error', resp => {
        console.log('Unable to join', resp); // eslint-disable-line
        this.setState({ loading: false, status: 'error' });
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
      <div styleName="root" style={{ backgroundColor }}>
        <div styleName="center">{this.renderInnerContent()}</div>
      </div>
    );
  }
}
