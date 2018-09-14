import React, { Component } from 'react';

import { Socket } from 'phoenix';

import './index.css';

export default class Controller extends Component {
  componentWillMount() {
    this.socket = new Socket('/socket');

    this.socket.connect();
    this.channel = this.socket.channel('game:play');
    this.channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp); // eslint-disable-line
      })
      .receive('error', resp => {
        console.log('Unable to join', resp); // eslint-disable-line
      });
  }

  render() {
    return (
      <div styleName="root">
        <div styleName="child">Controller (WIP)</div>
      </div>
    );
  }
}
