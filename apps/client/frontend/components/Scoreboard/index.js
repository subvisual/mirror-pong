import React, { Component } from 'react';
import _ from 'lodash';
import Centered from '../Centered';

import Channel from '../../lib/channel';

import './index.css';

export default class Scoreboard extends Component {
  state = {
    score: {
      left: 0,
      right: 0,
    },
    loading: true,
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

      console.log('Joined successfully', response); // eslint-disable-line no-console

      const left = _.get(response, 'game.score_left', 0);
      const right = _.get(response, 'game.score_right', 0);

      this.setState({ score: { left, right }, loading: false });
      this.subscribeToGoals();
    } catch (error) {
      console.log('Unable to join', error); // eslint-disable-line no-console
    }
  };

  subscribeToGoals = () => {
    this.channel.on('player_scored', data => {
      this.setState({
        score: { left: data.score_left, right: data.score_right },
      });
    });
  };

  leaveChannel = async () => {
    try {
      const response = await this.channel.leave();

      console.log('Left successfully', response); // eslint-disable-line no-console
    } catch (error) {
      console.log('Error while leaving the channel', error); // eslint-disable-line no-console
    }
  };

  render() {
    const {
      score: { left, right },
      loading,
    } = this.state;

    if (loading) return null;

    return (
      <Centered>
        <div styleName="root">
          {`${left} - ${right}`}
          <br />
          <span styleName="url">pong.mirrorconf.com</span>
        </div>
      </Centered>
    );
  }
}
