import React, { Component } from 'react';

import { Socket } from 'phoenix';

import './index.css';

export default class Controller extends Component {
  socket = new Socket('/socket');

  componentWillMount() {
    this.socket.connect();

    window.channel = this.socket.channel('game:play');

    window.channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp);
      })
      .receive('error', resp => {
        console.log('Unable to join', resp);
      });
  }

  componentWillUnmount() {
    this.socket.disconnect();
  }

  render() {
    return (
      <div styleName="root">
        <div styleName="child">Controller (WIP)</div>
      </div>
    );
  }
}
