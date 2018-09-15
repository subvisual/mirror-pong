import React, { Component } from 'react';

import { Socket } from 'phoenix';

import './index.css';

export default class Controller extends Component {
  state = {
    loading: true,
    status: null,
  };

  constructor(props) {
    super(props);

    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:play');
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
        this.setState({ loading: false, status: 'joined' });
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

  render() {
    const { loading, status } = this.state;

    if (loading) return <div styleName="root" />;

    return (
      <div styleName="root">
        <div styleName="child">
          {status === 'joined' ? 'Joined the game!' : "Couldn't join the game!"}
        </div>
      </div>
    );
  }
}
